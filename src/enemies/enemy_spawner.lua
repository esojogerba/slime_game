require("src/player")
require("src/weapons/sword")

enemies = {}

function spawnEnemy(x, y, type)
	local enemy = {}

	-- Anim8 library
	anim8 = require("libraries/anim8")

	-- Smooth scaling
	love.graphics.setDefaultFilter("nearest", "nearest")

	-- Type
	enemy.type = type

	-- Position
	enemy.x = x
	enemy.y = y

	-- Speed
	enemy.speed = 50

	-- Health
	enemy.health = 5

	-- Damage cooldown
	enemy.damageCooldown = 0.5 -- Time in seconds before the enemy can take damage again
	enemy.damageCooldownTimer = 0 -- Tracks the remaining cooldown time

	-- Damage flash
	enemy.flashTimer = 0 -- Timer for opacity flash effect
	enemy.isFlashing = false -- Whether the enemy is flashing

	-- Enemy damage recoil
	enemy.recoilDuration = 0.2 -- Duration of recoil effect
	enemy.recoilTimer = 0 -- Timer for recoil
	enemy.recoilDirection = { x = 0, y = 0 } -- Direction to recoil

	-- Death status
	enemy.death_status = false

	-- Fade-out effect
	enemy.fadeAlpha = 1 -- Fully opaque at the start
	enemy.fadeDuration = 0.3 -- Fade-out duration in seconds

	-- Damage
	enemy.damage_sound = love.audio.newSource("sounds/enemies/enemy_damage.wav", "static")

	-- Death
	enemy.death_sound = love.audio.newSource("sounds/enemies/enemy_death.wav", "static")

	-- Function that sets the properties of the new enemy
	local init
	if type == "brownSlime" then
		init = require("src/enemies/brown_slime")
	elseif type == "blueSlime" then
		init = require("src/enemies/blue_slime")
	end

	enemy = init(enemy, x, y)

	table.insert(enemies, enemy)

	if enemy then
		print("Enemy: ", type)
	end
end

function enemies:update(dt)
	-- Calls update functions on all enemies
	for i, e in ipairs(self) do
		e:update(dt)
	end

	-- Iterate through all enemies in reverse to remove the dead ones
	for i = #enemies, 1, -1 do
		if enemies[i].dead then
			table.remove(enemies, i)
		end
	end
end

function enemies:draw()
	for i, e in ipairs(self) do
		e:draw()
	end
end
