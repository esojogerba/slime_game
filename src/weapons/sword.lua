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
	self.isActive = true -- Sword is only active during an attack
end

function Sword:update(dt)
	-- Move sprite depending on player's position
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

function Sword:move()
	local offsetX, offsetY = 0, 0

	-- Update sword position based on player's position and facing direction
	if self.player.anim == self.player.animations.up then
		offsetY = -12
	elseif self.player.anim == self.player.animations.down then
		offsetY = 12
	elseif self.player.anim == self.player.animations.left then
		offsetX = -12
	elseif self.player.anim == self.player.animations.right then
		offsetX = 12
	end

	self.collider:setPosition(self.player.x + offsetX, self.player.y + offsetY)
end

function Sword:draw()
	local spriteOffsetX = self.sprite:getWidth() / 2
	local spriteOffsetY = self.sprite:getHeight() / 2
	-- Only draw sword if it is currently active
	if self.isActive then
		love.graphics.draw(self.sprite, self.x - spriteOffsetX, self.y - spriteOffsetY)
	end
end
