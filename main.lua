require("src/player")
require("src/map")
require("src/enemies/enemy_spawner")
require("src/sounds")
require("src/stairs")
require("src/weapons/sword")

function love.load()
	-- Print to console
	io.stdout:setvbuf("no")

	-- Set the title
	love.window.setTitle("Slime Game")

	-- Windfield physics library
	wf = require("libraries/Windfield")
	world = wf.newWorld(0, 0)

	-- Collision classes
	world:addCollisionClass("Obstacle", { collidesWith = { "Enemy", "Player" } })
	world:addCollisionClass("Player", { collidesWith = { "Obstacle", "Enemy" } })
	world:addCollisionClass("Enemy", { collidesWith = { "Obstacle", "Player" } })
	world:addCollisionClass("Stairs", { collidesWith = { "Player" } })
	world:addCollisionClass(
		"Player Weapon",
		{ collidesWith = { "Enemy" }, ignores = { "Player", "Obstacle", "Stairs" } }
	)
	world:addCollisionClass("None", { ignores = { "Enemy", "Player", "Obstacle", "Stairs" } })

	--list of maps
	local mapList = {
		{ file = "maps/floor1_1.lua", playerStart = { x = 50, y = 50 }, stairsStart = { x = 100, y = 270 } },
		{ file = "maps/floor1_2.lua", playerStart = { x = 50, y = 50 }, stairsStart = { x = 50, y = 250 } },
		{ file = "maps/floor1_3.lua", playerStart = { x = 155, y = 50 }, stairsStart = { x = 150, y = 250 } },
		{ file = "maps/floor1_4.lua", playerStart = { x = 155, y = 50 }, stairsStart = { x = 150, y = 150 } },
		{ file = "maps/floor1_5.lua", playerStart = { x = 45, y = 50 }, stairsStart = { x = 50, y = 270 } },
		{ file = "maps/floor1_6.lua", playerStart = { x = 45, y = 50 }, stairsStart = { x = 50, y = 250 } },
		{ file = "maps/floor1_7.lua", playerStart = { x = 155, y = 20 }, stairsStart = { x = 150, y = 150 } },
		{ file = "maps/floor1_8.lua", playerStart = { x = 50, y = 50 }, stairsStart = { x = 150, y = 150 } },
		{ file = "maps/floor1_9.lua", playerStart = { x = 60, y = 50 }, stairsStart = { x = 150, y = 150 } },
		{ file = "maps/floor1_10.lua", playerStart = { x = 50, y = 50 }, stairsStart = { x = 150, y = 50 } },
		{ file = "maps/floor2_1.lua", playerStart = { x = 40, y = 50 }, stairsStart = { x = 270, y = 20 } },
		{ file = "maps/floor2_2.lua", playerStart = { x = 50, y = 50 }, stairsStart = { x = 153, y = 150 } },
		{ file = "maps/floor2_3.lua", playerStart = { x = 155, y = 155 }, stairsStart = { x = 150, y = 280 } },
		{ file = "maps/floor2_4.lua", playerStart = { x = 50, y = 50 }, stairsStart = { x = 273, y = 270 } },
		{ file = "maps/floor2_5.lua", playerStart = { x = 160, y = 40 }, stairsStart = { x = 153, y = 278 } },
		{ file = "maps/floor2_6.lua", playerStart = { x = 50, y = 50 }, stairsStart = { x = 150, y = 290 } },
		{ file = "maps/floor2_7.lua", playerStart = { x = 50, y = 50 }, stairsStart = { x = 270, y = 280 } },
		{ file = "maps/floor2_8.lua", playerStart = { x = 50, y = 50 }, stairsStart = { x = 280, y = 280 } },
		{ file = "maps/floor2_9.lua", playerStart = { x = 50, y = 50 }, stairsStart = { x = 280, y = 280 } },
		{ file = "maps/floor2_10.lua", playerStart = { x = 50, y = 50 }, stairsStart = { x = 280, y = 280 } },
	}

	-- Camera library
	camera = require("libraries/camera")

	-- Map (load default map)
	Map:load(mapList[1].file)

	-- Camera
	cam = camera()

	-- Calculate scale to fit the screen
	local screenWidth, screenHeight = love.graphics.getDimensions()
	local mapWidth = Map.gameMap.width * Map.gameMap.tilewidth
	local mapHeight = Map.gameMap.height * Map.gameMap.tileheight

	local scaleX = screenWidth / mapWidth
	local scaleY = screenHeight / mapHeight

	-- Set the scale to the smaller of the two to maintain aspect ratio
	cam.scale = math.min(scaleX, scaleY)

	-- Game
	Game = {
		state = "running", -- Possible states: "running", "fading", "game_over"
		fadeTimer = 1, -- Time in seconds for fading
		fadeAlpha = 1, -- Initial alpha for fading
		sound = love.audio.newSource("sounds/music/game_over.wav", "static"),
	}

	-- Stairs(list of maps)
	Stairs:load(mapList)

	-- Player
	Player:load(Sword)
	Player.collider:setPosition(mapList[1].playerStart.x, mapList[1].playerStart.y)

	-- Sword
	Sword:load(Player)

	-- Sounds
	Sounds:load("sounds/music/title.wav")
end

function love.update(dt)
	-- Game over
	if Game.state == "fading" then
		Game.fadeTimer = Game.fadeTimer - dt

		if Game.fadeTimer > 0 then
			Game.fadeAlpha = Game.fadeTimer -- Adjust alpha over time
		else
			Game.fadeAlpha = 0
			Game.state = "game_over" -- Transition to "game_over"
			Sounds.currentSong:stop()
			Game.sound:play()
		end

		return
	end

	-- Game is running
	if Game.state == "running" then
		-- Map
		Map:update(dt)

		-- Player
		-- TODO pass all enemies into player
		Player:update(dt, enemies)

		-- Sword
		Sword:update(dt)

		-- Enemies
		enemies:update(dt)

		-- Stairs
		Stairs:update(dt)

		-- Update world
		world:update(dt)

		-- Camera is set to the center of the map
		cam:lookAt(Map.x, Map.y)
	end
end

function love.draw()
	if Game.state == "running" or Game.state == "fading" then
		-- Draw from the camera's perspective
		cam:attach()

		-- Map
		Map:draw()

		-- Stairs
		Stairs:draw()

		-- Player
		Player:draw()

		-- Sword
		Sword:draw()

		-- Enemies
		enemies:draw()

		-- Draw world colliders
		world:draw()

		-- Detach camera
		cam:detach()
	end

	if Game.state == "fading" then
		-- Fade effect
		love.graphics.setColor(0, 0, 0, 1 - Game.fadeAlpha) -- Black fade-in
		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
		love.graphics.setColor(1, 1, 1, 1) -- Reset color
	end

	if Game.state == "game_over" then
		-- Black background
		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

		-- "You Died" message
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.setFont(love.graphics.newFont(32))
		love.graphics.printf("You Died", 0, love.graphics.getHeight() / 3, love.graphics.getWidth(), "center")

		-- Draw "Continue" button
		local buttonWidth, buttonHeight = 200, 50
		local buttonX = (love.graphics.getWidth() - buttonWidth) / 2
		local buttonY = love.graphics.getHeight() / 2
		love.graphics.rectangle("fill", buttonX, buttonY, buttonWidth, buttonHeight)
		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.printf("Continue", buttonX, buttonY + 10, buttonWidth, "center")
	end
end

function love.mousepressed(x, y, button)
	if button == 1 and Game.state == "game_over" then
		-- Button dimensions
		local buttonWidth, buttonHeight = 200, 50
		local buttonX = (love.graphics.getWidth() - buttonWidth) / 2
		local buttonY = love.graphics.getHeight() / 2

		-- Check if the mouse is inside the button bounds
		if x > buttonX and x < buttonX + buttonWidth and y > buttonY and y < buttonY + buttonHeight then
			resetGame()
		end
	end
end

function resetGame()
	-- Stop game over sound
	Game.sound:stop()

	-- Reset game state variables
	Game.state = "running"
	Game.fadeTimer = 1
	Game.fadeAlpha = 1

	-- Reset player
	Stairs.currentMapIndex = 1
	local firstMap = Stairs.maplist[Stairs.currentMapIndex]
	Player.health = 5
	Player.collider:setPosition(firstMap.playerStart.x, firstMap.playerStart.y)
	Player.invincible = false
	Player.isFlashing = false
	Player.anim = Player.animations.right

	-- Reset stairs
	Stairs.x = firstMap.stairsStart.x
	Stairs.y = firstMap.stairsStart.y
	Stairs.collider:setPosition(Stairs.x + 8, Stairs.y + 8)
	Stairs.locked = true
	Stairs.stairSprite = love.graphics.newImage("sprites/level/trap_door.png")

	-- Reset enemies
	enemies:reset()

	-- Reset map
	Map:load(firstMap.file)

	-- Reset music
	Sounds:load("sounds/music/title.wav")
end
