const express = require('express');
const { Client } = require('pg');

const app = express();
const PORT = process.env.PORT || 5000;

// CORS - Autoriser les requêtes du Frontend
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  if (req.method === 'OPTIONS') {
    return res.sendStatus(200);
  }
  next();
});

// Configuration de la base de données
const client = new Client({
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
  host: process.env.DB_HOST || 'postgres-service',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'appdb_devops'
});

// Connexion à la DB (avec retry)
const connectDB = () => {
  client.connect((err) => {
    if (err) {
      console.log(' Erreur DB, retry dans 5s...', err);
      setTimeout(connectDB, 5000);
    } else {
      console.log(' Connecté à PostgreSQL');
    }
  });
};
connectDB();

// Route de santé (pour Kubernetes)
app.get('/health', (req, res) => {
  res.json({ status: 'Backend OK ' });
});

// Route API - récupérer les utilisateurs
app.get('/api/users', async (req, res) => {
  try {
    const result = await client.query('SELECT * FROM users LIMIT 10');
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: 'Erreur DB', message: error.message });
  }
});

// Route API - ajouter un utilisateur
app.post('/api/users', express.json(), async (req, res) => {
  const { name, email } = req.body;
  try {
    const result = await client.query(
      'INSERT INTO users (name, email) VALUES ($1, $2) RETURNING *',
      [name, email]
    );
    res.json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(PORT, () => {
  console.log(` Backend démarré sur le port ${PORT}`);
});