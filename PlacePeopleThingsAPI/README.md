PlacePeopleThingsAPI

Node + TypeScript + Express API for PlacePeopleThings

Setup

1. Install dependencies:

   npm install

2. Create a .env file in the project root (or use the .env.example) with at least the following:

   DATABASE_URL=postgres://user:password@localhost:5432/yourdb
   PORT=3000

3. Initialize DB (example schema):

   CREATE TABLE IF NOT EXISTS places (
     id SERIAL PRIMARY KEY,
     name TEXT NOT NULL,
     description TEXT
   );

Development

- Run in dev mode (auto-restart) — uses nodemon + ts-node:

  npm run dev

- Run with Node inspector (attach debugger) using the debug dev script:

  npm run dev:debug

Docker (Postgres + API)

This repository contains a Dockerfile and docker-compose.yaml to run Postgres and the API together for local testing.

1. Build and start services:

   docker-compose up --remove-orphans --build

2. The API will be available at http://localhost:3000 and Postgres at localhost:5432 with credentials from the compose file (postgres/postgres).

Notes

- nodemon config is provided in `nodemon.json` (ignores dist, node_modules, and .git).
- If you prefer to run without Postgres, set up an empty database or modify `src/db.ts` to switch to an in-memory fallback.
