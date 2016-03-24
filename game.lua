local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called
-- -----------------------------------------------------------------------------------------------------------------

-- Local forward references should go here

-- -------------------------------------------------------------------------------

local screenWidth, screenHeight = display.contentWidth, display.contentHeight
local screenCenter = { x = screenWidth / 2, y = screenHeight / 2 }
-- print( screenWidth .. screenHeight)
local GRID_WIDTH = 6
local GRID_HEIGHT = 6
local CELL_WIDTH = screenWidth / GRID_WIDTH * 5 / 6
local CELL_HEIGHT = screenHeight / GRID_HEIGHT * 2 / 3
local OFFSET_WIDTH = screenWidth * 1 / 12
local OFFSET_HEIGHT = screenHeight * 1 / 6
local CIRCLE_RADIUS = CELL_WIDTH / 2

RANDOM = true

-- Setup grid

local grid = {}
for i = 1, GRID_HEIGHT do
    grid[i] = {}
end


for i = 1, GRID_WIDTH do
    for j = 1, GRID_HEIGHT do
        local xPos = CELL_WIDTH * (i - 1) + CELL_WIDTH / 2 + OFFSET_WIDTH
        local yPos = CELL_HEIGHT * (j - 1) + CELL_HEIGHT / 2 + OFFSET_HEIGHT
        grid[i][j] = {x=xPos, y=yPos}
        -- print ( grid[i][j].x .. " " .. grid[i][j].y )
    end
end

local puzzles = require( "puzzles" )
puzzleLoader = {}
puzzleLoader.puzzles = puzzles
puzzleLoader.level = 0
puzzleLoader.speed = 7000
puzzleLoader.timeOver = function (obj)
    composer.gotoScene("gameOver")
    composer.removeScene("game",false)
end

function puzzleLoader:loadNextPuzzle()
    --print ("Called load next puzzle")
    self.level = self.level + 1
    self.speed=self.speed-(self.speed*0.1)
    print (self.speed)
    print (self.level)
    if (RANDOM) then
        return self:generateRandomPuzzle()
    end
    puzzle = require( self.puzzles[self.level] )
    return puzzle
end

function puzzleLoader:generateRandomPuzzle()
    -- print( "Generating random puzzle" )
    puzzle = {
        dots = {
            {x=math.random( GRID_WIDTH ), y=math.random( GRID_HEIGHT ), taps=math.random( 2 )},
            {x=math.random( GRID_WIDTH ), y=math.random( GRID_HEIGHT ), taps=math.random( 2 )},
            {x=math.random( GRID_WIDTH ), y=math.random( GRID_HEIGHT ), taps=math.random( 2 )}
        },
    }
    -- print( "Generated random puzzle" )
    return puzzle
end 


local function displayCircle(dot) 
    --print( "Displaying circle" )
    local pos = grid[dot.x][dot.y]
    local circle = display.newCircle( pos.x, pos.y, CIRCLE_RADIUS )
    circle:setFillColor( 1 )
    circle.done = false
    circle.taps = dot.taps
    if circle.taps == 2 then
        circle.strokeWidth = 5
        circle:setStrokeColor( 1, 0, 0 )
    end
    circle.tapListener = function(event)
        local circle = event.target
            if ( circle.taps == event.numTaps ) then
                circle:onDone();
            end
            print( circle.done )
    end
    circle:addEventListener( "tap", circle.tapListener)

    function circle:onDone() 
        self.done = true
        self.alpha = 0
        self:removeEventListener( "tap", self.tapListener )
        self.group:checkComplete()
    end

    return circle
end


function displayPuzzle(puzzle, sceneGroup)
    local wall = display.newRect( screenCenter.x, screenCenter.y, 120, 120 )
    wall:setFillColor( 0.4 )
    wall.alpha = 1
    wall.zoomTranstion = transition.to( wall, { time=puzzleLoader.speed, xScale=12, yScale=12, onComplete=puzzleLoader.timeOver })
    sceneGroup:insert( wall )
    local patternGroup = display.newGroup( )
    local levelText = display.newText({x=screenCenter.x , y=20 , text=puzzleLoader.level ,fontSize=50 ,font=native.systemFontBold})
    patternGroup:insert( levelText )
    for k,dot in pairs(puzzle.dots) do
        circle = displayCircle(dot)
        circle.group = patternGroup
        patternGroup:insert( circle )
        print( "Scene group Children: " .. patternGroup.numChildren )
    end
    sceneGroup:insert( patternGroup )



    function patternGroup:checkComplete()
        print( "Checking group Children: " .. self.numChildren )
        for i = 1, self.numChildren do
            if self[i].done == false then
                return false
            end
        end
        print( "Yayyy, you did it" )
        self:onComplete()
        return true
    end

    function patternGroup:onComplete()
        self:removeSelf( )
        wall:removeSelf( )
        transition.cancel(wall.zoomTransition)
        wall = nil
        local puzzle = puzzleLoader:loadNextPuzzle()
        displayPuzzle(puzzle, sceneGroup)
    end
end





-- "scene:create()"
function scene:create( event )

    -- Initialize the scene here
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.

    local sceneGroup = self.view

    local corridor = display.newImageRect( "assets/corridor.png", 720, 1280 )
    corridor.x = screenWidth / 2
    corridor.y = screenHeight / 2
    sceneGroup:insert( corridor )
    local puzzle = puzzleLoader:loadNextPuzzle()
    
    displayPuzzle(puzzle, sceneGroup)

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
        -- Example: start timers, begin animation, play audio, etc.
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
    print ("ASDHKASJHDKJASHDKJHSAKDJHSAKJDHKSAJHDKJSAHDKJHSA")

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