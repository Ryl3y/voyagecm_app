from datetime import timedelta

from app.services import today_cameroon
from tests.conftest import login

TOMORROW = (today_cameroon() + timedelta(days=1)).isoformat()


def city_ids(client) -> dict[str, int]:
    return {c["name"]: c["id"] for c in client.get("/cities").json()}


def search(client, dep: str, arr: str, day: str = TOMORROW):
    ids = city_ids(client)
    return client.get(
        "/trips/search",
        params={"departure_city_id": ids[dep], "arrival_city_id": ids[arr], "travel_date": day},
    )


def booking_payload(trip_id: int, seat: int, day: str = TOMORROW) -> dict:
    return {
        "trip_id": trip_id,
        "travel_date": day,
        "seat_number": seat,
        "passenger_name": "Jean Mballa",
        "passenger_cni": "123456789",
        "passenger_phone": "6 77 12 34 56",
        "payment_method": "mtn",
    }


def test_search_returns_seeded_trips(client):
    response = search(client, "Yaoundé", "Douala")
    assert response.status_code == 200
    trips = response.json()
    assert [t["code"] for t in trips] == ["R001", "R003", "R002", "R031"]  # triés par heure
    zoom = trips[-1]
    assert zoom["trip_class"] == "Zoom" and zoom["capacity"] == 50 and zoom["available_seats"] == 50


def test_search_rejects_same_city_and_past_date(client):
    assert search(client, "Douala", "Douala").status_code == 400
    yesterday = (today_cameroon() - timedelta(days=1)).isoformat()
    assert search(client, "Yaoundé", "Douala", yesterday).status_code == 400


def test_booking_flow_and_double_booking(client):
    trip = search(client, "Yaoundé", "Douala").json()[0]

    response = client.post("/bookings", json=booking_payload(trip["id"], 12))
    assert response.status_code == 201, response.text
    booking = response.json()
    assert booking["code"].startswith("CM-") and booking["code"].endswith("-S12")
    assert booking["passenger_phone"] == "677123456"
    assert booking["passenger_cni_masked"].endswith("789") and "123" not in booking["passenger_cni_masked"]
    assert booking["amount"] == trip["price"]

    # Même siège, même date : refusé
    again = client.post("/bookings", json=booking_payload(trip["id"], 12))
    assert again.status_code == 409
    assert "déjà pris" in again.json()["detail"]

    # Le siège est libre un autre jour
    other_day = (today_cameroon() + timedelta(days=2)).isoformat()
    assert client.post("/bookings", json=booking_payload(trip["id"], 12, other_day)).status_code == 201

    seats = client.get(f"/trips/{trip['id']}/seats", params={"travel_date": TOMORROW}).json()
    assert seats["occupied"] == [12]
    assert search(client, "Yaoundé", "Douala").json()[0]["available_seats"] == trip["capacity"] - 1

    assert client.get(f"/bookings/{booking['code'].lower()}").status_code == 200


def test_booking_validation(client):
    trip = search(client, "Yaoundé", "Douala").json()[0]
    bad_phone = booking_payload(trip["id"], 1) | {"passenger_phone": "12345"}
    assert client.post("/bookings", json=bad_phone).status_code == 422
    assert client.post("/bookings", json=booking_payload(trip["id"], 71)).status_code == 400


def test_login_rejects_bad_password(client):
    response = client.post("/auth/login", json={"username": "admin", "password": "faux"})
    assert response.status_code == 401


def test_agency_manages_only_its_trips(client):
    headers = login(client, "agency1", "agency-test")
    mine = client.get("/agency/trips", headers=headers).json()
    assert {t["agency"]["name"] for t in mine} == {"Touristique Express"}

    ids = city_ids(client)
    created = client.post(
        "/agency/trips",
        headers=headers,
        json={
            "departure_city_id": ids["Douala"],
            "arrival_city_id": ids["Kribi"],
            "departure_time": "07:15",
            "arrival_time": "10:30",
            "price": 5000,
            "trip_class": "Zoom",
        },
    )
    assert created.status_code == 201, created.text
    new_trip = created.json()
    assert new_trip["capacity"] == 50 and new_trip["code"].startswith("R")

    updated = client.put(f"/agency/trips/{new_trip['id']}", headers=headers, json={"price": 5500, "trip_class": "VIP"})
    assert updated.status_code == 200 and updated.json()["capacity"] == 70

    # Un trajet d'une autre agence n'est pas accessible
    other = search(client, "Yaoundé", "Bafoussam").json()[0]
    assert client.delete(f"/agency/trips/{other['id']}", headers=headers).status_code == 404

    assert client.delete(f"/agency/trips/{new_trip['id']}", headers=headers).status_code == 204
    assert search(client, "Douala", "Kribi").json() == []


def test_admin_only_routes(client):
    agency_headers = login(client, "agency1", "agency-test")
    assert client.get("/admin/stats", headers=agency_headers).status_code == 403
    assert client.get("/admin/stats").status_code == 401

    headers = login(client, "admin", "admin-test")
    stats = client.get("/admin/stats", headers=headers).json()
    assert stats["total_trips"] == 31 and stats["total_agencies"] == 10

    created = client.post(
        "/admin/agencies",
        headers=headers,
        json={"name": "General Voyages", "services": ["VIP", " ", "Wifi"], "verified": True},
    )
    assert created.status_code == 201, created.text
    body = created.json()
    assert body["agency"]["services"] == ["VIP", "Wifi"]
    login(client, body["username"], body["password"])  # les identifiants générés fonctionnent

    assert client.post("/admin/agencies", headers=headers, json={"name": "general voyages"}).status_code == 409
