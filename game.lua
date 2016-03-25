local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called
-- -----------------------------------------------------------------------------------------------------------------

-- Local forward references should go here

-- -------------------------------------------------------------------------------

local screenWidth, screenHeight = display.contentWidth, display.contentHeight
local screenCenter = { x = display.contentCenterX, y = display.contentCenterY }
-- print( screenWidth .. screenHeight)
local GRID_WIDTH = 6
local GRID_HEIGHT = 6
local CELL_WIDTH = screenWidth / GRID_WIDTH * 5 / 6
local CELL_HEIGHT = screenHeight / GRID_HEIGHT * 2 / 3
local OFFSET_WIDTH = screenWidth * 1 / 12
local OFFSET_HEIGHT = screenHeight * 1 / 6
local CIRCLE_RADIUS = CELL_WIDTH / 2

local RANDOM = true

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
puzzleLoader.score = 0


puzzleLoader.timeOver = function (obj)
    print("Level" .. puzzleLoader.level)
    local options = {
        effect = "fade",
        time = 400,
        params = {
            score = puzzleLoader.score,
            level = puzzleLoader.level
        }
    }
    composer.gotoScene("gameOver", options)
    composer.removeScene("game", false)
end

function puzzleLoader:loadNextPuzzle()
    --print ("Called load next puzzle")
    self.level = self.level + 1
    self.levelText.text = self.level
    self.speed = self.speed - self.speed * 0.1
    print (self.speed)
    print (self.level)
    if (RANDOM) then
        return self:generateRandomPuzzle()
    end
    local puzzle = require( self.puzzles[self.level] )
    return puzzle
end

function puzzleLoader:generateRandomPuzzle()
    -- print( "Generating random puzzle" )
    local puzzle = {
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
    circle.touchListener = function(event)
        if (event.phase == "ended") then
            local circle = event.target
            circle.taps = circle.taps - 1
            if ( circle.taps == 1 ) then
                circle.strokeWidth = 0
            elseif ( circle.taps == 0 ) then
                circle:onDone();
            end
        end
    end
    circle:addEventListener( "touch", circle.touchListener)

    function circle:onDone() 
        --self.done = true
        --self.alpha = 0
        --self:removeEventListener( "tap", self.tapListener )
        self:removeSelf( )
        self.group:checkComplete()
        if( self.taps == 2 ) then
            puzzleLoader.score = puzzleLoader.score + 2
        else 
            puzzleLoader.score = puzzleLoader.score + 1
        end
    end

    return circle
end


function displayPuzzle(puzzle, background, patternGroup, foreground)
    local wall = display.newRect( screenCenter.x, screenCenter.y, 120, 120 )
    wall:setFillColor( 0.4 )
    wall.alpha = 1
    wall.zoomTranstion = transition.to( wall, { time=puzzleLoader.speed, xScale=12, yScale=12, onComplete=puzzleLoader.timeOver })
    background:insert( wall )
    for k,dot in pairs(puzzle.dots) do
        local circle = displayCircle(dot)
        circle.group = patternGroup
        patternGroup:insert( circle )
    end

    function patternGroup:checkComplete()
        print("Num children" .. self.numChildren)
        if ( self.numChildren == 0 ) then
            self:onComplete()
        end
    end
    function patternGroup:onComplete()
        wall:removeSelf( )
        transition.cancel(wall.zoomTransition)
        wall = nil
        local puzzle = puzzleLoader:loadNextPuzzle()
        displayPuzzle(puzzle, background, patternGroup, foreground)
    end
end





-- "scene:create()"
function scene:create( event )

    -- Initialize the scene here
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.

    local sceneGroup = self.view
    local corridor = display.newImageRect( "assets/Anriduh.png", 720, 1280 )
    corridor.x = screenWidth / 2
    corridor.y = screenHeight / 2
    local background = display.newGroup( )
    background:insert (corridor )
    sceneGroup:insert( background )
    local patternGroup = display.newGroup( )
    sceneGroup:insert( patternGroup )
    local foreground = display.newGroup( )
    sceneGroup:insert( foreground )
    puzzleLoader.levelText = display.newText({x=screenCenter.x , y=30 , text=puzzleLoader.level ,fontSize=80 ,font=native.systemFontBold})
    foreground:insert (puzzleLoader.levelText)
    local puzzle = puzzleLoader:loadNextPuzzle()
    displayPuzzle(puzzle, background, patternGroup, foreground)
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