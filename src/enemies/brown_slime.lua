require("src/player")
require("src/weapons/sword")

local function brownInit(enemy, x, y)
	-- Anim8 library
	anim8 = require("libraries/anim8")

	-- Smooth scaling
	love.graphics.setDefaultFilter("nearest", "nearest")

	-- Collider
	enemy.collider = world:newBSGRectangleCollider(x, y, 15, 15, 2)
	enemy.collider:setCollisionClass("Enemy")
	enemy.collider:setFixedRotation(true)

	-- Position
	enemy.x = x
	enemy.y = y

	-- Speed
	enemy.speed = 50

	-- Damage to player
	enemy.damage = 1

	-- Health
	enemy.health = 3

	-- Sprite and grid
	enemy.spriteSheet = love.graphics.newImage("sprites/enemies/brownSlime.png")
	enemy.grid = anim8.newGrid(12, 10, enemy.spriteSheet:getWidth(), enemy.spriteSheet:getHeight())

	-- Animations
	enemy.animations = {}
	enemy.animations.left = anim8.newAnimation(enemy.grid("1-4", 1), 0.2)
	enemy.animations.right = anim8.newAnimation(enemy.grid("1-4", 2), 0.2)
	enemy.animations.up = anim8.newAnimation(enemy.grid("1-4", 3), 0.2)
	enemy.animations.down = enemy.animations.right
	enemy.anim = enemy.animations.right

	function enemy:move(player)
		-- Distances from player
		local dx = player.x - enemy.collider:getX()
		local dy = player.y - enemy.collider:getY()
		local distance = math.sqrt(dx * dx + dy * dy)

		-- Enemy's detection range
		local detectionRange = 100

		-- If within detection range, move towards player
		if distance < detectionRange then
			local directionX = dx / distance
			local directionY = dy / distance

			enemy.collider:setLinearVelocity(directionX * enemy.speed, directionY * enemy.speed)

			if math.abs(directionX) > math.abs(directionY) then
				if directionX > 0 then
					enemy.anim = enemy.animations.right
				else
					enemy.anim = enemy.animations.left
				end
			else
				if directionY > 0 then
					enemy.anim = enemy.animations.down
				else
					enemy.anim = enemy.animations.up
				end
			end
		-- Else, remain still
		else
			enemy.collider:setLinearVelocity(0, 0)
		end
	end

	function enemy:weaponCollision(damage, sword, death_status)
		-- If enemy is not dead
		if not death_status then
			-- Decrease enemy's health
			enemy.health = enemy.health - damage

			-- Play damage sound
			enemy.damage_sound:play()

			-- Stop moving
			enemy.collider:setLinearVelocity(0, 0)

			-- Make sprite flash grey
			enemy.isFlashing = true
			enemy.flashTimer = 0.2

			-- Recoil variables
			local sword_x, sword_y = sword.collider:getPosition()
			local dx = enemy.x - sword_x
			local dy = enemy.y - sword_y
			local magnitude = math.sqrt(dx * dx + dy * dy)

			-- If enemy is not dead, calculate recoil
			if enemy.health > 0 then
				local recoilMultiplier = 3
				enemy.recoilDirection.x = (dx / magnitude) * recoilMultiplier
				enemy.recoilDirection.y = (dy / magnitude) * recoilMultiplier
				enemy.recoilTimer = enemy.recoilDuration
			end

			-- If enemy is out of health
			if enemy.health <= 0 then
				-- Trigger death status
				enemy.death_status = true
				-- Stop movement
				enemy.collider:setLinearVelocity(0, 0)
				-- Destroy collider
				enemy.collider:destroy()
				-- Play death sound
				enemy.death_sound:play()
			end

			-- Apply damage cooldown
			enemy.damageCooldownTimer = enemy.damageCooldown
		end
	end

	function enemy:update(dt)
		if not enemy.death_status then
			-- Update the damage cooldown timer
			if enemy.damageCooldownTimer > 0 then
				enemy.damageCooldownTimer = enemy.damageCooldownTimer - dt
			end

			-- Recoil from damage or move normally
			if enemy.recoilTimer > 0 then
				-- Apply recoil movement
				local vx = enemy.recoilDirection.x * enemy.speed * 1
				local vy = enemy.recoilDirection.y * enemy.speed * 1
				enemy.collider:setLinearVelocity(vx, vy)
				enemy.recoilTimer = enemy.recoilTimer - dt
			else
				enemy:move(Player)
			end

			-- Update flashing effect
			if enemy.isFlashing then
				enemy.flashTimer = enemy.flashTimer - dt
				if enemy.flashTimer <= 0 then
					enemy.isFlashing = false
				end
			end

			-- Update x and y variables using collider's position
			enemy.x, enemy.y = enemy.collider:getPosition()

			enemy.anim:update(dt)

			-- Take damage from player's weapon
			if enemy.damageCooldownTimer <= 0 and enemy.collider:enter("Player Weapon") then
				enemy:weaponCollision(1, Sword, enemy.death_status)
			end
		elseif enemy.death_status then
			-- Gradually reduce the alpha during the fade-out period
			if enemy.fadeAlpha > 0 then
				enemy.fadeAlpha = enemy.fadeAlpha - (dt / enemy.fadeDuration)
			else
				-- Ensure alpha does not go below 0
				enemy.fadeAlpha = 0
			end
			return -- Skip normal behavior when the enemy is dead
		end
	end

	function enemy:draw()
		if not enemy.death_status or enemy.fadeAlpha > 0 then
			-- Set enemy color based on flashing state
			if enemy.isFlashing then
				-- Flash opacity
				love.graphics.setColor(0, 0, 0, enemy.fadeAlpha * 0.4)
			else
				-- Normal color
				love.graphics.setColor(255, 255, 255, enemy.fadeAlpha)
			end

			enemy.anim:draw(enemy.spriteSheet, enemy.x, enemy.y, nil, 2, 2, 6, 5)

			-- Normal color
			love.graphics.setColor(255, 255, 255, 1)
		end
	end

	return enemy
end

return brownInit
