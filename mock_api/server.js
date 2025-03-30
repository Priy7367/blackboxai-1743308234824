const express = require('express');
const multer = require('multer');
const cors = require('cors');
const app = express();
const port = 3001;

app.use(cors());
app.use(express.json());

const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

// Mock verification endpoint
app.post('/verify', upload.single('image'), (req, res) => {
  const mockResponse = {
    transaction_id: 'txn_123456789',
    is_authentic: Math.random() > 0.3, // 70% chance of being authentic
    confidence: (Math.random() * 0.5 + 0.5).toFixed(4),
    medicine_name: 'Paracetamol 500mg',
    manufacturer: 'MediPharm Inc.',
    batch_number: 'B2023-08-15',
    expiry_date: '2025-08-15',
    production_date: '2023-08-15',
    verification_method: req.body.mode === 'qr' ? 'qr' : 'ai'
  };
  res.json(mockResponse);
});

// Mock blockchain details endpoint
app.get('/blockchain/:id', (req, res) => {
  res.json({
    transaction_hash: '0xabcd1234efgh5678',
    block_number: '123456',
    timestamp: '2023-08-15T12:34:56Z',
    owner_address: '0x1234abcd5678efgh',
    manufacturer_address: '0xmedipharm123456',
    previous_owners: []
  });
});

// Mock report endpoint
app.post('/report', (req, res) => {
  res.json({ success: true });
});

app.listen(port, () => {
  console.log(`Mock API server running at http://localhost:${port}`);
});