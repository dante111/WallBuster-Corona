-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

local screenWidth, screenHeight = display.contentWidth, display.contentHeight
local screenCenter = { x = screenWidth / 2, y = screenHeight / 2 }

local GRID_WIDTH = 3
local GRID_HEIGHT = 3
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
	end
end

local puzzles = require( "puzzles" )
puzzleLoader = {}
puzzleLoader.puzzles = puzzles
puzzleLoader.level = 0
puzzleLoader.speed = 7000
puzzleLoader.timeOver = function (obj)
	print( "Time over")
	print( obj )
end

puzzleLoader.gameOver = function ()
	
end
function puzzleLoader:loadNextPuzzle()
	self.level = self.level + 1
	print (self.level)
	if (RANDOM) then
		return self:generateRandomPuzzle()
	end
	puzzle = require( self.puzzles[self.level] )
	return puzzle
end

function puzzleLoader:generateRandomPuzzle()
	puzzle = {
		dots = {
			{x=math.random( GRID_WIDTH ), y=math.random( GRID_HEIGHT ), taps=math.random( 2 )},
			{x=math.random( GRID_WIDTH ), y=math.random( GRID_HEIGHT ), taps=math.random( 2 )},
			{x=math.random( GRID_WIDTH ), y=math.random( GRID_HEIGHT ), taps=math.random( 2 )}
		},
	}
	return puzzle
end	


local function displayCircle(dot) 
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
		self.alpha = 0.5
		self:removeEventListener( "tap", self.tapListener )
		self.group:checkComplete()
	end

	return circle
end


function displayPuzzle(puzzle)
	local wall = display.newRect( screenCenter.x, screenCenter.y, 120, 120 )
	wall:setFillColor( 0.4 )
	wall.alpha = 1
	wall.zoomTranstion = transition.to( wall, { time=puzzleLoader.speed, xScale=12, yScale=12, onComplete=puzzleLoader.timeOver })
	local patternGroup = display.newGroup( )
	for k,dot in pairs(puzzle.dots) do
		circle = displayCircle(dot)
		circle.group = patternGroup
		patternGroup:insert( circle )
	end
	function patternGroup:checkComplete()
		print( "Checking group" )
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
		displayPuzzle(puzzle)
	end
end

local corridor = display.newImageRect( "assets/corridor.png", 720, 1280 )

corridor.x = screenWidth / 2
corridor.y = screenHeight / 2


-- circle = display.newCircle( screenCenter.x, screenCenter.y, CELL_WIDTH / 2 )
-- circle:setFillColor( 0 )
-- circle.alpha = 1
-- circle:addEventListener( "tap", patternListener )


-- circle2 = display.newCircle( screenCenter.x + 50, screenCenter.y + 50, CELL_WIDTH / 2 )
-- circle2:setFillColor( 0 )
-- circle2.alpha = 1
-- circle2:addEventListener( "tap", patternListener )

local puzzle = puzzleLoader:loadNextPuzzle()

displayPuzzle(puzzle)

