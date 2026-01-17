-- Team Selection Scene
local composer = require( "composer" )
local scene = composer.newScene()

-- Team options
local teams = {
    { name = "Big Tuna", color = { 0.2, 0.6, 0.9 } },
    { name = "Seahawks", color = { 0.9, 0.3, 0.3 } },
    { name = "Stingers", color = { 0.3, 0.9, 0.3 } },
    { name = "Gators", color = { 0.9, 0.7, 0.2 } },
    { name = "Solo", color = { 0.6, 0.6, 0.6 } },
}

-- Create team selection buttons
local function createTeamButtons( sceneGroup )
    local buttonWidth = display.contentWidth * 0.7
    local buttonHeight = 70
    local spacing = 15
    local startY = display.contentHeight * 0.35
    local buttonsPerRow = 1
    
    local currentX = display.contentCenterX
    local currentY = startY
    
    for i = 1, #teams do
        local team = teams[i]
        
        -- Create button background
        local button = display.newRoundedRect( sceneGroup, currentX, currentY, buttonWidth, buttonHeight, 15 )
        button:setFillColor( unpack( team.color ) )
        button.team = team.name
        
        -- Create team name
        local nameText = display.newText( {
            parent = sceneGroup,
            text = team.name,
            x = currentX,
            y = currentY,
            fontSize = 24,
            font = native.systemFontBold,
        } )
        nameText:setFillColor( 1, 1, 1 )
        
        -- Button touch handler
        local function onButtonTouch( event )
            if event.phase == "ended" then
                _G.gameData.selectedTeam = team.name
                composer.gotoScene( "scenes.map", { effect = "slideLeft", time = 300 } )
            end
            return true
        end
        
        button:addEventListener( "touch", onButtonTouch )
        
        -- Update position for next button
        currentY = currentY + buttonHeight + spacing
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
        text = "Select Your Team",
        x = display.contentCenterX,
        y = 100,
        fontSize = 36,
        font = native.systemFontBold,
    } )
    title:setFillColor( 1, 1, 1 )
    
    -- Sport display
    local sportDisplay = display.newText( {
        parent = sceneGroup,
        text = _G.gameData.selectedSport or "Sport",
        x = display.contentCenterX,
        y = 150,
        fontSize = 20,
        font = native.systemFont,
    } )
    sportDisplay:setFillColor( 0.8, 0.8, 0.8 )
    
    -- Create team buttons
    createTeamButtons( sceneGroup )
    
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
