// Praxis Mapper Backend Server
// Node.js/Express server for handling ping data

const express = require('express');
const cors = require('cors');
const app = express();
const PORT = 8080;

// Middleware
app.use(cors());
app.use(express.json());

// In-memory storage for pings (in production, use a database)
let pings = [];
const PING_EXPIRY_TIME = 300000; // 5 minutes in milliseconds

// Clean up expired pings periodically
setInterval(() => {
    const now = Date.now();
    pings = pings.filter(ping => (now - ping.timestamp) < PING_EXPIRY_TIME);
}, 60000); // Clean up every minute

// POST /api/pings - Create a new ping
app.post('/api/pings', (req, res) => {
    const { userId, sport, latitude, longitude, timestamp } = req.body;
    
    if (!userId || !sport || latitude === undefined || longitude === undefined) {
        return res.status(400).json({ error: 'Missing required fields' });
    }
    
    const ping = {
        id: Date.now().toString() + Math.random().toString(36).substr(2, 9),
        userId,
        sport,
        latitude: parseFloat(latitude),
        longitude: parseFloat(longitude),
        timestamp: timestamp || Date.now(),
    };
    
    // Remove old ping from same user
    pings = pings.filter(p => p.userId !== userId);
    
    // Add new ping
    pings.push(ping);
    
    console.log(`New ping from user ${userId} at (${latitude}, ${longitude})`);
    
    res.json({ success: true, ping });
});

// GET /api/pings/nearby - Get pings within radius
app.get('/api/pings/nearby', (req, res) => {
    const lat = parseFloat(req.query.lat);
    const lon = parseFloat(req.query.lon);
    const radius = parseFloat(req.query.radius) || 200; // meters
    
    if (isNaN(lat) || isNaN(lon)) {
        return res.status(400).json({ error: 'Invalid coordinates' });
    }
    
    // Calculate distance using Haversine formula
    const calculateDistance = (lat1, lon1, lat2, lon2) => {
        const R = 6371000; // Earth radius in meters
        const dLat = (lat2 - lat1) * Math.PI / 180;
        const dLon = (lon2 - lon1) * Math.PI / 180;
        const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                  Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
                  Math.sin(dLon / 2) * Math.sin(dLon / 2);
        const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    };
    
    // Filter pings within radius
    const now = Date.now();
    const nearbyPings = pings.filter(ping => {
        // Remove expired pings
        if ((now - ping.timestamp) >= PING_EXPIRY_TIME) {
            return false;
        }
        
        const distance = calculateDistance(lat, lon, ping.latitude, ping.longitude);
        return distance <= radius;
    });
    
    res.json({ pings: nearbyPings });
});

// GET /api/pings - Get all active pings
app.get('/api/pings', (req, res) => {
    const now = Date.now();
    const activePings = pings.filter(ping => (now - ping.timestamp) < PING_EXPIRY_TIME);
    res.json({ pings: activePings });
});

// DELETE /api/pings/:userId - Remove ping for a user
app.delete('/api/pings/:userId', (req, res) => {
    const { userId } = req.params;
    pings = pings.filter(p => p.userId !== userId);
    res.json({ success: true });
});

// Health check
app.get('/health', (req, res) => {
    res.json({ status: 'ok', activePings: pings.length });
});

app.listen(PORT, () => {
    console.log(`Praxis Mapper server running on http://localhost:${PORT}`);
    console.log(`Active pings: ${pings.length}`);
});
