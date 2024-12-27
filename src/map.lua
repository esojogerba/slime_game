require("src/enemies/enemy_spawner")

Map = {}

-- STI library
sti = require("libraries/sti")

function Map:load(mapFile)
	-- Clear existing map data
	self:unload()

	-- Map
	self.gameMap = sti(mapFile)

	self.x = (self.gameMap.width * self.gameMap.tilewidth) / 2
	self.y = (self.gameMap.height * self.gameMap.tileheight) / 2

	-- Wall layer
	walls = {}

	if self.gameMap.layers["Walls"] then
		for i, obj in pairs(self.gameMap.layers["Walls"].objects) do
			local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
			wall:setType("static")
			wall:setCollisionClass("Obstacle")
			table.insert(walls, wall)
		end
	end

	if self.gameMap.layers["Enemies"] then
		for i, obj in pairs(self.gameMap.layers["Enemies"].objects) do
			spawnEnemy(obj.x, obj.y, obj.name)
		end
	end
end

function Map:unload()
	-- Remove collision objects
	if walls then
		for _, wall in pairs(walls) do
			if wall and wall.body then
				wall:destroy()
			end
		end
		walls = {}
	end
	-- Clear map data
	self.gameMap = nil
end

function Map:update(dt)
	if self.gameMap then
		self.gameMap:update(dt)
	end
end

function Map:draw()
	if self.gameMap then
		-- Draw map in layers
		if self.gameMap.layers["Floor"] then
			self.gameMap:drawLayer(self.gameMap.layers["Floor"])
		end
		if self.gameMap.layers["Obstacles"] then
			self.gameMap:drawLayer(self.gameMap.layers["Obstacles"])
		end
	end
end
