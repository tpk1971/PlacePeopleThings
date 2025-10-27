import express from 'express';
import cors from 'cors';
import pool from './db';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3000;

app.get('/api/health', (_req, res) => {
  res.json({ status: 'ok', env: process.env.NODE_ENV || 'development' });
});

// Get list of places
app.get('/api/places', async (_req, res) => {
  try {
    const result = await pool.query('SELECT id, name, description FROM places ORDER BY id DESC LIMIT 100');
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching places:', err);
    res.status(500).json({ error: 'Database error' });
  }
});

// Create a new place
app.post('/api/places', async (req, res) => {
  const { name, description } = req.body;
  if (!name) return res.status(400).json({ error: 'name is required' });
  try {
    const result = await pool.query(
      'INSERT INTO places (name, description) VALUES ($1, $2) RETURNING id, name, description',
      [name, description || null]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error inserting place:', err);
    res.status(500).json({ error: 'Database error' });
  }
});

app.listen(PORT, () => {
  console.log(`PlacePeopleThingsAPI listening on http://localhost:${PORT}`);
});

