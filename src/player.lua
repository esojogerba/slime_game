Player = {}

function Player:load(sword)
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
	self.max_hearts = 5
	self.health = self.max_hearts
	self.invincible = false

	-- Player damage flash
	self.flashTimer = 0 -- Timer for opacity flash effect
	self.isFlashing = false -- Whether the player is flashing

	-- Player damage recoil
	self.recoilDuration = 0.2 -- Duration of recoil effect
	self.recoilTimer = 0 -- Timer for recoil
	self.recoilDirection = { x = 0, y = 0 } -- Direction to recoil

	-- Sprite and grid
	self.spriteSheet = love.graphics.newImage("sprites/player/mainSlime.png")
	self.grid = anim8.newGrid(12, 10, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())

	-- Animations
	self.animations = {}
	self.animations.left = anim8.newAnimation(self.grid("1-4", 1), 0.2)
	self.animations.right = anim8.newAnimation(self.grid("1-4", 2), 0.2)
	self.animations.up = anim8.newAnimation(self.grid("1-4", 3), 0.2)
	self.animations.down = self.animations.right

	-- Player's current animation
	self.anim = self.animations.right

	-- Player's current direction
	self.curr_direction = "right"

	-- Player's sword
	self.sword = Sword
	self.sword:load(self)

	-- TODO Sounds

	-- Damage
	self.damage_sound = love.audio.newSource("sounds/player/player_damage.wav", "static")

	-- Attack
	self.sword_sound = love.audio.newSource("sounds/player/sword_swing.wav", "static")

	-- Item

	-- Use Stairs
end

function Player:update(dt, Enemy)
	-- Recoil from damage or move normally
	if self.recoilTimer > 0 then
		-- Apply recoil movement
		local vx = self.recoilDirection.x * self.speed * 1
		local vy = self.recoilDirection.y * self.speed * 1
		self.collider:setLinearVelocity(vx, vy)
		self.recoilTimer = self.recoilTimer - dt
	else
		-- Player movement with arrow keys
		self:move(dt)
	end

	-- Update flashing effect
	if self.isFlashing then
		self.flashTimer = self.flashTimer - dt
		self.invincible = true
		if self.flashTimer <= 0 then
			self.isFlashing = false
			self.invincible = false
		end
	end

	-- Match player position with collider position
	self.x = self.collider:getX()
	self.y = self.collider:getY()

	-- Update animation
	self.anim:update(dt)

	self.sword:update(dt)

	-- Handle sword attack
	if love.keyboard.isDown("space") and not self.sword.isActive and self.sword.cooldownTimer <= 0 then
		self.sword_sound:play()
		self.sword:attack(dt)
	end

	-- Enemy collisions
	if self.collider:enter("Enemy") then
		Player:enemyCollision(1, Enemy, self.invincible)
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
		self.animations.down = self.animations.right
		self.anim = self.animations.right
		self.curr_direction = "right"
	end
	-- Player moves left
	if love.keyboard.isDown("left") then
		vx = self.speed * -1
		self.animations.down = self.animations.left
		self.anim = self.animations.left
		self.curr_direction = "left"
	end
	-- Player moves up
	if love.keyboard.isDown("up") then
		vy = self.speed * -1
		self.anim = self.animations.up
		self.curr_direction = "up"
	end
	-- Player moves down
	if love.keyboard.isDown("down") then
		vy = self.speed
		self.anim = self.animations.down
		self.curr_direction = "down"
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
function Player:enemyCollision(damage, Enemy, status)
	if not status then
		-- Decrease player's health
		self.health = Player.health - damage
		print("Player collided with Enemy!")
		print("Player's Health: ", self.health)

		-- Play sound effect
		self.damage_sound:play()

		-- Make player flash grey
		self.isFlashing = true
		self.flashTimer = 1

		-- Make player recoil
		local enemy_x, enemy_y = Enemy.collider:getPosition()
		local dx = self.x - enemy_x
		local dy = self.y - enemy_y
		local magnitude = math.sqrt(dx * dx + dy * dy)

		-- If player is not dead, calculate recoil
		if self.health > 0 then
			self.recoilDirection.x = dx / magnitude
			self.recoilDirection.y = dy / magnitude
			self.recoilTimer = self.recoilDuration
		end

		-- Fade to game over screen if player has died
		if self.health <= 0 and Game.state == "running" then
			Game.state = "fading"
			Game.fadeTimer = 1 -- Reset fade timer
			Game.fadeAlpha = 1 -- Reset fade alpha
		end
	end
end

function Player:draw()
	-- Set player color based on flashing state
	if self.isFlashing then
		-- Flash opacity
		love.graphics.setColor(255, 255, 255, 0.5)
	else
		-- Normal color
		love.graphics.setColor(255, 255, 255, 1)
	end

	self.sword:draw()
	self.anim:draw(self.spriteSheet, self.x, self.y, nil, 2, 2, 6, 5)

	-- Normal color
	love.graphics.setColor(255, 255, 255, 1)
end
