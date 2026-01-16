-- Landing Scene - Sport Selection
local composer = require( "composer" )
local scene = composer.newScene()

-- Sports list
local sports = {
    { name = "Football", icon = "⚽" },
    { name = "Basketball", icon = "🏀" },
    { name = "Baseball", icon = "⚾" },
    { name = "Tennis", icon = "🎾" },
    { name = "Soccer", icon = "⚽" },
    { name = "Volleyball", icon = "🏐" },
    { name = "Running", icon = "🏃" },
    { name = "Cycling", icon = "🚴" },
}

-- Create sport selection buttons
local function createSportButtons( sceneGroup )
    local buttonWidth = display.contentWidth * 0.4
    local buttonHeight = 80
    local spacing = 20
    local startY = display.contentHeight * 0.3
    local buttonsPerRow = 2
    local currentX = display.contentWidth * 0.1
    local currentY = startY
    
    for i = 1, #sports do
        local sport = sports[i]
        
        -- Create button background
        local button = display.newRoundedRect( sceneGroup, currentX, currentY, buttonWidth, buttonHeight, 15 )
        button:setFillColor( 0.2, 0.6, 0.9 )
        button.sport = sport.name
        
        -- Create sport icon
        local iconText = display.newText( {
            parent = sceneGroup,
            text = sport.icon,
            x = currentX,
            y = currentY - 15,
            fontSize = 40,
        } )
        
        -- Apply grayscale effect to make icons black and white
        -- Using setFillColor with grayscale values
        iconText:setFillColor( 0.4, 0.4, 0.4 ) -- Dark gray for black and white effect
        
        -- Create sport name
        local nameText = display.newText( {
            parent = sceneGroup,
            text = sport.name,
            x = currentX,
            y = currentY + 20,
            fontSize = 18,
            font = native.systemFontBold,
        } )
        nameText:setFillColor( 1, 1, 1 )
        
        -- Button touch handler
        local function onButtonTouch( event )
            if event.phase == "ended" then
                _G.gameData.selectedSport = sport.name
                composer.gotoScene( "scenes.map", { effect = "slideLeft", time = 300 } )
            end
            return true
        end
        
        button:addEventListener( "touch", onButtonTouch )
        
        -- Update position for next button
        if i % buttonsPerRow == 0 then
            currentX = display.contentWidth * 0.1
            currentY = currentY + buttonHeight + spacing
        else
            currentX = currentX + buttonWidth + spacing
        end
    end
end

function scene:create( event )
    local sceneGroup = self.view
    
    -- Background
    local background = display.newRect( sceneGroup, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight )
    background:setFillColor( 0.1, 0.1, 0.15 )
    
    -- Title
    local title = display.newText( {
        parent = sceneGroup,
        text = "SquadSearch",
        x = display.contentCenterX,
        y = 80,
        fontSize = 48,
        font = native.systemFontBold,
    } )
    title:setFillColor( 1, 1, 1 )
    
    -- Subtitle
    local subtitle = display.newText( {
        parent = sceneGroup,
        text = "Select Your Sport",
        x = display.contentCenterX,
        y = 140,
        fontSize = 24,
        font = native.systemFont,
    } )
    subtitle:setFillColor( 0.8, 0.8, 0.8 )
    
    -- Create sport buttons
    createSportButtons( sceneGroup )
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase
    
    if phase == "will" then
        -- Scene is about to show
    elseif phase == "did" then
        -- Scene is now showing
    end
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase
    
    if phase == "will" then
        -- Scene is about to hide
    elseif phase == "did" then
        -- Scene is now hidden
    end
end

function scene:destroy( event )
    local sceneGroup = self.view
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene
