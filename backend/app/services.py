"""Règles métier partagées entre les routes."""

import secrets
from datetime import date, datetime

from fastapi import HTTPException, status
from sqlalchemy import func, select
from sqlalchemy.orm import Session, joinedload

from app.config import CAMEROON_TZ
from app.models import Booking, City, Trip
from app.schemas import SAME_CITY_MESSAGE, AgencyOut, BookingOut, TripOut


def now_cameroon() -> datetime:
    return datetime.now(CAMEROON_TZ)


def today_cameroon() -> date:
    return now_cameroon().date()


def trip_query():
    return select(Trip).options(
        joinedload(Trip.agency), joinedload(Trip.departure_city), joinedload(Trip.arrival_city)
    )


def trip_to_out(trip: Trip) -> TripOut:
    return TripOut(
        id=trip.id,
        code=trip.code,
        agency=AgencyOut.model_validate(trip.agency),
        departure_city=trip.departure_city.name,
        arrival_city=trip.arrival_city.name,
        departure_time=trip.departure_time,
        arrival_time=trip.arrival_time,
        price=trip.price,
        trip_class=trip.trip_class,
        capacity=trip.capacity,
        active=trip.active,
    )


def booking_to_out(booking: Booking) -> BookingOut:
    cni = booking.passenger_cni
    return BookingOut(
        code=booking.code,
        trip=trip_to_out(booking.trip),
        travel_date=booking.travel_date,
        seat_number=booking.seat_number,
        passenger_name=booking.passenger_name,
        passenger_cni_masked="•" * max(len(cni) - 3, 0) + cni[-3:],
        passenger_phone=booking.passenger_phone,
        payment_method=booking.payment_method,
        amount=booking.amount,
        created_at=booking.created_at,
    )


def occupied_seats(db: Session, trip_id: int, travel_date: date) -> list[int]:
    rows = db.scalars(
        select(Booking.seat_number)
        .where(Booking.trip_id == trip_id, Booking.travel_date == travel_date)
        .order_by(Booking.seat_number)
    )
    return list(rows)


def booked_counts(db: Session, trip_ids: list[int], travel_date: date) -> dict[int, int]:
    if not trip_ids:
        return {}
    rows = db.execute(
        select(Booking.trip_id, func.count())
        .where(Booking.trip_id.in_(trip_ids), Booking.travel_date == travel_date)
        .group_by(Booking.trip_id)
    )
    return {trip_id: count for trip_id, count in rows}


def ensure_distinct_cities(departure_city_id: int, arrival_city_id: int) -> None:
    if departure_city_id == arrival_city_id:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, SAME_CITY_MESSAGE)


def ensure_not_past(travel_date: date) -> datetime:
    """Refuse les dates passées ; retourne l'heure actuelle au Cameroun."""
    now = now_cameroon()
    if travel_date < now.date():
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "La date de voyage est déjà passée.")
    return now


def ensure_bookable(trip: Trip, travel_date: date) -> None:
    """Refuse les dates passées et les départs du jour déjà partis."""
    now = ensure_not_past(travel_date)
    if travel_date == now.date() and trip.departure_time <= now.time().replace(tzinfo=None):
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Ce bus est déjà parti aujourd'hui.")


def get_city_or_400(db: Session, city_id: int) -> City:
    city = db.get(City, city_id)
    if city is None:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, f"Ville inconnue (id={city_id}).")
    return city


def new_booking_code(seat_number: int) -> str:
    return f"CM-{secrets.randbelow(1_000_000):06d}-S{seat_number}"
