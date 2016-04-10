
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called
-- -----------------------------------------------------------------------------------------------------------------

-- Local forward references should go here

-- -------------------------------------------------------------------------------


-- print( screenWidth .. screenHeight)

-- "scene:create()"
function scene:create( event )	
    local screenWidth, screenHeight = display.contentWidth, display.contentHeight
    local screenCenter = { x = screenWidth / 2, y = screenHeight / 2 }
    local GRID_WIDTH = 6
    local GRID_HEIGHT = 6
    local CELL_WIDTH = screenWidth / GRID_WIDTH * 5 / 6
    local CELL_HEIGHT = screenHeight / GRID_HEIGHT * 2 / 3
    local OFFSET_WIDTH = screenWidth * 1 / 12
    local OFFSET_HEIGHT = screenHeight * 1 / 6
    local CIRCLE_RADIUS = CELL_WIDTH / 2
    local sceneGroup = self.view
    
	local corridor = display.newImageRect( "assets/corridor.png", 720, 1280 )
    corridor.x = screenWidth / 2
    corridor.y = screenHeight / 2
    sceneGroup:insert(corridor)
    local backButton = display.newRoundedRect( screenCenter.x, screenCenter.y+400, 350, 150 ,20)
    backButton.tapListener = function(event)
        composer.gotoScene("start")
    end
    sceneGroup:insert(backButton)
    local titleText = display.newText({x=screenCenter.x , y=screenCenter.y - 500 , text="Tap once" ,fontSize=50,font=native.systemFontBold})
    local titleText2 = display.newText({x=screenCenter.x , y=screenCenter.y - 300 , text="Tap twice " ,fontSize=50,font=native.systemFontBold})
    local titleText3 = display.newText({x=screenCenter.x , y=screenCenter.y - 100 , text="    Do NOT tap " ,fontSize=50,font=native.systemFontBold})
    local circle1=display.newCircle(screenCenter.x-250, screenCenter.y-500, CIRCLE_RADIUS)
    sceneGroup:insert(circle1)
    local circle2=display.newCircle(screenCenter.x-250, screenCenter.y-300, CIRCLE_RADIUS)
    sceneGroup:insert(circle2)
    circle2.strokeWidth = 5
    circle2:setStrokeColor( 1, 0, 0 )
    local circle3=display.newCircle(screenCenter.x-250, screenCenter.y-100, CIRCLE_RADIUS)
    sceneGroup:insert(circle3)
    circle3:setFillColor(1,0,0)

    local line = display.newLine( screenCenter.x-250, screenCenter.y+100, screenCenter.x+250, screenCenter.y+100 )
    line.alpha = 0.5
    line:setStrokeColor( 0, 0, 0 )
    line.strokeWidth = 100
    sceneGroup:insert(line)

    local circle4=display.newCircle(screenCenter.x-250, screenCenter.y+100, CIRCLE_RADIUS)
    sceneGroup:insert(circle4)

    local circle = display.newCircle( screenCenter.x+250, screenCenter.y+100, CIRCLE_RADIUS)
    circle:setFillColor(0, 0, 0)
    circle.strokeWidth = 5
    circle.alpha = 0.5
    sceneGroup:insert(circle)
    local titleText4 = display.newText({x=screenCenter.x , y=screenCenter.y + 200 , text="Swipe" ,fontSize=50,font=native.systemFontBold})


    backButton:setFillColor(0,0,0)
    sceneGroup:insert(titleText)
	sceneGroup:insert(titleText2)
    sceneGroup:insert(titleText3)
    sceneGroup:insert(titleText4)
    local backText = display.newText({x=screenCenter.x , y=screenCenter.y +400, text="BACK" ,fontSize=50,font=native.systemFontBold})
    backText:setFillColor(1,1,1)
    sceneGroup:insert(backText)
    backButton:addEventListener( "tap", backButton.tapListener)
end


-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen)
    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen
        -- Insert code here to make the scene come alive
        -- Example: back timers, begin animation, play audio, etc.
    end
end


-- "scene:hide()"
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen)
        -- Insert code here to "pause" the scene
        -- Example: stop timers, stop animation, stop audio, etc.
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen
    end
end


-- "scene:destroy()"
function scene:destroy( event )

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view
    -- Insert code here to clean up the scene
    -- Example: remove display objects, save state, etc.
end


-- -------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene