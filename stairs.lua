require("player")
require("map")

Stairs = {}

function Stairs:load()
    --load stairs sprite
    self.stairSprite = love.graphics.newImage("sprites/locked.png")
    self.locked = true

    --hard code stair position (needs work)
    self.x = 100
    self.y = 100

    --set stairs collider
    self.collider = world:newRectangleCollider(self.x, self.y, 16, 16)
    self.collider:setCollisionClass("Stairs")
    self.collider:setType("static")
    self.collider:setFixedRotation(true)

    -- make img clean
    love.graphics.setDefaultFilter("nearest", "nearest")
end

function Stairs:update(dt)
    --if player touches stairs sprite changes if stairs open level changes 
    --(TODO change when all enemies dead)
    if self.collider:enter("Player") then
        if self.locked == false then
            self:changeLevel("maps/floor_2.lua")
        end
        self.stairSprite = love.graphics.newImage("sprites/open.png")
        self.locked = false
    end

    --TODO if player touches stairs when open and presses enter change map

    -- Switch map and reload associated objects
    function Stairs:changeLevel(nextMap)
        -- Clean up the current map objects
        Map:unload()
    
        -- Load the new map
        Map:load(nextMap)
    
        -- Reset stairs for the new map (if reused in multiple levels)
        --Needs work
        self.locked = true
        self.stairSprite = love.graphics.newImage("sprites/locked.png")
    end
end

function Stairs:draw()
    --draw stairs
    love.graphics.draw(self.stairSprite, self.x, self.y)
end