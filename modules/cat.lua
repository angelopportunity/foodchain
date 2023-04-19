--IMPLEMENT HOP COOLDOWN!!!

local anim8 = require 'modules.anim8'

local Cat = {}
Cat.__index = Cat

local spritesheet = love.graphics.newImage('sprites/catspritesheet.png')
local grid = anim8.newGrid(16, 17, spritesheet:getWidth(), spritesheet:getHeight())
local shadow = love.graphics.newImage("sprites/catshadow.png")
local jump = anim8.newAnimation(grid('1-3',1), 0.1)
local jumping = anim8.newAnimation(grid('3-3',1), 0.1)
local neutral = anim8.newAnimation(grid('1-1',1), 0.1)


function Cat:newCat(x, y)
    local cat = {}
    setmetatable(cat, self)

    cat.x = x
    cat.y = y
    cat.speed = 30
    cat.goalx = nil
    cat.goaly = nil
    cat.xvel = 0
    cat.yvel = 0
    cat.sprite = neutral
    cat.huntTimer = 0
    cat.hopping = false
    cat.hopFrames = 80
    cat.hopCooldown = 200

    return cat
end



function Cat:live(dt)
    local nearbyBirds = self:sense(100)
    if #nearbyBirds > 0 then
        self.goalx = nearbyBirds[1].x
        self.goaly = nearbyBirds[1].y
    else
        self.goalx = nil
        self.goaly = nil
    end
    
    if self.huntTimer <= self.hopFrames then
        self:hunt(dt)
    end

    if self.huntTimer > self.hopFrames then
        self.sprite = neutral
        self.xvel = 0
        self.yvel = 0
    end

    if self.huntTimer > self.hopCooldown then
        self.huntTimer = 0
    end

    self.huntTimer = self.huntTimer + 1
    
    if self.xvel ~= 0 or self.yvel ~= 0 then
        self.hopping = true
    else
        self.hopping = false
    end

end

function Cat:physics(dt)
    self.x = self.x + self.xvel * dt
	self.y = self.y + self.yvel * dt
	self.xvel = self.xvel * (1 - math.min(dt, 1))
	self.yvel = self.yvel * (1 - math.min(dt, 1))
    self.sprite:update(dt)
end

function Cat:draw()
    if self.hopping == false then
        self.sprite = neutral
    end

    if self.hopping == true then
        if self.huntTimer > 0 and self.huntTimer < 4 then
            self.sprite = jump
        elseif self.huntTimer >= 4 and self.huntTimer < self.hopFrames then
            self.sprite = jumping
        elseif self.huntTimer >= self.hopFrames then
            self.sprite = neutral
        end
    end

    if self.hopping == true then
        if self.huntTimer <= self.hopFrames / 2 then
            if self.huntTimer % 5 == 0 then
                self.y = self.y - 1
            end
        elseif self.huntTimer > self.hopFrames / 2 and self.huntTimer < self.hopFrames then
            if self.huntTimer % 5 == 0 then
                self.y = self.y + 1
            end
        end
    end

    self.sprite:draw(spritesheet, math.floor(self.x), math.floor(self.y))
end


    function Cat:hunt(dt)
        if self.goalx and self.goaly and self.huntTimer > 0 then
            if self.huntTimer == 1 then
                local dx = self.goalx - self.x
                local dy = self.goaly - self.y
                local distance = math.sqrt(dx * dx + dy * dy)
                if distance > 1 then
                    local direction = {x = dx / distance, y = dy / distance}
                    self.xvel = direction.x * self.speed
                    self.yvel = direction.y * self.speed
                else
                    self.goalx = nil
                    self.goaly = nil
                end
            end
            self.huntTimer = self.huntTimer + 1
        end
    end

function Cat:sense(radius)
    local nearbyBirds = {}
    for i, bird in ipairs(Birds) do
        local distance = math.sqrt((bird.x - self.x)^2 + (bird.y - self.y)^2)
        if distance < radius then
            table.insert(nearbyBirds, bird)
        end
    end
    return nearbyBirds
end

return Cat