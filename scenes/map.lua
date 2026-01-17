-- Map Scene - Main game screen with ping functionality
local composer = require( "composer" )
local json = require( "json" ) -- Solar2D built-in JSON library
local scene = composer.newScene()

-- Valid team names (must match teamSelection.lua)
local validTeams = {
    "Big Tuna",
    "Seahawks",
    "Stingers",
    "Gators",
    "Solo",
}

local mapView = nil
local pingButton = nil
local pointsDisplay = nil
local nearbyCountDisplay = nil
local teamDisplay = nil
local userMarker = nil
local pingMarkers = {}
local isPinging = false

-- Calculate distance between two coordinates (Haversine formula)
local function calculateDistance( lat1, lon1, lat2, lon2 )
    local R = 6371000 -- Earth radius in meters
    local dLat = math.rad( lat2 - lat1 )
    local dLon = math.rad( lon2 - lon1 )
    local a = math.sin( dLat / 2 ) * math.sin( dLat / 2 ) +
              math.cos( math.rad( lat1 ) ) * math.cos( math.rad( lat2 ) ) *
              math.sin( dLon / 2 ) * math.sin( dLon / 2 )
    local c = 2 * math.atan2( math.sqrt( a ), math.sqrt( 1 - a ) )
    return R * c
end

-- Update nearby ping count
local function updateNearbyCount()
    if not _G.gameData.currentLocation then return end
    
    local nearbyCount = 0
    local userLat = _G.gameData.currentLocation.latitude
    local userLon = _G.gameData.currentLocation.longitude
    
    for i = 1, #_G.gameData.nearbyPings do
        local ping = _G.gameData.nearbyPings[i]
        local distance = calculateDistance( userLat, userLon, ping.latitude, ping.longitude )
        if distance <= _G.gameData.pingRadius then
            nearbyCount = nearbyCount + 1
        end
    end
    
    if nearbyCountDisplay then
        nearbyCountDisplay.text = "Nearby: " .. nearbyCount
    end
    
    -- Award points if 3+ pings nearby
    if nearbyCount >= 3 and isPinging then
        local pointsToAdd = 10 * nearbyCount
        _G.gameData.points = _G.gameData.points + pointsToAdd
        if pointsDisplay then
            pointsDisplay.text = "Points: " .. _G.gameData.points
        end
        
        -- Show notification
        local notification = display.newText( {
            text = "+" .. pointsToAdd .. " points!",
            x = display.contentCenterX,
            y = display.contentHeight * 0.3,
            fontSize = 32,
            font = native.systemFontBold,
        } )
        notification:setFillColor( 0, 1, 0 )
        transition.to( notification, { y = notification.y - 50, alpha = 0, time = 2000, onComplete = function() display.remove( notification ) end } )
    end
end

-- Send ping to Praxis Mapper backend
local function sendPingToBackend( latitude, longitude )
    local function networkListener( event )
        if event.isError then
            print( "Network error: " .. tostring( event.response ) )
        else
            print( "Ping sent successfully" )
        end
    end
    
    local headers = {}
    headers["Content-Type"] = "application/json"
    
    local params = {}
    params.headers = headers
    params.body = json.encode( {
        userId = _G.gameData.userId,
        sport = _G.gameData.selectedSport,
        latitude = latitude,
        longitude = longitude,
        timestamp = os.time(),
    } )
    
    network.request( _G.gameData.praxisMapperURL .. "/api/pings", "POST", networkListener, params )
end

-- Fetch nearby pings from Praxis Mapper backend
local function fetchNearbyPings()
    if not _G.gameData.currentLocation then return end
    
    local function networkListener( event )
        if event.isError then
            print( "Network error fetching pings: " .. tostring( event.response ) )
        else
            local response = json.decode( event.response )
            if response and response.pings then
                _G.gameData.nearbyPings = response.pings
                updateNearbyCount()
                updatePingMarkers()
            end
        end
    end
    
    local url = _G.gameData.praxisMapperURL .. "/api/pings/nearby?" ..
                "lat=" .. _G.gameData.currentLocation.latitude ..
                "&lon=" .. _G.gameData.currentLocation.longitude ..
                "&radius=" .. _G.gameData.pingRadius * 2
    
    network.request( url, "GET", networkListener )
end

-- Update ping markers on map
local function updatePingMarkers()
    -- Clear existing markers
    for i = 1, #pingMarkers do
        if pingMarkers[i] then
            display.remove( pingMarkers[i] )
        end
    end
    pingMarkers = {}
    
    if not mapView or not _G.gameData.currentLocation then return end
    
    -- Add markers for nearby pings
    for i = 1, #_G.gameData.nearbyPings do
        local ping = _G.gameData.nearbyPings[i]
        if ping.userId ~= _G.gameData.userId then
            local marker = display.newCircle( 0, 0, 8 )
            marker:setFillColor( 1, 0.5, 0 )
            marker.alpha = 0.7
            -- Note: In a real implementation, you'd convert lat/lon to screen coordinates
            marker.x = display.contentCenterX + ( ping.longitude - _G.gameData.currentLocation.longitude ) * 10000
            marker.y = display.contentCenterY - ( ping.latitude - _G.gameData.currentLocation.latitude ) * 10000
            scene.view:insert( marker )
            pingMarkers[#pingMarkers + 1] = marker
        end
    end
end

-- Handle ping button tap
local function onPingButtonTap()
    if not _G.gameData.currentLocation then
        -- Request location if not available
        native.showAlert( "Location Required", "Please enable location services.", { "OK" } )
        return
    end
    
    isPinging = true
    
    -- Send ping to backend
    sendPingToBackend( _G.gameData.currentLocation.latitude, _G.gameData.currentLocation.longitude )
    
    -- Update user marker
    if userMarker then
        userMarker:setFillColor( 0, 1, 0 )
        transition.to( userMarker, { alpha = 0.3, time = 1000, iterations = 3 } )
    end
    
    -- Fetch nearby pings after a short delay
    timer.performWithDelay( 500, fetchNearbyPings )
    
    -- Reset ping state after 5 seconds
    timer.performWithDelay( 5000, function()
        isPinging = false
        if userMarker then
            userMarker:setFillColor( 0.2, 0.6, 0.9 )
            userMarker.alpha = 1
        end
    end )
end

-- Get current location
local function getCurrentLocation()
    local function locationHandler( event )
        if event.errorCode then
            native.showAlert( "Location Error", "Unable to get location: " .. tostring( event.errorMessage ), { "OK" } )
        else
            _G.gameData.currentLocation = {
                latitude = event.latitude,
                longitude = event.longitude,
            }
            
            -- Update user marker position
            if userMarker then
                -- In a real implementation, you'd convert lat/lon to screen coordinates
                userMarker.x = display.contentCenterX
                userMarker.y = display.contentCenterY
            end
            
            -- Fetch nearby pings
            fetchNearbyPings()
        end
    end
    
    if system.getInfo( "environment" ) == "simulator" then
        -- Simulator location (San Francisco)
        _G.gameData.currentLocation = {
            latitude = 37.7749,
            longitude = -122.4194,
        }
        if userMarker then
            userMarker.x = display.contentCenterX
            userMarker.y = display.contentCenterY
        end
        fetchNearbyPings()
    else
        -- Request location on device
        Runtime:addEventListener( "location", locationHandler )
        if location.hasLocationServicesEnabled() then
            location.startLocation()
        else
            native.showAlert( "Location Services", "Please enable location services in settings.", { "OK" } )
        end
    end
end

function scene:create( event )
    local sceneGroup = self.view
    
    -- Background
    local background = display.newRect( sceneGroup, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight )
    background:setFillColor( 0.15, 0.15, 0.2 )
    
    -- Native map view
    mapView = native.newMapView( display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight * 0.8 )
    mapView.mapType = "standard" -- or "satellite", "hybrid"
    sceneGroup:insert( mapView )
    
    -- User marker
    userMarker = display.newCircle( sceneGroup, display.contentCenterX, display.contentCenterY, 12 )
    userMarker:setFillColor( 0.2, 0.6, 0.9 )
    userMarker.strokeWidth = 2
    userMarker:setStrokeColor( 1, 1, 1 )
    
    -- Ping button
    pingButton = display.newRoundedRect( sceneGroup, display.contentCenterX, display.contentHeight * 0.9, 200, 60, 30 )
    pingButton:setFillColor( 0, 0.8, 0.4 )
    pingButton:addEventListener( "tap", onPingButtonTap )
    
    local pingButtonText = display.newText( {
        parent = sceneGroup,
        text = "PING",
        x = display.contentCenterX,
        y = display.contentHeight * 0.9,
        fontSize = 28,
        font = native.systemFontBold,
    } )
    pingButtonText:setFillColor( 1, 1, 1 )
    
    -- Points display
    pointsDisplay = display.newText( {
        parent = sceneGroup,
        text = "Points: " .. _G.gameData.points,
        x = display.contentWidth * 0.15,
        y = 50,
        fontSize = 20,
        font = native.systemFontBold,
    } )
    pointsDisplay:setFillColor( 1, 1, 0 )
    
    -- Nearby count display
    nearbyCountDisplay = display.newText( {
        parent = sceneGroup,
        text = "Nearby: 0",
        x = display.contentWidth * 0.85,
        y = 50,
        fontSize = 18,
        font = native.systemFont,
    } )
    nearbyCountDisplay:setFillColor( 1, 1, 1 )
    
    -- Team display will be created/updated in scene:show() to reflect most recent selection
    
    -- Back button
    local backButton = display.newRoundedRect( sceneGroup, 50, 50, 80, 40, 10 )
    backButton:setFillColor( 0.5, 0.5, 0.5 )
    backButton:addEventListener( "tap", function()
        composer.gotoScene( "scenes.landing", { effect = "slideRight", time = 300 } )
    end )
    
    local backButtonText = display.newText( {
        parent = sceneGroup,
        text = "Back",
        x = 50,
        y = 50,
        fontSize = 16,
        font = native.systemFont,
    } )
    backButtonText:setFillColor( 1, 1, 1 )
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase
    
    if phase == "will" then
        -- Scene is about to show
    elseif phase == "did" then
        -- Update team display with most recent selection
        if teamDisplay then
            display.remove( teamDisplay )
            teamDisplay = nil
        end
        
        local teamName = nil
        if _G.gameData.selectedTeam then
            -- Check if selected team matches one of the valid teams
            for i = 1, #validTeams do
                if _G.gameData.selectedTeam == validTeams[i] then
                    teamName = _G.gameData.selectedTeam
                    break
                end
            end
        end
        
        if teamName then
            teamDisplay = display.newText( {
                parent = sceneGroup,
                text = teamName,
                x = display.contentCenterX,
                y = 50,
                fontSize = 18,
                font = native.systemFont,
            } )
            teamDisplay:setFillColor( 0.8, 0.8, 0.8 )
        end
        
        -- Get location when scene shows
        getCurrentLocation()
        
        -- Periodically fetch nearby pings
        timer.performWithDelay( 10000, fetchNearbyPings, 0 )
    end
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase
    
    if phase == "will" then
        -- Cancel timers
        timer.cancelAll()
    elseif phase == "did" then
        -- Scene is now hidden
    end
end

function scene:destroy( event )
    local sceneGroup = self.view
    
    -- Clean up
    for i = 1, #pingMarkers do
        if pingMarkers[i] then
            display.remove( pingMarkers[i] )
        end
    end
    pingMarkers = {}
    
    if teamDisplay then
        display.remove( teamDisplay )
        teamDisplay = nil
    end
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene
