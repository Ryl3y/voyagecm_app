from fastapi import APIRouter, HTTPException, status
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import joinedload

from app.deps import DbSession
from app.models import Booking, Trip
from app.schemas import BookingCreate, BookingOut
from app.services import booking_to_out, ensure_bookable, new_booking_code, occupied_seats

router = APIRouter(prefix="/bookings", tags=["bookings"])


def _seat_taken(db, trip: Trip, data: BookingCreate) -> HTTPException:
    taken = set(occupied_seats(db, trip.id, data.travel_date))
    free = [s for s in range(1, trip.capacity + 1) if s not in taken]
    if not free:
        return HTTPException(status.HTTP_409_CONFLICT, "Désolé, il n'y a plus de sièges disponibles pour ce trajet.")
    return HTTPException(
        status.HTTP_409_CONFLICT,
        f"Le siège {data.seat_number} est déjà pris. Sièges disponibles : {', '.join(map(str, free))}",
    )


@router.post("", response_model=BookingOut, status_code=status.HTTP_201_CREATED)
def create_booking(data: BookingCreate, db: DbSession):
    """Réserve un siège. Le paiement Mobile Money est simulé."""
    trip = db.get(Trip, data.trip_id)
    if trip is None or not trip.active:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Trajet non trouvé.")
    ensure_bookable(trip, data.travel_date)
    if data.seat_number > trip.capacity:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, f"Ce bus compte {trip.capacity} places.")
    if data.seat_number in occupied_seats(db, trip.id, data.travel_date):
        raise _seat_taken(db, trip, data)

    # La contrainte unique (trajet, date, siège) protège contre deux réservations simultanées ;
    # on réessaie seulement si c'est le code de réservation aléatoire qui est en collision.
    for _ in range(5):
        booking = Booking(
            code=new_booking_code(data.seat_number),
            trip_id=trip.id,
            travel_date=data.travel_date,
            seat_number=data.seat_number,
            passenger_name=data.passenger_name,
            passenger_cni=data.passenger_cni,
            passenger_phone=data.passenger_phone,
            payment_method=data.payment_method,
            amount=trip.price,
        )
        db.add(booking)
        try:
            db.commit()
        except IntegrityError:
            db.rollback()
            if data.seat_number in occupied_seats(db, trip.id, data.travel_date):
                raise _seat_taken(db, trip, data)
            continue
        return get_booking(booking.code, db)
    raise HTTPException(status.HTTP_503_SERVICE_UNAVAILABLE, "Réessayez dans un instant.")


@router.get("/{code}", response_model=BookingOut)
def get_booking(code: str, db: DbSession):
    booking = db.scalar(
        select(Booking)
        .where(Booking.code == code.strip().upper())
        .options(
            joinedload(Booking.trip).options(
                joinedload(Trip.agency), joinedload(Trip.departure_city), joinedload(Trip.arrival_city)
            )
        )
    )
    if booking is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Aucune réservation avec ce code.")
    return booking_to_out(booking)
