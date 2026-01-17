const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const mysql = require('mysql2/promise');
const { v4: uuidv4 } = require('uuid');
require('dotenv').config();

const app = express();

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.static('public'));

// MySQL Connection Pool
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASS || '',
  database: process.env.DB_NAME || 'notesdb',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Initialize Database
async function initDatabase() {
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASS || ''
  });

  try {
    await connection.query(`CREATE DATABASE IF NOT EXISTS notesdb`);
    await connection.query(`USE notesdb`);
    
    await connection.query(`
      CREATE TABLE IF NOT EXISTS notes (
        id VARCHAR(36) PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        content LONGTEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
      )
    `);
    
    console.log('✅ Database initialized successfully');
  } catch (error) {
    console.error('❌ Database error:', error.message);
  } finally {
    await connection.end();
  }
}

// Routes

// Get all notes
app.get('/api/notes', async (req, res) => {
  try {
    const connection = await pool.getConnection();
    const [notes] = await connection.query(
      'SELECT * FROM notes ORDER BY updated_at DESC'
    );
    connection.release();
    res.json(notes);
  } catch (error) {
    console.error('Error fetching notes:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get single note
app.get('/api/notes/:id', async (req, res) => {
  try {
    const connection = await pool.getConnection();
    const [notes] = await connection.query(
      'SELECT * FROM notes WHERE id = ?',
      [req.params.id]
    );
    connection.release();
    
    if (notes.length === 0) {
      return res.status(404).json({ error: 'Note not found' });
    }
    res.json(notes[0]);
  } catch (error) {
    console.error('Error fetching note:', error);
    res.status(500).json({ error: error.message });
  }
});

// Create note
app.post('/api/notes', async (req, res) => {
  const { title, content } = req.body;
  
  if (!title || !content) {
    return res.status(400).json({ error: 'Title and content are required' });
  }

  const id = uuidv4();
  
  try {
    const connection = await pool.getConnection();
    await connection.query(
      'INSERT INTO notes (id, title, content) VALUES (?, ?, ?)',
      [id, title, content]
    );
    connection.release();
    
    res.status(201).json({ id, title, content, message: '✅ Note created successfully' });
  } catch (error) {
    console.error('Error creating note:', error);
    res.status(500).json({ error: error.message });
  }
});

// Update note
app.put('/api/notes/:id', async (req, res) => {
  const { title, content } = req.body;
  
  if (!title || !content) {
    return res.status(400).json({ error: 'Title and content are required' });
  }

  try {
    const connection = await pool.getConnection();
    const [result] = await connection.query(
      'UPDATE notes SET title = ?, content = ? WHERE id = ?',
      [title, content, req.params.id]
    );
    connection.release();
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Note not found' });
    }
    
    res.json({ message: '✅ Note updated successfully' });
  } catch (error) {
    console.error('Error updating note:', error);
    res.status(500).json({ error: error.message });
  }
});

// Delete note
app.delete('/api/notes/:id', async (req, res) => {
  try {
    const connection = await pool.getConnection();
    const [result] = await connection.query(
      'DELETE FROM notes WHERE id = ?',
      [req.params.id]
    );
    connection.release();
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Note not found' });
    }
    
    res.json({ message: '✅ Note deleted successfully' });
  } catch (error) {
    console.error('Error deleting note:', error);
    res.status(500).json({ error: error.message });
  }
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

// Start server
const PORT = process.env.PORT || 3000;

initDatabase().then(() => {
  app.listen(PORT, () => {
    console.log(`\n🚀 Notes App Server running on http://localhost:${PORT}`);
    console.log(`📝 API Documentation: http://localhost:${PORT}/\n`);
  });
});

module.exports = app;
