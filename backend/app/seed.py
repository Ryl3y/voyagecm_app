"""Crée les tables et insère les données de démonstration.

Usage : python -m app.seed
Le script est idempotent : il ne fait rien si des villes existent déjà.
"""

from datetime import time

from sqlalchemy import select

from app.config import settings
from app.database import Base, SessionLocal, engine
from app.models import Agency, City, Role, Trip, TripClass, User
from app.security import hash_password

CITIES = [
    "Yaoundé", "Douala", "Bafoussam", "Bamenda", "Ngaoundéré", "Garoua",
    "Maroua", "Bertoua", "Ebolowa", "Kribi", "Buea", "Limbe", "Dschang",
    "Foumban", "Kumba", "Nkongsamba", "Banyo",
]

# (nom, logo, services, couleur de l'image, description)
AGENCIES = [
    ("Touristique Express", "🚌", ["VIP", "Climatisé", "Toilettes"], "059669/FFFFFF", "Yaoundé - Douala, bus climatisés, respect des horaires."),
    ("Buca Voyages", "🚍", ["Rénové", "Départs réguliers"], "10B981/FFFFFF", "Douala - Yaoundé, bus rénovés, départs réguliers."),
    ("Amour Mezam Express", "🚐", ["Passagers", "Colis", "Confort"], "065F46/FFFFFF", "Ouest et Nord-Ouest, transport de passagers et colis."),
    ("MEN TRAVEL", "🚎", ["Confort", "Rapide"], "047857/FFFFFF", "Yaoundé - Kribi, ligne confort."),
    ("GARANTI Express", "🛡️", ["Passagers", "Marchandises", "Sécurité"], "6EE7B7/000000", None),
    ("Danay Express", "🌟", ["VIP", "Ponctuel"], "34D399/000000", None),
    ("Fako Express", "🏞️", ["Confort", "Paysages"], "A7F3D0/000000", None),
    ("Nord Voyages", "🐫", ["Fiable", "Longue distance"], "D1FAE5/000000", None),
    ("Est Transit", "🌳", ["Économique", "Flexibilité"], "ECFDF5/000000", None),
    ("Sud Confort", "🌴", ["Climatisé", "Direct"], "CCFBF1/000000", None),
]

# (code, départ, arrivée, n° agence, heure départ, heure arrivée, prix XAF, classe)
TRIPS = [
    ("R001", "Yaoundé", "Douala", 1, "08:00", "12:00", 6500, "VIP"),
    ("R002", "Yaoundé", "Douala", 1, "10:00", "14:00", 6000, "Classique"),
    ("R003", "Yaoundé", "Douala", 2, "09:00", "13:00", 6200, "Confort"),
    ("R004", "Douala", "Yaoundé", 1, "14:00", "18:00", 6500, "VIP"),
    ("R005", "Douala", "Yaoundé", 2, "15:00", "19:00", 6000, "Confort"),
    ("R006", "Yaoundé", "Bafoussam", 3, "07:00", "11:30", 5000, "Classique"),
    ("R007", "Bafoussam", "Yaoundé", 3, "13:00", "17:30", 5000, "Classique"),
    ("R008", "Yaoundé", "Dschang", 3, "09:00", "14:00", 5500, "Confort"),
    ("R009", "Bafoussam", "Douala", 5, "09:30", "14:00", 5500, "Classique"),
    ("R010", "Dschang", "Douala", 5, "10:00", "15:00", 5800, "Classique"),
    ("R011", "Yaoundé", "Kribi", 4, "11:00", "15:00", 7000, "Confort"),
    ("R012", "Kribi", "Yaoundé", 4, "16:00", "20:00", 7000, "Confort"),
    ("R013", "Yaoundé", "Ebolowa", 10, "07:30", "10:30", 4000, "Classique"),
    ("R014", "Douala", "Buea", 7, "06:00", "08:30", 3500, "Classique"),
    ("R015", "Douala", "Limbe", 7, "07:00", "09:00", 3000, "Classique"),
    ("R016", "Bamenda", "Bafoussam", 3, "09:00", "12:00", 4500, "Classique"),
    ("R017", "Ngaoundéré", "Garoua", 8, "08:00", "13:00", 8000, "Confort"),
    ("R018", "Garoua", "Maroua", 6, "14:00", "17:00", 5000, "Classique"),
    ("R019", "Yaoundé", "Bertoua", 9, "07:00", "12:00", 6000, "Classique"),
    ("R020", "Bertoua", "Yaoundé", 9, "13:00", "18:00", 6000, "Classique"),
    ("R021", "Douala", "Bamenda", 3, "06:30", "13:00", 8000, "VIP"),
    ("R022", "Bamenda", "Douala", 3, "07:00", "13:30", 8000, "VIP"),
    ("R023", "Yaoundé", "Ngaoundéré", 8, "18:00", "06:00", 12000, "VIP"),
    ("R024", "Ngaoundéré", "Yaoundé", 8, "18:30", "06:30", 12000, "VIP"),
    ("R025", "Maroua", "Garoua", 6, "09:00", "12:00", 5000, "Classique"),
    ("R026", "Garoua", "Maroua", 6, "10:00", "13:00", 5000, "Classique"),
    ("R027", "Kumba", "Douala", 7, "08:00", "11:00", 4000, "Classique"),
    ("R028", "Douala", "Kumba", 7, "13:00", "16:00", 4000, "Classique"),
    ("R029", "Bafoussam", "Foumban", 3, "10:00", "11:30", 2500, "Classique"),
    ("R030", "Foumban", "Bafoussam", 3, "14:00", "15:30", 2500, "Classique"),
    ("R031", "Yaoundé", "Douala", 1, "16:00", "20:00", 7500, "Zoom"),
]


def _t(value: str) -> time:
    hours, minutes = value.split(":")
    return time(int(hours), int(minutes))


def seed() -> None:
    Base.metadata.create_all(bind=engine)
    with SessionLocal() as db:
        if db.scalar(select(City.id).limit(1)):
            print("Base déjà initialisée, rien à faire.")
            return

        cities = {name: City(name=name) for name in CITIES}
        db.add_all(cities.values())

        agencies = []
        for name, logo, services, colors, description in AGENCIES:
            agencies.append(
                Agency(
                    name=name,
                    logo=logo,
                    verified=True,
                    services=services,
                    image_url=f"https://placehold.co/300x160/{colors}/png?text={name.replace(' ', '+')}",
                    description=description,
                )
            )
        db.add_all(agencies)
        db.flush()

        for code, dep, arr, agency_no, t_dep, t_arr, price, klass in TRIPS:
            trip_class = TripClass(klass)
            db.add(
                Trip(
                    code=code,
                    agency_id=agencies[agency_no - 1].id,
                    departure_city_id=cities[dep].id,
                    arrival_city_id=cities[arr].id,
                    departure_time=_t(t_dep),
                    arrival_time=_t(t_arr),
                    price=price,
                    trip_class=trip_class,
                    capacity=trip_class.capacity,
                )
            )

        db.add(User(username=settings.admin_username, password_hash=hash_password(settings.admin_password), role=Role.ADMIN))
        agency_hash = hash_password(settings.seed_agency_password)
        for index, agency in enumerate(agencies, start=1):
            db.add(User(username=f"agency{index}", password_hash=agency_hash, role=Role.AGENCY, agency_id=agency.id))

        db.commit()
        print(f"OK : {len(CITIES)} villes, {len(AGENCIES)} agences, {len(TRIPS)} trajets, {len(AGENCIES) + 1} comptes.")


if __name__ == "__main__":
    seed()
