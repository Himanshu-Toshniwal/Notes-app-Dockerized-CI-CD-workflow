const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const sqlite3 = require('sqlite3').verbose();
const { v4: uuidv4 } = require('uuid');
require('dotenv').config();

const app = express();

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.static('public'));

// SQLite Database
const dbPath = process.env.DB_PATH || './notesdb.sqlite';
const db = new sqlite3.Database(dbPath);

// Initialize Database
function initDatabase() {
  return new Promise((resolve, reject) => {
    db.serialize(() => {
      db.run(`
        CREATE TABLE IF NOT EXISTS notes (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
          updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
      `, (err) => {
        if (err) {
          console.error('Database error:', err.message);
          reject(err);
        } else {
          console.log('Database initialized successfully');
          resolve();
        }
      });
    });
  });
}

// Routes

// Get all notes
app.get('/api/notes', (req, res) => {
  db.all('SELECT * FROM notes ORDER BY updated_at DESC', (err, rows) => {
    if (err) {
      console.error('Error fetching notes:', err);
      return res.status(500).json({ error: err.message });
    }
    res.json(rows);
  });
});

// Get single note
app.get('/api/notes/:id', (req, res) => {
  db.get('SELECT * FROM notes WHERE id = ?', [req.params.id], (err, row) => {
    if (err) {
      console.error('Error fetching note:', err);
      return res.status(500).json({ error: err.message });
    }
    if (!row) {
      return res.status(404).json({ error: 'Note not found' });
    }
    res.json(row);
  });
});

// Create note
app.post('/api/notes', (req, res) => {
  const { title, content } = req.body;
  
  if (!title || !content) {
    return res.status(400).json({ error: 'Title and content are required' });
  }

  const id = uuidv4();
  
  db.run(
    'INSERT INTO notes (id, title, content) VALUES (?, ?, ?)',
    [id, title, content],
    function(err) {
      if (err) {
        console.error('Error creating note:', err);
        return res.status(500).json({ error: err.message });
      }
      res.status(201).json({ id, title, content, message: 'Note created successfully' });
    }
  );
});

// Update note
app.put('/api/notes/:id', (req, res) => {
  const { title, content } = req.body;
  
  if (!title || !content) {
    return res.status(400).json({ error: 'Title and content are required' });
  }

  db.run(
    'UPDATE notes SET title = ?, content = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
    [title, content, req.params.id],
    function(err) {
      if (err) {
        console.error('Error updating note:', err);
        return res.status(500).json({ error: err.message });
      }
      if (this.changes === 0) {
        return res.status(404).json({ error: 'Note not found' });
      }
      res.json({ message: 'Note updated successfully' });
    }
  );
});

// Delete note
app.delete('/api/notes/:id', (req, res) => {
  db.run('DELETE FROM notes WHERE id = ?', [req.params.id], function(err) {
    if (err) {
      console.error('Error deleting note:', err);
      return res.status(500).json({ error: err.message });
    }
    if (this.changes === 0) {
      return res.status(404).json({ error: 'Note not found' });
    }
    res.json({ message: 'Note deleted successfully' });
  });
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

// Start server
const PORT = process.env.PORT || 3000;

initDatabase().then(() => {
  app.listen(PORT, () => {
    console.log(`Notes App Server running on http://localhost:${PORT}`);
    console.log(`Database: ${dbPath}`);
  });
}).catch(err => {
  console.error('Failed to initialize database:', err);
  process.exit(1);
});

module.exports = app;