require("src/player")

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

	-- Health
	self.health = 10

	-- Damage cooldown
	self.damageCooldown = 0.5 -- Time in seconds before the enemy can take damage again
	self.damageCooldownTimer = 0 -- Tracks the remaining cooldown time

	-- Enemy damage recoil
	self.recoilDuration = 0.2 -- Duration of recoil effect
	self.recoilTimer = 0 -- Timer for recoil
	self.recoilDirection = { x = 0, y = 0 } -- Direction to recoil

	-- Death status
	self.death_status = false

	-- Sprite and grid
	self.spriteSheet = love.graphics.newImage("sprites/enemies/brownSlime.png")
	self.grid = anim8.newGrid(12, 10, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())

	-- Animations
	self.animations = {}
	self.animations.left = anim8.newAnimation(self.grid("1-4", 1), 0.2)
	self.animations.right = anim8.newAnimation(self.grid("1-4", 2), 0.2)
	self.animations.up = anim8.newAnimation(self.grid("1-4", 3), 0.2)
	self.animations.down = self.animations.right
	self.anim = self.animations.right

	-- TODO Sounds

	-- Damage
	self.damage_sound = love.audio.newSource("sounds/enemies/enemy_damage.wav", "static")

	-- Death
	self.death_sound = love.audio.newSource("sounds/enemies/enemy_death.wav", "static")
end

function Enemy:update(dt, player, sword)
	if not self.death_status then
		-- Update the damage cooldown timer
		if self.damageCooldownTimer > 0 then
			self.damageCooldownTimer = self.damageCooldownTimer - dt
		end

		-- Recoil from damage or move normally
		if self.recoilTimer > 0 then
			-- Apply recoil movement
			local vx = self.recoilDirection.x * self.speed * 1
			local vy = self.recoilDirection.y * self.speed * 1
			self.collider:setLinearVelocity(vx, vy)
			self.recoilTimer = self.recoilTimer - dt
		else
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
		end

		-- Update x and y variables using collider's position
		self.x, self.y = self.collider:getPosition()

		self.anim:update(dt)

		-- Take damage from player's weapon
		if self.damageCooldownTimer <= 0 and self.collider:enter("Player Weapon") then
			self:weaponCollision(1, sword, self.death_status)
		end
	end
end

function Enemy:weaponCollision(damage, sword, death_status)
	-- If enemy is not dead
	if not death_status then
		-- Decrease enemy's health
		self.health = self.health - damage
		print("Enemy damaged, health: ", self.health)

		-- Play damage sound
		self.damage_sound:play()

		-- Stop moving towards player
		self.collider:setLinearVelocity(0, 0)

		-- TODO Damage flash

		-- TODO Damage recoil
		-- Recoil variables
		local sword_x, sword_y = sword.collider:getPosition()
		local dx = self.x - sword_x
		local dy = self.y - sword_y
		local magnitude = math.sqrt(dx * dx + dy * dy)

		-- If enemy is not dead, calculate recoil
		if self.health > 0 then
			local recoilMultiplier = 3
			self.recoilDirection.x = (dx / magnitude) * recoilMultiplier
			self.recoilDirection.y = (dy / magnitude) * recoilMultiplier
			self.recoilTimer = self.recoilDuration
		end

		-- If enemy is out of health
		if self.health <= 0 then
			-- Trigger death status
			self.death_status = true
			-- Destroy collider
			self.collider:destroy()
			-- Play death sound
			self.death_sound:play()
		end

		-- Apply damage cooldown
		self.damageCooldownTimer = self.damageCooldown
	end
end

function Enemy:draw()
	if not self.death_status then
		self.anim:draw(self.spriteSheet, self.x, self.y, nil, 2, 2, 6, 5)
	end
end
