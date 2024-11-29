require("player")

Enemy = {}

function Enemy:load()
	-- Anim8 library
	anim8 = require("libraries/anim8")

	-- Smooth scaling
	love.graphics.setDefaultFilter("nearest", "nearest")

	-- Collider
	self.collider = world:newBSGRectangleCollider(250, 250, 15, 15, 2)
	self.collider:setCollisionClass("Enemy")
	self.collider:setFixedRotation(true)

	-- Position
	self.x = 300
	self.y = 300

	-- Speed
	self.speed = 50

	-- Sprite and grid
	self.spriteSheet = love.graphics.newImage("sprites/brownSlime.png")
	self.grid = anim8.newGrid(12, 10, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())

	-- Animations
	self.animations = {}
	self.animations.left = anim8.newAnimation(self.grid("1-4", 1), 0.2)
	self.animations.right = anim8.newAnimation(self.grid("1-4", 2), 0.2)
	self.animations.up = anim8.newAnimation(self.grid("1-4", 3), 0.2)
	self.animations.down = self.animations.right
	self.anim = self.animations.right
end

function Enemy:update(dt, player)
	-- Distances from player
	local dx = player.x - self.collider:getX()
	local dy = player.y - self.collider:getY()
	local distance = math.sqrt(dx * dx + dy * dy)

	-- Enemy's detection range
	local detectionRange = 100

	-- If within detection range, move towards player
	if distance < detectionRange then
		local directionX = dx / distance
		local directionY = dy / distance

		self.collider:setLinearVelocity(directionX * self.speed, directionY * self.speed)

		if math.abs(directionX) > math.abs(directionY) then
			if directionX > 0 then
				self.anim = self.animations.right
			else
				self.anim = self.animations.left
			end
		else
			if directionY > 0 then
				self.anim = self.animations.down
			else
				self.anim = self.animations.up
			end
		end
	-- Else, remain still
	else
		self.collider:setLinearVelocity(0, 0)
	end

	-- Update x and y variables using collider's position
	self.x, self.y = self.collider:getPosition()

	self.anim:update(dt)
end

function Enemy:draw()
	self.anim:draw(self.spriteSheet, self.x, self.y, nil, 2, 2, 6, 5)
end
