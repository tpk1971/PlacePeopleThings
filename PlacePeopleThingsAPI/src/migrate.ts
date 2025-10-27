// Migration runner: apply versioned SQL migration files from ../migrations
import dotenv from 'dotenv';
import { Client } from 'pg';
import fs from 'fs';
import path from 'path';

dotenv.config();

const connectionString = process.env.DATABASE_URL;
if (!connectionString) {
  console.warn('No DATABASE_URL provided — migration will attempt to connect to DB via default env.');
}

const maxAttempts = Number(process.env.DB_MIGRATE_MAX_ATTEMPTS || 30);
const delayMs = Number(process.env.DB_MIGRATE_DELAY_MS || 1000);

async function sleep(ms: number) {
  return new Promise((res) => setTimeout(res, ms));
}

function migrationsDir(): string {
  // When compiled to dist, __dirname is dist; migrations folder is at ../migrations
  return path.resolve(__dirname, '../migrations');
}

async function ensureMigrationsTable(client: Client) {
  const sql = `
    CREATE TABLE IF NOT EXISTS migrations (
      id SERIAL PRIMARY KEY,
      name TEXT NOT NULL UNIQUE,
      applied_at TIMESTAMPTZ NOT NULL DEFAULT now()
    );
  `;
  await client.query(sql);
}

async function getAppliedMigrations(client: Client): Promise<Set<string>> {
  const res = await client.query('SELECT name FROM migrations');
  return new Set(res.rows.map((r: any) => r.name));
}

async function applyMigration(client: Client, name: string, sql: string) {
  // Run inside a transaction
  await client.query('BEGIN');
  try {
    await client.query(sql);
    await client.query('INSERT INTO migrations (name) VALUES ($1)', [name]);
    await client.query('COMMIT');
    console.log(`Applied migration: ${name}`);
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  }
}

async function runMigrations() {
  let attempts = 0;
  while (true) {
    attempts++;
    let client: Client | null = null;
    try {
      client = new Client({ connectionString, ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : undefined });
      await client.connect();

      // Ensure migrations table exists
      await ensureMigrationsTable(client);

      const applied = await getAppliedMigrations(client);

      const dir = migrationsDir();
      if (!fs.existsSync(dir)) {
        console.log(`Migrations directory not found: ${dir} — nothing to apply.`);
        await client.end();
        return 0;
      }

      const files = fs.readdirSync(dir).filter((f) => f.endsWith('.sql')).sort();
      const toApply = files.filter((f) => !applied.has(f));

      if (toApply.length === 0) {
        console.log('No new migrations to apply.');
        await client.end();
        return 0;
      }

      for (const file of toApply) {
        const fullPath = path.join(dir, file);
        const sql = fs.readFileSync(fullPath, 'utf8');
        console.log(`Applying migration ${file}...`);
        await applyMigration(client, file, sql);
      }

      await client.end();
      console.log('All migrations applied successfully.');
      return 0;
    } catch (err) {
      console.warn(`Migration attempt ${attempts} failed: ${err}`);
      if (client) {
        try { await client.end(); } catch (_) {}
      }
      if (attempts >= maxAttempts) {
        console.error('Max migration attempts reached — aborting.');
        return 2;
      }
      await sleep(delayMs);
    }
  }
}

runMigrations().then((code) => process.exit(code)).catch((e) => { console.error(e); process.exit(3); });
