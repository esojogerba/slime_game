require("player")
require("map")

Stairs = {}

function Stairs:load(mapList)
    --load stairs sprite
    self.stairSprite = love.graphics.newImage("sprites/locked.png")
    self.locked = true

    --hard code stair position (needs work)
    self.x = mapList[1].stairsStart.x
    self.y = mapList[1].stairsStart.y

    --set stairs collider
    self.collider = world:newRectangleCollider(self.x, self.y, 16, 16)
    self.collider:setCollisionClass("Stairs")
    self.collider:setType("static")
    self.collider:setFixedRotation(true)

    --map cycling
    self.maplist = mapList or {}
    self.currentMapIndex = 1

    -- make img clean
    love.graphics.setDefaultFilter("nearest", "nearest")
end

function Stairs:update(dt)
    --if player touches stairs sprite changes if stairs open level changes 
    --(TODO change when all enemies dead)
    if self.collider:enter("Player") then
        if self.locked == false then
            self:advanceToNextMap()
        else
            self.stairSprite = love.graphics.newImage("sprites/open.png")
            self.locked = false
        end
    end
end

--update map index
function Stairs:advanceToNextMap()
    self.currentMapIndex = self.currentMapIndex + 1

    --check if game has been won
    if self.currentMapIndex > 20 then
        print("Congratulations you won!!")
        return
    end

    --pass new map to change level function
    self:changeLevel(self.currentMapIndex)
end

-- Switch map and reload associated objects
function Stairs:changeLevel(nextMapIndex)

    --retrieve next map
    local nextMap = self.maplist[nextMapIndex]

    -- Clean up the current map objects
    Map:unload()

    -- Load the new map
    Map:load(nextMap.file)

    --Set player starting position
    Player.collider:setPosition(nextMap.playerStart.x, nextMap.playerStart.y)

    --Set stairs starting position
    self.x = nextMap.stairsStart.x
    self.y = nextMap.stairsStart.y
    self.collider:setPosition(self.x + 8, self.y + 8)

    -- Reset stairs for the new map (if reused in multiple levels)
    --Needs work
    self.locked = true
    self.stairSprite = love.graphics.newImage("sprites/locked.png")
end

function Stairs:draw()
    --draw stairs
    love.graphics.draw(self.stairSprite, self.x, self.y)
end