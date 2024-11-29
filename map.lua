Map = {}

function Map:load()
	-- STI library
	sti = require("libraries/sti")

	-- Map
	self.gameMap = sti("maps/square_map.lua")
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
end

function Map:update(dt) end

function Map:draw()
	-- Draw map in layers
	self.gameMap:drawLayer(self.gameMap.layers["Floor"])
	self.gameMap:drawLayer(self.gameMap.layers["Obstacles"])
end
