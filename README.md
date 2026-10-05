# VoyageCM

Application mobile de réservation de billets de bus interurbains au Cameroun.

- **mobile/** : application Flutter (Android et iOS)
- **backend/** : API Python (FastAPI + SQLAlchemy)
- **PostgreSQL** : base de données

## Fonctionnalités

**Voyageur** (sans compte)
- Rechercher un trajet : ville de départ, ville d'arrivée, date (jusqu'à 90 jours à l'avance).
- Voir les agences, horaires, classes (Classique, Confort avec toilettes, VIP climatisé, Zoom 50 places), prix et places libres.
- Choisir son siège sur le plan du bus, saisir nom, CNI et téléphone, choisir MTN MoMo ou Orange Money (**paiement simulé**).
- Recevoir un code `CM-123456-S12` et retrouver son billet avec ce code (onglet « Mon billet »).

**Agence** (onglet « Espace pro »)
- Voir, ajouter, modifier et supprimer ses trajets.
- Voir la liste des passagers d'un trajet pour une date.

**Administrateur**
- Vue d'ensemble : trajets, agences, réservations, places libres et recettes du jour.
- Liste de tous les trajets, ajout d'agences (identifiants générés et affichés une seule fois).

### Règles métier
- Un trajet est un départ **quotidien**. Les sièges sont réservés **par date** : le siège 12 du lundi est indépendant du siège 12 du mardi.
- Un siège ne peut pas être vendu deux fois : c'est garanti par une contrainte unique en base, même si deux personnes réservent au même moment.
- Impossible de réserver une date passée ou un bus déjà parti (heure du Cameroun).
- Capacité : 50 places en classe Zoom, 70 sinon.

## Démarrage rapide

Prérequis : Python 3.12 ou plus récent, PostgreSQL (16 ou plus récent), Flutter.

### 1. Base de données

Avec le compte `postgres` (le mot de passe choisi à l'installation de PostgreSQL) :

```bash
psql -U postgres -c "CREATE USER voyagecm_app WITH PASSWORD 'choisir-un-mot-de-passe';"
psql -U postgres -c "CREATE DATABASE voyagecm OWNER voyagecm_app;"
psql -U postgres -c "CREATE DATABASE voyagecm_test OWNER voyagecm_app;"   # pour les tests
```

> Sous Windows, `psql` se trouve dans `C:\Program Files\PostgreSQL\17\bin\`.

### 2. API

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate          # Windows  (Linux/macOS : source .venv/bin/activate)
pip install -r requirements-dev.txt
cp .env.example .env            # puis modifier JWT_SECRET et les mots de passe
python -m app.seed              # tables + données de démonstration
uvicorn app.main:app --reload --host 0.0.0.0
```

L'API tourne sur http://localhost:8000. La documentation interactive est sur http://localhost:8000/docs.
`python -m app.seed` crée les données de démonstration : 17 villes, 10 agences, 31 trajets, un compte `admin` et les comptes `agency1` à `agency10`. Leurs mots de passe sont ceux définis dans `.env`.

### 3. Application mobile

```bash
cd mobile
flutter pub get
flutter run                                            # émulateur Android : API sur 10.0.2.2:8000
flutter run --dart-define=API_URL=http://localhost:8000      # simulateur iOS
flutter run --dart-define=API_URL=http://192.168.1.20:8000   # téléphone réel : IP du PC sur le Wi-Fi
```

## Tests

```bash
# Backend : utilise la base voyagecm_test (vidée à chaque test, ne pas y mettre de vraies données)
cd backend
pytest      # lit TEST_DATABASE_URL dans backend/.env
# Autre base : définir TEST_DATABASE_URL, par ex. sous PowerShell :
#   $env:TEST_DATABASE_URL="postgresql+psycopg://voyagecm:motdepasse@localhost:5432/voyagecm_test"; pytest

# Mobile
cd mobile
flutter analyze
flutter test
```

## API (résumé)

| Méthode | Route | Accès |
|---|---|---|
| GET | `/cities`, `/agencies` | public |
| GET | `/trips/search?departure_city_id=&arrival_city_id=&travel_date=` | public |
| GET | `/trips/{id}/seats?travel_date=` | public |
| POST | `/bookings` · GET `/bookings/{code}` | public |
| POST | `/auth/login` · GET `/auth/me` | — |
| GET/POST/PUT/DELETE | `/agency/trips…`, `/agency/trips/{id}/passengers` | agence |
| GET | `/admin/stats`, `/admin/trips` · POST `/admin/agencies` | admin |

## Avant une mise en production
- Servir l'API en **HTTPS** et définir `API_URL` en `https://…` au build (`flutter build apk --dart-define=API_URL=…`).
- Mettre un `JWT_SECRET` long et aléatoire, changer tous les mots de passe de démonstration et restreindre `CORS_ORIGINS`.
- Intégrer les vraies API de paiement MTN MoMo / Orange Money. Aujourd'hui le paiement est simulé.
- Le numéro de CNI est une donnée personnelle : il faut une politique de confidentialité, une durée de conservation et le respect de la réglementation camerounaise sur les données personnelles.
- Remplacer `create_all` par des migrations (Alembic) dès que le schéma évolue.
