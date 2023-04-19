local anim8 = require 'modules.anim8'

local Bird = {}
Bird.__index = Bird

local spritesheet = love.graphics.newImage('sprites/birdwalk.png')
local grid = anim8.newGrid(80, 80, spritesheet:getWidth(), spritesheet:getHeight())
local walking = anim8.newAnimation(grid('1-15',1), 0.25)
local neutral = anim8.newAnimation(grid('1-1', 1), 0.1)


function Bird:newBird(x, y) 
    local bird = {}
    setmetatable(bird, self)
    bird.x = x
    bird.y = y 
    bird.speed = 300
    bird.goalx = nil
    bird.goaly = nil
    bird.xvel = 0
    bird.yvel = 0
    bird.sprite = neutral
    bird.pauseCounter = 0
    bird.pauseDuration = 10
    return bird
end

function Bird:live(dt)
    local nearbyRats = self:sense(100)
    if #nearbyRats > 0 then
        self.goalx = nearbyRats[1].x
        self.goaly = nearbyRats[1].y
    else
        self.goalx = nil
        self.goaly = nil
    end
    self:hunt(dt)
end

function Bird:physics(dt)
    self.x = self.x + self.xvel * dt
    self.y = self.y + self.yvel * dt
    self.xvel = self.xvel * (1 - math.min(dt, 1))
    self.yvel = self.yvel * (1 - math.min(dt, 1))
    self.movingUpwards = self.yvel < 0 -- Set the movingUpwards flag based on y-velocity
    local looped = self:customUpdate(self.sprite, dt)
    if looped and self.sprite.position == 1 then
        self.xvel = self.xvel * 0
        self.yvel = self.yvel * 0
    end
end

function Bird:customUpdate(animation, dt)
    local wasLastFrame = (animation.position == 15)
    local isPaused = (animation.position == 12) and (self.pauseCounter < self.pauseDuration)

    if not isPaused then
        animation:update(dt)
    else
        self.pauseCounter = self.pauseCounter + 1
    end
    
    if animation.position ~= 12 then
        self.pauseCounter = 0
    end

    local isFirstFrame = (animation.position == 1)
    return wasLastFrame and isFirstFrame
end



function Bird:hunt(dt)
    if self.goalx and self.goaly then
        local dx = self.goalx - self.x
        local dy = self.goaly - self.y
        local distance = math.sqrt(dx*dx + dy*dy)
        local stopThreshold = 5 -- Add a threshold distance for stopping the movement

        if distance > stopThreshold then
            local direction = {x = dx/distance, y = dy/distance}
            local movingFrames = {10, 11, 12, 14, 15, 1}
            local looped = self:customUpdate(self.sprite, dt)

            if looped then
                table.remove(movingFrames, 6) -- Remove the first "1" from the movingFrames when the animation loops
            end

            local shouldMove = false
            for _, frame in ipairs(movingFrames) do
                if self.sprite.position == frame then
                    shouldMove = true
                    break
                end
            end

            if shouldMove then
                self.xvel = self.xvel + direction.x * self.speed * dt
                self.yvel = self.yvel + direction.y * self.speed * dt
            else
                self.xvel = 0
                self.yvel = 0
            end
        else
            self.goalx = nil
            self.goaly = nil
            self.xvel = 0
            self.yvel = 0
        end
    end
end

function Bird:draw()
    if self.xvel ~= 0 or self.yvel ~= 0 then
        self.sprite = walking
    else
        self.sprite = neutral
    end
    self.sprite:draw(spritesheet, math.floor(self.x), math.floor(self.y))
end

function Bird:sense(radius)
    local nearbyRats = {}
    for i, rat in ipairs(Rats) do
        local distance = math.sqrt((rat.x - self.x)^2 + (rat.y - self.y)^2)
        if distance < radius then
            table.insert(nearbyRats, rat)
        end
    end
    return nearbyRats
end

return Bird