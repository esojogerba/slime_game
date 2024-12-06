Player = {}

function Player:load()
	-- Anim8 library
	anim8 = require("libraries/anim8")

	-- Smooth scaling
	love.graphics.setDefaultFilter("nearest", "nearest")

	-- Collider
	self.collider = world:newBSGRectangleCollider(50, 50, 15, 15, 2)
	self.collider:setCollisionClass("Player")
	self.collider:setFixedRotation(true)

	-- Position
	self.x = 0
	self.y = 0

	-- Speed
	self.speed = 100

	-- Health
	self.health = 5

	-- Sprite and grid
	self.spriteSheet = love.graphics.newImage("sprites/mainSlime.png")
	self.grid = anim8.newGrid(12, 10, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())

	-- Animations
	self.animations = {}
	self.animations.left = anim8.newAnimation(self.grid("1-4", 1), 0.2)
	self.animations.right = anim8.newAnimation(self.grid("1-4", 2), 0.2)
	self.animations.up = anim8.newAnimation(self.grid("1-4", 3), 0.2)
	self.animations.down = self.animations.right

	-- Player's current animation
	self.anim = self.animations.right
end

function Player:update(dt)
	-- Player movement with arrow keys
	self:move(dt)

	-- Match player position with collider position
	self.x = self.collider:getX()
	self.y = self.collider:getY()

	-- Update animation
	self.anim:update(dt)

	-- Enemy collisions
	if self.collider:enter("Enemy") then
		Player:enemyCollision()
	end
end

-- Player movement with arrow keys
function Player:move(dt)
	-- Velocities
	local vx = 0
	local vy = 0

	-- Player moves right
	if love.keyboard.isDown("right") then
		vx = self.speed
		self.anim = self.animations.right
		self.animations.down = self.animations.right
	end
	-- Player moves left
	if love.keyboard.isDown("left") then
		vx = self.speed * -1
		self.anim = self.animations.left
		self.animations.down = self.animations.left
	end
	-- Player moves up
	if love.keyboard.isDown("up") then
		vy = self.speed * -1
		self.anim = self.animations.up
	end
	-- Player moves down
	if love.keyboard.isDown("down") then
		vy = self.speed
		self.anim = self.animations.down
	end
	-- Player moves in a diagonal direction
	if vx ~= 0 and vy ~= 0 then
		local magnitude = math.sqrt(vx * vx + vy * vy)
		vx = (vx / magnitude) * self.speed
		vy = (vy / magnitude) * self.speed
	end

	-- Update linear velocity of collider depending on key pressed
	self.collider:setLinearVelocity(vx, vy)

	self.anim:update(dt)
end

-- Take damage from enemies when collision occurs
function Player:enemyCollision()
	self.health = Player.health - 1
	print("Player collided with Enemy!")
	print("Player's Health: ", self.health)

	-- Fade to game over screen if player has died
	if self.health <= 0 and Game.state == "running" then
		Game.state = "fading"
		Game.fadeTimer = 1 -- Reset fade timer
		Game.fadeAlpha = 1 -- Reset fade alpha
	end
end

function Player:draw()
	if Game.isGameOver then
		-- Fade sprite by applying the alpha value
		love.graphics.setColor(0, 0, 0, Game.fadeAlpha) -- Black fade
	else
		love.graphics.setColor(1, 1, 1, 1) -- Normal color
	end

	self.anim:draw(self.spriteSheet, self.x, self.y, nil, 2, 2, 6, 5)
end
