# SquadSearch - Location-Based Ping App

A location-based mobile app built with Solar2D where users can "ping" their current location. The app detects if there are three or more other active pings nearby and awards points to the user when this condition is met.

## Features

- **Sport Selection**: Choose from multiple sports on the landing screen
- **Location Pinging**: Ping your current location to signal your presence
- **Proximity Detection**: Automatically detects when 3+ other users are nearby
- **Point System**: Earn points when you're near other players (10 points per nearby ping)
- **Real-time Updates**: Nearby ping count updates in real-time
- **Map Integration**: Visual representation of your location and nearby pings

## Tech Stack

- **Frontend**: Solar2D (Corona SDK) - Lua-based game engine
- **Geolocation**: Mapbox (configured for integration)
- **Backend**: Praxis Mapper (Node.js/Express server)
- **Platform**: iOS and Android

## Project Structure

```
squadsearch/
├── config.lua              # Solar2D configuration
├── build.settings          # Build settings for iOS/Android
├── main.lua               # App entry point
├── scenes/
│   ├── landing.lua        # Sport selection screen
│   └── map.lua            # Main map screen with ping functionality
├── utils/
│   └── json.lua           # JSON encoder/decoder
├── server/
│   ├── praxis-mapper-server.js  # Backend server
│   └── package.json       # Node.js dependencies
└── README.md
```

## Setup Instructions

### 1. Solar2D Setup

1. Download and install [Solar2D](https://solar2d.com/)
2. Open Solar2D Simulator
3. Open this project folder in Solar2D

### 2. Mapbox Configuration

1. Sign up for a [Mapbox account](https://www.mapbox.com/)
2. Get your Mapbox access token
3. Open `main.lua` and replace `YOUR_MAPBOX_ACCESS_TOKEN` with your actual token:
   ```lua
   mapboxToken = "pk.eyJ1IjoieW91cnVzZXJuYW1lIiwiYSI6ImN..."
   ```

### 3. Backend Server Setup

1. Navigate to the `server` directory:
   ```bash
   cd server
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Start the server:
   ```bash
   npm start
   ```

   The server will run on `http://localhost:8080`

4. (Optional) For development with auto-reload:
   ```bash
   npm run dev
   ```

### 4. Configure Backend URL

If your backend server is running on a different URL, update `main.lua`:
```lua
praxisMapperURL = "http://your-server-url:8080"
```

For device testing, use your computer's local IP address:
```lua
praxisMapperURL = "http://192.168.1.XXX:8080"
```

## Usage

1. **Launch the app** in Solar2D Simulator or on a device
2. **Select a sport** from the landing screen
3. **Allow location permissions** when prompted
4. **Tap the PING button** to send your location
5. **Earn points** when 3+ other users ping nearby (10 points per nearby ping)

## API Endpoints

The Praxis Mapper backend provides the following endpoints:

- `POST /api/pings` - Create a new ping
  ```json
  {
    "userId": "123456",
    "sport": "Football",
    "latitude": 37.7749,
    "longitude": -122.4194,
    "timestamp": 1234567890
  }
  ```

- `GET /api/pings/nearby?lat=37.7749&lon=-122.4194&radius=200` - Get nearby pings
  Returns: `{ "pings": [...] }`

- `GET /api/pings` - Get all active pings

- `DELETE /api/pings/:userId` - Remove a user's ping

- `GET /health` - Health check endpoint

## Configuration

### Ping Settings

In `main.lua`, you can adjust:
- `pingRadius`: Distance in meters to consider pings as "nearby" (default: 100m)
- `pointsPerPing`: Points awarded per nearby ping (currently 10 points)

### Location Services

The app requires location permissions:
- **iOS**: Configured in `build.settings` with usage descriptions
- **Android**: Permissions declared in `build.settings`

## Mapbox Integration Notes

The current implementation includes a placeholder for Mapbox. To fully integrate:

1. Install the Mapbox plugin for Solar2D (if available)
2. Replace the map placeholder in `scenes/map.lua` with native Mapbox map view
3. Use Mapbox SDK for accurate coordinate-to-screen conversions

## Testing

### Simulator Testing
- The app uses a default location (San Francisco) when running in the simulator
- Multiple simulator instances can be used to test proximity detection

### Device Testing
- Ensure location services are enabled
- Connect to the same network as your backend server
- Update `praxisMapperURL` to use your computer's local IP

## Future Enhancements

- Full Mapbox map integration with native map view
- User authentication and profiles
- Persistent point storage
- Sport-specific filtering
- Push notifications for nearby players
- Leaderboards
- Chat functionality

## License

MIT License - feel free to use and modify as needed.

## Support

For issues or questions:
- Solar2D Documentation: https://docs.coronalabs.com/
- Mapbox Documentation: https://docs.mapbox.com/
- Praxis Mapper: Custom backend implementation
