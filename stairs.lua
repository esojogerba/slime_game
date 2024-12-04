require("player")

Stairs = {}

function Stairs:load()
    --load stairs sprite
    self.stairSprite = love.graphics.newImage("sprites/locked.png")

    -- make img clean
    love.graphics.setDefaultFilter("nearest", "nearest")

    --hard code stair position (needs work)
    self.x = 100
    self.y = 100

    --set stairs collider
    self.collider = world:newRectangleCollider(self.x, self.y, 16, 16)
    self.collider:setCollisionClass("Stairs")
    self.collider:setType("static")
    self.collider:setFixedRotation(true)
end

function Stairs:update(dt)
    --if player touches stairs sprite changes (TODO change when all enemies dead)
    if self.collider:enter("Player") then
        self.stairSprite = love.graphics.newImage("sprites/open.png")
    end

    --TODO if player touches stairs when open and presses enter change map
end

function Stairs:draw()
    --draw stairs
    love.graphics.draw(self.stairSprite, self.x, self.y)
end