import enum
from datetime import date, datetime, time

from sqlalchemy import (
    Boolean,
    CheckConstraint,
    Date,
    DateTime,
    Enum,
    ForeignKey,
    Integer,
    String,
    Time,
    UniqueConstraint,
    func,
)
from sqlalchemy.dialects.postgresql import ARRAY
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


def _enum_values(enum_cls: type[enum.Enum]) -> list[str]:
    return [member.value for member in enum_cls]


class Role(str, enum.Enum):
    ADMIN = "admin"
    AGENCY = "agency"


class TripClass(str, enum.Enum):
    CLASSIQUE = "Classique"
    CONFORT = "Confort"  # avec toilettes
    VIP = "VIP"  # climatisé
    ZOOM = "Zoom"  # bus de 50 places

    @property
    def capacity(self) -> int:
        return 50 if self is TripClass.ZOOM else 70


class PaymentMethod(str, enum.Enum):
    MTN = "mtn"
    ORANGE = "orange"


class City(Base):
    __tablename__ = "cities"

    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(80), unique=True)


class Agency(Base):
    __tablename__ = "agencies"

    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(120), unique=True)
    logo: Mapped[str] = mapped_column(String(16), default="🚌")
    verified: Mapped[bool] = mapped_column(Boolean, default=False)
    services: Mapped[list[str]] = mapped_column(ARRAY(String(60)), default=list)
    image_url: Mapped[str | None] = mapped_column(String(500))
    description: Mapped[str | None] = mapped_column(String(300))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    trips: Mapped[list["Trip"]] = relationship(back_populates="agency")


class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(primary_key=True)
    username: Mapped[str] = mapped_column(String(60), unique=True)
    password_hash: Mapped[str] = mapped_column(String(100))
    role: Mapped[Role] = mapped_column(Enum(Role, name="user_role", values_callable=_enum_values))
    agency_id: Mapped[int | None] = mapped_column(ForeignKey("agencies.id", ondelete="CASCADE"))

    agency: Mapped[Agency | None] = relationship()


class Trip(Base):
    """Un départ régulier (tous les jours) proposé par une agence."""

    __tablename__ = "trips"
    __table_args__ = (
        CheckConstraint("departure_city_id <> arrival_city_id", name="ck_trip_distinct_cities"),
        CheckConstraint("price > 0", name="ck_trip_price_positive"),
    )

    id: Mapped[int] = mapped_column(primary_key=True)
    code: Mapped[str | None] = mapped_column(String(20), unique=True)
    agency_id: Mapped[int] = mapped_column(ForeignKey("agencies.id", ondelete="CASCADE"), index=True)
    departure_city_id: Mapped[int] = mapped_column(ForeignKey("cities.id"))
    arrival_city_id: Mapped[int] = mapped_column(ForeignKey("cities.id"))
    departure_time: Mapped[time] = mapped_column(Time)
    arrival_time: Mapped[time] = mapped_column(Time)
    price: Mapped[int] = mapped_column(Integer)  # en XAF
    trip_class: Mapped[TripClass] = mapped_column(
        Enum(TripClass, name="trip_class", values_callable=_enum_values)
    )
    capacity: Mapped[int] = mapped_column(Integer)
    active: Mapped[bool] = mapped_column(Boolean, default=True)

    agency: Mapped[Agency] = relationship(back_populates="trips")
    departure_city: Mapped[City] = relationship(foreign_keys=[departure_city_id])
    arrival_city: Mapped[City] = relationship(foreign_keys=[arrival_city_id])


class Booking(Base):
    """Réservation d'un siège sur un trajet, pour une date donnée."""

    __tablename__ = "bookings"
    __table_args__ = (
        # Garantie en base qu'un siège ne peut être vendu deux fois pour le même départ.
        UniqueConstraint("trip_id", "travel_date", "seat_number", name="uq_booking_seat"),
    )

    id: Mapped[int] = mapped_column(primary_key=True)
    code: Mapped[str] = mapped_column(String(20), unique=True)
    trip_id: Mapped[int] = mapped_column(ForeignKey("trips.id", ondelete="CASCADE"), index=True)
    travel_date: Mapped[date] = mapped_column(Date, index=True)
    seat_number: Mapped[int] = mapped_column(Integer)
    passenger_name: Mapped[str] = mapped_column(String(120))
    passenger_cni: Mapped[str] = mapped_column(String(30))
    passenger_phone: Mapped[str] = mapped_column(String(20))
    payment_method: Mapped[PaymentMethod] = mapped_column(
        Enum(PaymentMethod, name="payment_method", values_callable=_enum_values)
    )
    amount: Mapped[int] = mapped_column(Integer)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    trip: Mapped[Trip] = relationship()
