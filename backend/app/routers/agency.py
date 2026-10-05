"""Espace agence : gestion de ses propres trajets et liste des passagers."""

from datetime import date

from fastapi import APIRouter, HTTPException, Query, status
from sqlalchemy import select

from app.deps import AgencyUser, DbSession
from app.models import Booking, Trip
from app.schemas import PassengerOut, TripCreate, TripOut, TripUpdate
from app.services import ensure_distinct_cities, get_city_or_400, trip_query, trip_to_out

router = APIRouter(prefix="/agency", tags=["agency"])


def _own_trip(db, user, trip_id: int) -> Trip:
    trip = db.scalars(trip_query().where(Trip.id == trip_id)).unique().first()
    if trip is None or trip.agency_id != user.agency_id or not trip.active:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Trajet non trouvé.")
    return trip


@router.get("/trips", response_model=list[TripOut])
def my_trips(user: AgencyUser, db: DbSession):
    trips = db.scalars(
        trip_query()
        .where(Trip.agency_id == user.agency_id, Trip.active.is_(True))
        .order_by(Trip.departure_time)
    ).unique()
    return [trip_to_out(t) for t in trips]


@router.post("/trips", response_model=TripOut, status_code=status.HTTP_201_CREATED)
def add_trip(data: TripCreate, user: AgencyUser, db: DbSession):
    get_city_or_400(db, data.departure_city_id)
    get_city_or_400(db, data.arrival_city_id)
    trip = Trip(
        agency_id=user.agency_id,
        **data.model_dump(),
        capacity=data.trip_class.capacity,
    )
    db.add(trip)
    db.flush()
    trip.code = f"R{trip.id:03d}"
    db.commit()
    return trip_to_out(_own_trip(db, user, trip.id))


@router.put("/trips/{trip_id}", response_model=TripOut)
def update_trip(trip_id: int, data: TripUpdate, user: AgencyUser, db: DbSession):
    trip = _own_trip(db, user, trip_id)
    changes = data.model_dump(exclude_unset=True, exclude_none=True)
    dep = changes.get("departure_city_id", trip.departure_city_id)
    arr = changes.get("arrival_city_id", trip.arrival_city_id)
    ensure_distinct_cities(dep, arr)
    for city_id in {dep, arr}:
        get_city_or_400(db, city_id)
    if "trip_class" in changes and changes["trip_class"].capacity < trip.capacity:
        # Passer en Zoom (50 places) n'est possible que si aucun siège > 50 n'est vendu.
        too_high = db.scalar(
            select(Booking.id).where(
                Booking.trip_id == trip.id, Booking.seat_number > changes["trip_class"].capacity
            )
        )
        if too_high:
            raise HTTPException(
                status.HTTP_409_CONFLICT,
                "Des sièges au-delà de 50 sont déjà réservés : impossible de passer en classe Zoom.",
            )
    for field, value in changes.items():
        setattr(trip, field, value)
    if "trip_class" in changes:
        trip.capacity = trip.trip_class.capacity
    db.commit()
    db.expire_all()
    return trip_to_out(_own_trip(db, user, trip.id))


@router.delete("/trips/{trip_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_trip(trip_id: int, user: AgencyUser, db: DbSession):
    # Suppression logique : les réservations existantes restent consultables.
    trip = _own_trip(db, user, trip_id)
    trip.active = False
    db.commit()


@router.get("/trips/{trip_id}/passengers", response_model=list[PassengerOut])
def passengers(trip_id: int, user: AgencyUser, db: DbSession, travel_date: date = Query(...)):
    trip = _own_trip(db, user, trip_id)
    bookings = db.scalars(
        select(Booking)
        .where(Booking.trip_id == trip.id, Booking.travel_date == travel_date)
        .order_by(Booking.seat_number)
    )
    return [PassengerOut.model_validate(b, from_attributes=True) for b in bookings]
