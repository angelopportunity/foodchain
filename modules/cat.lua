local anim8 = require 'modules.anim8'

local circleCenters = {}
local Cat = {}
Cat.__index = Cat

local spritesheet = love.graphics.newImage('sprites/catspritesheet.png')
local grid = anim8.newGrid(16, 17, spritesheet:getWidth(), spritesheet:getHeight())
local shadow = love.graphics.newImage("sprites/catshadow.png")
local neutral = anim8.newAnimation(grid('1-1',1), 0.1)



function Cat:newCat(x, y)
    local cat = {}
    setmetatable(cat, self)

    --Movement--
    cat.x = x
    cat.y = y
    cat.speed = 30
    cat.goalx = nil
    cat.goaly = nil
    cat.goal = nil
    cat.xvel = 0
    cat.yvel = 0
    --Visuals--
    cat.sprite = neutral
    cat.huntTimer = 0
    cat.hopping = false
    cat.hopFrames = 80
    cat.hopCooldown = 200
    cat.talking = anim8.newAnimation(grid('1-2',2), .25)
    cat.jump = anim8.newAnimation(grid('1-3',1), 0.1)
    cat.jumping = anim8.newAnimation(grid('3-3',1), 0.1)
    --Energy--
    cat.energy = 100
    

    return cat
end



function Cat:live(dt)
    local nearbyBirds, nearbyCats = self:sense(100)
    if self.goal ~= "join circle" then
        if #nearbyBirds > 0 then
            self.goal = "bird"
            self.goalx = nearbyBirds[1].x
            self.goaly = nearbyBirds[1].y
        elseif #nearbyCats > 0 then
            self.goal = "cat"
            self.goalx = nearbyCats[1].x
            self.goaly = nearbyCats[1].y
        else
            self.goalx = self.x + math.random(-25, 25)
            self.goaly = self.y + math.random(-25, 25)
        end
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
    
    -- update animation frames
    self.sprite:update(dt)
end


function Cat:physics(dt)
    self.x = self.x + self.xvel * dt
	self.y = self.y + self.yvel * dt
	self.xvel = self.xvel * (1 - math.min(dt, 1))
	self.yvel = self.yvel * (1 - math.min(dt, 1))
    self.sprite:update(dt)
end

function Cat:draw()
    if self.hopping == false and self.goal ~= "join circle" then
        self.sprite = neutral
    elseif self.hopping == false and self.goal == "join circle" then
        self.sprite = self.talking
    end

    if self.hopping == true then
        if self.huntTimer > 0 and self.huntTimer < 4 then
            self.sprite = self.jump
        elseif self.huntTimer >= 4 and self.huntTimer < self.hopFrames then
            self.sprite = self.jumping
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
            if distance > 15  then
                local direction = {x = dx / distance, y = dy / distance}
                self.xvel = direction.x * self.speed
                self.yvel = direction.y * self.speed
            else
                if self.goal == "cat" then
                    self:joinCircle()
                else
                    self.goalx = nil
                    self.goaly = nil
                end
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

    local nearbyCats = {}
    for i, othercat in ipairs(Cats) do
        local distance = math.sqrt((othercat.x - self.x)^2 + (othercat.y - self.y)^2)
        if distance < radius and distance ~= 0 then
            table.insert(nearbyCats, othercat)
        end
    end

    return nearbyBirds, nearbyCats

end

function Cat:joinCircle()
    local nearbyBirds, nearbyCats = self:sense(100)
    if #nearbyBirds > 0 then
        self.goal = "bird"
        self.goalx = nearbyBirds[1].x
        self.goaly = nearbyBirds[1].y
    else
        self.goal = "join circle"

        if not self.circleCenterId then
            self.circleCenterId = self
        end

        local centerX, centerY = self.circleCenterId.x, self.circleCenterId.y
        local circleRadius = 30

        local totalCats = #nearbyCats + 1
        local sortedCats = {self}
        for _, cat in ipairs(nearbyCats) do
            cat.circleCenterId = self.circleCenterId
            table.insert(sortedCats, cat)
        end

        table.sort(sortedCats, function(a, b)
            return math.atan2(a.y - centerY, a.x - centerX) < math.atan2(b.y - centerY, b.x - centerX)
        end)

        for i, cat in ipairs(sortedCats) do
            local angle = (2 * math.pi / totalCats) * (i - 1)
            cat.goalx = centerX + circleRadius * math.cos(angle)
            cat.goaly = centerY + circleRadius * math.sin(angle)
            cat.huntTimer = 0
        end
    end
end

return Cat