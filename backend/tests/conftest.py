"""Les tests utilisent une vraie base PostgreSQL dédiée (elle est vidée à chaque test).

    TEST_DATABASE_URL=postgresql+psycopg://voyagecm:voyagecm@localhost:5432/voyagecm_test pytest
"""

import os
from pathlib import Path

import pytest
from dotenv import dotenv_values

TEST_DB = (
    os.environ.get("TEST_DATABASE_URL")
    or dotenv_values(Path(__file__).parent.parent / ".env").get("TEST_DATABASE_URL")
    or "postgresql+psycopg://voyagecm:voyagecm@localhost:5432/voyagecm_test"
)
os.environ["DATABASE_URL"] = TEST_DB
os.environ["JWT_SECRET"] = "test-secret-suffisamment-long-pour-hs256"
os.environ["ADMIN_PASSWORD"] = "admin-test"
os.environ["SEED_AGENCY_PASSWORD"] = "agency-test"

from fastapi.testclient import TestClient  # noqa: E402
from sqlalchemy.exc import OperationalError  # noqa: E402

from app.database import Base, engine  # noqa: E402
from app.main import app  # noqa: E402
from app.seed import seed  # noqa: E402


@pytest.fixture()
def client():
    try:
        Base.metadata.drop_all(bind=engine)
    except OperationalError as exc:
        pytest.skip(f"PostgreSQL de test indisponible : {exc.orig}")
    seed()
    with TestClient(app) as test_client:
        yield test_client


def login(client, username: str, password: str) -> dict[str, str]:
    response = client.post("/auth/login", json={"username": username, "password": password})
    assert response.status_code == 200, response.text
    return {"Authorization": f"Bearer {response.json()['access_token']}"}
