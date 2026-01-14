-- SquadSearch - Location-based Ping App
-- Main entry point

-- Hide status bar
display.setStatusBar( display.HiddenStatusBar )

-- Initialize Composer for scene management
local composer = require( "composer" )

-- Initialize global variables
_G.gameData = {
    selectedSport = nil,
    currentLocation = nil,
    userPing = nil,
    nearbyPings = {},
    points = 0,
    pingRadius = 100, -- meters
    mapboxToken = "pk.eyJ1IjoiZGF2b3JlZG1hbiIsImEiOiJjbWtkbjRraW8wZHBvM2Vwbnlvd2lraTM4In0.ZbWtu2SO8H9kXbNL3_BGlA", -- Replace with your Mapbox token
    praxisMapperURL = "http://localhost:8080", -- Replace with your Praxis Mapper URL
    userId = math.random(100000, 999999), -- Generate unique user ID
}

-- Go to landing scene
composer.gotoScene( "scenes.landing" )
