import re
from datetime import date, datetime, time

from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator

from app.models import PaymentMethod, Role, TripClass

PHONE_RE = re.compile(r"^(\+?237)?[26]\d{8}$")
CNI_RE = re.compile(r"^[A-Za-z0-9]{6,20}$")

SAME_CITY_MESSAGE = "La ville de départ et la ville d'arrivée ne peuvent pas être identiques."


class ORMModel(BaseModel):
    model_config = ConfigDict(from_attributes=True)


# --- Auth ---------------------------------------------------------------

class LoginIn(BaseModel):
    username: str = Field(min_length=1, max_length=60)
    password: str = Field(min_length=1, max_length=128)


class Me(BaseModel):
    username: str
    role: Role
    agency_id: int | None
    agency_name: str | None


class TokenOut(Me):
    access_token: str
    token_type: str = "bearer"


# --- Référentiel ----------------------------------------------------------

class CityOut(ORMModel):
    id: int
    name: str


class AgencyOut(ORMModel):
    id: int
    name: str
    logo: str
    verified: bool
    services: list[str]
    image_url: str | None
    description: str | None


class AgencyCreate(BaseModel):
    name: str = Field(min_length=2, max_length=120)
    logo: str = Field(default="🚌", max_length=16)
    verified: bool = False
    services: list[str] = Field(default_factory=list)
    image_url: str | None = Field(default=None, max_length=500)
    description: str | None = Field(default=None, max_length=300)

    @field_validator("services")
    @classmethod
    def clean_services(cls, v: list[str]) -> list[str]:
        return [s.strip() for s in v if s.strip()]

    @field_validator("image_url")
    @classmethod
    def http_url_only(cls, v: str | None) -> str | None:
        if v and not v.startswith(("http://", "https://")):
            raise ValueError("L'URL de l'image doit commencer par http:// ou https://")
        return v or None


class AgencyCreated(BaseModel):
    agency: AgencyOut
    username: str
    password: str  # affiché une seule fois à l'administrateur


# --- Trajets ---------------------------------------------------------------

class TripOut(BaseModel):
    id: int
    code: str | None
    agency: AgencyOut
    departure_city: str
    arrival_city: str
    departure_time: time
    arrival_time: time
    price: int
    trip_class: TripClass
    capacity: int
    active: bool


class TripSearchResult(TripOut):
    travel_date: date
    available_seats: int


class TripCreate(BaseModel):
    departure_city_id: int
    arrival_city_id: int
    departure_time: time
    arrival_time: time
    price: int = Field(gt=0)
    trip_class: TripClass = TripClass.CLASSIQUE

    @model_validator(mode="after")
    def distinct_cities(self):
        if self.departure_city_id == self.arrival_city_id:
            raise ValueError(SAME_CITY_MESSAGE)
        return self


class TripUpdate(BaseModel):
    departure_city_id: int | None = None
    arrival_city_id: int | None = None
    departure_time: time | None = None
    arrival_time: time | None = None
    price: int | None = Field(default=None, gt=0)
    trip_class: TripClass | None = None


class SeatMap(BaseModel):
    trip_id: int
    travel_date: date
    capacity: int
    occupied: list[int]


# --- Réservations ----------------------------------------------------------

class BookingCreate(BaseModel):
    trip_id: int
    travel_date: date
    seat_number: int = Field(ge=1)
    passenger_name: str = Field(min_length=2, max_length=120)
    passenger_cni: str
    passenger_phone: str
    payment_method: PaymentMethod

    @field_validator("passenger_name")
    @classmethod
    def strip_name(cls, v: str) -> str:
        v = " ".join(v.split())
        if len(v) < 2:
            raise ValueError("Veuillez entrer le nom complet du passager.")
        return v

    @field_validator("passenger_cni")
    @classmethod
    def check_cni(cls, v: str) -> str:
        v = v.strip().upper()
        if not CNI_RE.match(v):
            raise ValueError("Numéro de CNI invalide (6 à 20 lettres ou chiffres).")
        return v

    @field_validator("passenger_phone")
    @classmethod
    def check_phone(cls, v: str) -> str:
        v = re.sub(r"[\s.-]", "", v)
        if not PHONE_RE.match(v):
            raise ValueError("Numéro de téléphone camerounais invalide (ex : 6XXXXXXXX).")
        return v


class BookingOut(BaseModel):
    code: str
    trip: TripOut
    travel_date: date
    seat_number: int
    passenger_name: str
    passenger_cni_masked: str
    passenger_phone: str
    payment_method: PaymentMethod
    amount: int
    created_at: datetime


class PassengerOut(BaseModel):
    code: str
    seat_number: int
    passenger_name: str
    passenger_phone: str
    payment_method: PaymentMethod


# --- Administration --------------------------------------------------------

class AdminStats(BaseModel):
    total_trips: int
    total_agencies: int
    bookings_today: int
    available_seats_today: int
    revenue_today: int
