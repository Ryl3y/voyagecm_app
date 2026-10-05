"""Espace administrateur : vue d'ensemble, tous les trajets, ajout d'agences."""

import secrets

from fastapi import APIRouter, HTTPException, status
from sqlalchemy import func, select

from app.deps import AdminUser, DbSession
from app.models import Agency, Booking, Role, Trip, User
from app.schemas import AdminStats, AgencyCreate, AgencyCreated, AgencyOut, TripOut
from app.security import hash_password
from app.services import today_cameroon, trip_query, trip_to_out

router = APIRouter(prefix="/admin", tags=["admin"])


@router.get("/stats", response_model=AdminStats)
def stats(_: AdminUser, db: DbSession):
    today = today_cameroon()
    total_capacity = db.scalar(select(func.coalesce(func.sum(Trip.capacity), 0)).where(Trip.active.is_(True)))
    bookings_today, revenue_today = db.execute(
        select(func.count(Booking.id), func.coalesce(func.sum(Booking.amount), 0))
        .join(Trip)
        .where(Booking.travel_date == today, Trip.active.is_(True))
    ).one()
    return AdminStats(
        total_trips=db.scalar(select(func.count()).select_from(Trip).where(Trip.active.is_(True))),
        total_agencies=db.scalar(select(func.count()).select_from(Agency)),
        bookings_today=bookings_today,
        available_seats_today=total_capacity - bookings_today,
        revenue_today=revenue_today,
    )


@router.get("/trips", response_model=list[TripOut])
def all_trips(_: AdminUser, db: DbSession):
    trips = db.scalars(trip_query().where(Trip.active.is_(True)).order_by(Trip.id)).unique()
    return [trip_to_out(t) for t in trips]


@router.post("/agencies", response_model=AgencyCreated, status_code=status.HTTP_201_CREATED)
def add_agency(data: AgencyCreate, _: AdminUser, db: DbSession):
    if db.scalar(select(Agency.id).where(func.lower(Agency.name) == data.name.strip().lower())):
        raise HTTPException(status.HTTP_409_CONFLICT, "Une agence porte déjà ce nom.")
    agency = Agency(**{**data.model_dump(), "name": data.name.strip()})
    db.add(agency)
    db.flush()

    username = f"agency{agency.id}"
    while db.scalar(select(User.id).where(User.username == username)):
        username = f"agency{agency.id}-{secrets.token_hex(2)}"
    password = secrets.token_urlsafe(9)
    db.add(User(username=username, password_hash=hash_password(password), role=Role.AGENCY, agency_id=agency.id))
    db.commit()
    return AgencyCreated(agency=AgencyOut.model_validate(agency), username=username, password=password)
