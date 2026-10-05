"""Routes publiques : référentiel, recherche de trajets et plan des sièges."""

from datetime import date

from fastapi import APIRouter, HTTPException, Query, status
from sqlalchemy import select

from app.deps import DbSession
from app.models import Agency, City, Trip
from app.schemas import AgencyOut, CityOut, SeatMap, TripSearchResult
from app.services import (
    booked_counts,
    ensure_bookable,
    ensure_distinct_cities,
    ensure_not_past,
    occupied_seats,
    trip_query,
    trip_to_out,
)

router = APIRouter(tags=["public"])


@router.get("/cities", response_model=list[CityOut])
def list_cities(db: DbSession):
    return db.scalars(select(City).order_by(City.name)).all()


@router.get("/agencies", response_model=list[AgencyOut])
def list_agencies(db: DbSession):
    return db.scalars(select(Agency).order_by(Agency.id)).all()


@router.get("/trips/search", response_model=list[TripSearchResult])
def search_trips(
    db: DbSession,
    departure_city_id: int = Query(...),
    arrival_city_id: int = Query(...),
    travel_date: date = Query(...),
):
    ensure_distinct_cities(departure_city_id, arrival_city_id)
    now = ensure_not_past(travel_date)

    query = trip_query().where(
        Trip.active.is_(True),
        Trip.departure_city_id == departure_city_id,
        Trip.arrival_city_id == arrival_city_id,
    )
    if travel_date == now.date():
        # Ne pas proposer les bus déjà partis.
        query = query.where(Trip.departure_time > now.time().replace(tzinfo=None))
    trips = db.scalars(query.order_by(Trip.departure_time)).unique().all()

    counts = booked_counts(db, [t.id for t in trips], travel_date)
    return [
        TripSearchResult(
            **trip_to_out(t).model_dump(),
            travel_date=travel_date,
            available_seats=t.capacity - counts.get(t.id, 0),
        )
        for t in trips
    ]


@router.get("/trips/{trip_id}/seats", response_model=SeatMap)
def seat_map(trip_id: int, db: DbSession, travel_date: date = Query(...)):
    trip = db.get(Trip, trip_id)
    if trip is None or not trip.active:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Trajet non trouvé.")
    ensure_bookable(trip, travel_date)
    return SeatMap(
        trip_id=trip.id,
        travel_date=travel_date,
        capacity=trip.capacity,
        occupied=occupied_seats(db, trip.id, travel_date),
    )
