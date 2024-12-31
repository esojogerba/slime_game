require("src/player")
require("src/map")
require("src/enemies/enemy_spawner")

Stairs = {}

function Stairs:load(mapList)
	-- Smooth scaling
	love.graphics.setDefaultFilter("nearest", "nearest")

	--load stairs sprite
	self.stairSprite = love.graphics.newImage("sprites/level/trap_door.png")
	self.locked = true

	--hard code stair position (needs work)
	self.x = mapList[1].stairsStart.x
	self.y = mapList[1].stairsStart.y

	--set stairs collider
	self.collider = world:newRectangleCollider(self.x, self.y, 16, 16)
	self.collider:setCollisionClass("Stairs")
	self.collider:setType("static")
	self.collider:setFixedRotation(true)

	--map cycling
	self.maplist = mapList or {}
	self.currentMapIndex = 1

	-- make img clean
	love.graphics.setDefaultFilter("nearest", "nearest")
end

function Stairs:update(dt)
	--if player touches stairs sprite changes if stairs open level changes
	--(TODO change when all enemies dead)
	if enemies[1] == nil then
		self.stairSprite = love.graphics.newImage("sprites/level/stairs.png")
		self.locked = false
	end
	if self.collider:enter("Player") and self.locked == false then
		self:advanceToNextMap()
	end
end

--update map index
function Stairs:advanceToNextMap()
	self.currentMapIndex = self.currentMapIndex + 1

	--check if game has been won
	if self.currentMapIndex > 20 then
		print("Congratulations you won!!")
		return
	end

	--pass new map to change level function
	self:changeLevel(self.currentMapIndex)
end

-- Switch map and reload associated objects
function Stairs:changeLevel(nextMapIndex)
	--retrieve next map
	local nextMap = self.maplist[nextMapIndex]

	-- Clean up the current map objects
	Map:unload()

	-- Load the new map
	Map:load(nextMap.file)

	--Set player starting position
	Player.collider:setPosition(nextMap.playerStart.x, nextMap.playerStart.y)

	--Set stairs starting position
	self.x = nextMap.stairsStart.x
	self.y = nextMap.stairsStart.y
	self.collider:setPosition(self.x + 8, self.y + 8)

	-- Reset stairs for the new map (if reused in multiple levels)
	--Needs work
	self.locked = true
	self.stairSprite = love.graphics.newImage("sprites/level/trap_door.png")
end

function Stairs:draw()
	--draw stairs
	love.graphics.draw(self.stairSprite, self.x, self.y)
end
