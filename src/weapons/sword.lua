Sword = {}

function Sword:load(player)
	-- Smooth scaling
	love.graphics.setDefaultFilter("nearest", "nearest")

	-- Reference to the player object
	self.player = player

	-- Collider
	self.collider = world:newRectangleCollider(player.x, player.y, 16, 6)
	self.collider:setCollisionClass("Player Weapon")
	self.collider:setType("static")

	-- Position
	self.x = player.x
	self.y = player.y

	-- Sprite
	self.sprite = love.graphics.newImage("sprites/weapons/sword.png")

	-- Status
	self.isActive = false -- Sword is only active during an attack
	self.activeTimer = 0
	self.cooldownTimer = 0 -- Timer to track cooldown period

	-- Rotation
	self.rotation = 0
end

function Sword:update(dt)
	-- Handle the sword's timer
	if self.isActive then
		self.activeTimer = self.activeTimer - dt -- Decrease timer by delta time
		if self.activeTimer <= 0 then
			self.isActive = false -- Deactivate sword after 2 seconds
		end
	end

	-- Handle the cooldown timer
	if self.cooldownTimer > 0 then
		self.cooldownTimer = self.cooldownTimer - dt
	end

	-- Rotate sword sprite depending on player's direction
	self:move()

	-- Match sword's position with collider position
	self.x = self.collider:getX()
	self.y = self.collider:getY()

	-- Deactivate the sword collider when not attacking
	if not self.isActive then
		self.collider:setCollisionClass("None") -- Temporarily disable collision
	else
		self.collider:setCollisionClass("Player Weapon") -- Enable collision when attacking
	end
end

-- Rotate sword sprite depending on player's direction
function Sword:move()
	local offsetX, offsetY = 0, 0

	-- Update sword position and rotation based on player's direction
	if self.player.curr_direction == "up" then
		offsetY = -24 -- Offset behind the player
		offsetX = -3 -- Center
		self.rotation = -math.pi / 2 -- Rotate 90 degrees counterclockwise
		self.collider:destroy()
		self.collider = world:newRectangleCollider(self.player.x + offsetX, self.player.y + offsetY, 6, 16)
	elseif self.player.curr_direction == "down" then
		offsetY = 8 -- Offset in front of the player
		offsetX = -3 -- Center
		self.rotation = math.pi / 2 -- Rotate 90 degrees clockwise
		self.collider:destroy()
		self.collider = world:newRectangleCollider(self.player.x + offsetX, self.player.y + offsetY, 6, 16)
	elseif self.player.curr_direction == "left" then
		offsetX = -24 -- Offset to the left
		offsetY = -2 -- Center
		self.rotation = math.pi
		self.collider:destroy()
		self.collider = world:newRectangleCollider(self.player.x + offsetX, self.player.y + offsetY, 16, 6)
	elseif self.player.curr_direction == "right" then
		offsetX = 8 -- Offset to the right
		offsetY = -2 -- Center
		self.rotation = 0
		self.collider:destroy()
		self.collider = world:newRectangleCollider(self.player.x + offsetX, self.player.y + offsetY, 16, 6)
	end

	-- Deactivate the sword collider when not attacking
	if not self.isActive then
		self.collider:setCollisionClass("None") -- Temporarily disable collision
	else
		self.collider:setCollisionClass("Player Weapon") -- Enable collision when attacking
	end

	self.collider:setType("static")
end

-- Activates weapon collision class and active timer to deal damage to enemies
function Sword:attack(dt)
	if self.cooldownTimer <= 0 then
		self.isActive = true
		self.activeTimer = 1 -- Sword is active for 1 second
		self.cooldownTimer = 1.2 -- Cooldown duration (e.g., 1 second)
	end
end

function Sword:draw()
	local spriteOffsetX = self.sprite:getWidth() / 2
	local spriteOffsetY = self.sprite:getHeight() / 2

	-- Only draw sword if it is currently active
	if self.isActive then
		love.graphics.draw(
			self.sprite,
			self.x,
			self.y,
			self.rotation, -- Apply rotation
			1,
			1, -- Scale
			spriteOffsetX,
			spriteOffsetY -- Center sprite at the rotation point
		)
	end
end
