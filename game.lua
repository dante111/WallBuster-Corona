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

local RANDOM = false
local EPSILON = 0.01

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

local circles = {}
local dummyCircles = {}
puzzleLoader.timeOver = function (obj)
    local options = {
        effect = "fade",
        time = 400,
        params = {
            score = puzzleLoader.score,
            level = puzzleLoader.level
        }
    }
    transition.cancel(puzzleLoader.wall.zoomTransition)
    puzzleLoader.overSound = audio.loadSound( "assets/gameOver.mp3" )
    audio.play( puzzleLoader.overSound )
    composer.gotoScene("gameOver", options)
    composer.removeScene("game", false)
end

function puzzleLoader:loadNextPuzzle()
    --print ("Called load next puzzle")
    self.level = self.level + 1
    self.levelText.text = self.level
    self.speed = self.speed * 0.95
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
        dummyDots = { }
    }
    n = math.random( 3 ) - 1
    for i = 1, n do
        puzzle.dummyDots[#puzzle.dummyDots+1] = {x=math.random( GRID_WIDTH ), y=math.random( GRID_HEIGHT )}
    end
    -- print( "Generated random puzzle" )
    return puzzle
end 


local function displayCircle(dot) 
    --print( "Displaying circle" )
    local pos = grid[dot.x][dot.y]
    local circle = display.newCircle( pos.x, pos.y, CIRCLE_RADIUS )
    circle.taps = dot.taps
    if circle.taps == 2 then
        circle.strokeWidth = 5
        circle:setStrokeColor( 1, 0, 0 )
    end
    function circle:touch(event)
        if (event.phase == "ended") then
            puzzleLoader.score = puzzleLoader.score + 1
            audio.play( puzzleLoader.tapSound )
            local circle = event.target
            circle.taps = circle.taps - 1
            if ( circle.taps == 1 ) then
                circle.strokeWidth = 0
            elseif ( circle.taps == 0 ) then
                circle:onDone();
            end
        end
        return true
    end
    circle:addEventListener( "touch" )
    function circle:onDone() 
        self:removeSelf( )
        circles[self] = nil
        self.group:checkComplete()
    end

    return circle
end

function displayDummyCircle(dot)
    local pos = grid[dot.x][dot.y]
    local circle = display.newCircle( pos.x, pos.y, CIRCLE_RADIUS )
    function circle:touch(event)
        if (event.phase == "ended") then
            puzzleLoader:timeOver()
        end
    end
    circle:addEventListener( "touch" )
    circle:setFillColor(1, 0, 0)
    return circle
end

function displayDraggableCircle(dot, destination)
    local pos = grid[dot.x][dot.y]
    local goal = grid[destination.x][destination.y]
    local circle = display.newCircle( pos.x, pos.y, CIRCLE_RADIUS )
    local line = display.newLine( pos.x, pos.y, goal.x, goal.y )
    line.alpha = 0.5
    line:setStrokeColor( 0, 0, 0 )
    line.strokeWidth = 100
    circle.line = line
    circle:setFillColor(1, 1, 1)
    circle.alpha = 1

    function circle:touch( event )
        local xMin = math.min(pos.x, goal.x)
        local xMax = math.max(goal.x, pos.x)
        local yMin = math.min(pos.y, goal.y)
        local yMax = math.max(pos.y, goal.y)
        local phase = event.phase
        if "began" == phase then
            display.getCurrentStage():setFocus( self, event.id )
            self.isFocus = true
            -- Store initial touch position on the actual object - prevents jumping when touched
            self.xInit = self.x
            self.yInit = self.y
            self.xStart = event.x - self.x
            self.yStart = event.y - self.y
        elseif self.isFocus then 
            if "moved" == phase then
                    self.x = event.x
                    if (self.x < xMin) then self.x = xMin end
                    if (self.x > xMax) then self.x = xMax end                
     
                    self.y = event.y
                    if (self.y < yMin) then self.y = yMin end
                    if (self.y > yMax) then self.y = yMax end 
                    -- print( "t pos: " .. t.x .. " y: " .. t.y)
                    -- print( "xMax" .. xMax .. "yMax" .. yMax)
                    if (math.abs(self.x - goal.x) < EPSILON and math.abs(self.y - goal.y) < EPSILON) then
                    	puzzleLoader.score = puzzleLoader.score + 3
                        self.start:removeSelf( )
                        self.finish:removeSelf( )
                        self.line:removeSelf( )
                        self:removeSelf( )
                        self.group:checkComplete()
                    end
            elseif "ended" == phase or "cancelled" == phase then
                self.x = self.xInit
                self.y = self.yInit
                display.getCurrentStage():setFocus( self, nil )
            end
        end
        return false

    end
    circle:addEventListener( "touch" )

    return circle, line

end
function displayHole( hole )
    local pos = grid[hole.x][hole.y]
    local circle = display.newCircle( pos.x, pos.y, CIRCLE_RADIUS)
    circle:setFillColor(0, 0, 0)
    circle.strokeWidth = 5
    circle.alpha = 0.5
    return circle
end


function displayPuzzle(puzzle, background, patternGroup, dummyDotsGroup, foreground)
    local wall = display.newRect( screenCenter.x, screenCenter.y, 120, 120 )
    wall:setFillColor( 0.4 )
    wall.alpha = 1
    wall.zoomTranstion = transition.to( wall, { time=puzzleLoader.speed, xScale=10,  yScale=10, onComplete=puzzleLoader.timeOver })
    background:insert( wall )
    puzzleLoader.wall = wall
    if ( puzzle.dummyDots ~= nil ) then
        for k,dot in pairs(puzzle.dummyDots) do
            local circle = displayDummyCircle(dot)
            circle.group = dummyDotsGroup
            dummyDotsGroup:insert( circle )
            dummyCircles[#dummyCircles + 1] = circle
        end
    end
    if (puzzle.dots ~= nil) then
	    for k,dot in pairs( puzzle.dots ) do
	        local circle = displayCircle(dot)
	        circle.group = patternGroup
	        patternGroup:insert( circle )
	        circles[#circles + 1] = circle
	    end
	end

    if ( puzzle.swipes ~= nil ) then
        for k, swipe in pairs( puzzle.swipes) do
            local holeStart = displayHole( swipe.start )
            local holeFinish = displayHole( swipe.finish )
            local circle, line = displayDraggableCircle( swipe.start, swipe.finish )
            circle.start = holeStart
            circle.finish = holeFinish
            circle.group = patternGroup
            patternGroup:insert( holeStart )
            patternGroup:insert( holeFinish )
            patternGroup:insert( circle )
            background:insert( line )
        end
    end

    function patternGroup:checkComplete()
        print("Num children" .. self.numChildren)
        if ( self.numChildren == 0 ) then
            self:onComplete()
        end
    end
    function patternGroup:onComplete()
        wall:removeSelf( )
        for i = 1, #dummyCircles do
            dummyCircles[i]:removeSelf()
            dummyCircles[i] = nil
        end
        transition.cancel(wall.zoomTransition)
        wall = nil
        local puzzle = puzzleLoader:loadNextPuzzle()
        displayPuzzle(puzzle, background, patternGroup, dummyDotsGroup, foreground)
    end
    print( "Dummy numChildren" ..  dummyDotsGroup.numChildren)
end





-- "scene:create()"
function scene:create( event )

    -- Initialize the scene here
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.

    local sceneGroup = self.view
    local corridor = display.newImageRect( "assets/corridor.png", 720, 1280 )
    corridor.x = screenWidth / 2
    corridor.y = screenHeight / 2
    local background = display.newGroup( )
    background:insert (corridor )
    sceneGroup:insert( background )
    local dummyDotsGroup = display.newGroup( )
    sceneGroup:insert (dummyDotsGroup)
    local patternGroup = display.newGroup( )
    sceneGroup:insert( patternGroup )
    local foreground = display.newGroup( )
    sceneGroup:insert( foreground )
    puzzleLoader.levelText = display.newText({x=screenCenter.x , y=((display.contentHeight-display.actualContentHeight)/ 2) + 50 , text=puzzleLoader.level ,fontSize=80 ,font=native.systemFontBold})
    foreground:insert (puzzleLoader.levelText)
    local puzzle = puzzleLoader:loadNextPuzzle()
    displayPuzzle(puzzle, background, patternGroup, dummyDotsGroup, foreground)
    puzzleLoader.tapSound = audio.loadSound( "assets/tap.mp3" )
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