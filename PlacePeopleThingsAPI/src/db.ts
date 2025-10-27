// Database connection wrapper using pg Pool
import { Pool } from 'pg';
import dotenv from 'dotenv';

dotenv.config();

const connectionString = process.env.DATABASE_URL;

let pool: Pool | null = null;

if (connectionString) {
  pool = new Pool({
    connectionString,
    ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : undefined,
  });
}

// Simple in-memory fallback to allow running the API without Postgres during development
// The rest of the code can import `db` and use `db.query` if a real pool exists, otherwise
// fall back to the in-memory implementation below.

const inMemoryData: { places: Array<{ id: number; name: string; description?: string | null }> } = {
  places: [],
};
let nextId = 1;

const db = pool
  ? (pool as Pool)
  : ({
      query: async (text: string, params?: any[]) => {
        // naive parsing for the simple queries used in the project
        if (text.toLowerCase().startsWith('select') && text.includes('from places')) {
          return { rows: inMemoryData.places.slice().reverse() };
        }
        if (text.toLowerCase().startsWith('insert') && text.includes('into places')) {
          const name = params && params[0];
          const description = params && params[1];
          const row = { id: nextId++, name, description };
          inMemoryData.places.push(row);
          return { rows: [row] };
        }
        // Fallback: return empty
        return { rows: [] };
      },
    } as unknown as Pool);

export default db;
