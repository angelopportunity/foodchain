local Rat = {}

Rat.sprite = love.graphics.newImage("sprites/rat.png")
Rat.__index = Rat

function Rat:newRat(x, y) 
    local rat = {}
    setmetatable(rat, self)
    rat.x = x
    rat.y = y 
    rat.speed = 15
    rat.goalx = nil
    rat.goaly = nil
    rat.xvel = 0
    rat.yvel = 0
    return rat
end

function Rat:live(dt)
    local nearbyTrees = self:sense(100)
    if #nearbyTrees > 0 then
        self.goalx = nearbyTrees[1].x
        self.goaly = nearbyTrees[1].y
    else
        self.goalx = nil
        self.goaly = nil
    end
    self:hunt(dt)
end

function Rat:physics(dt)
    self.x = self.x + self.xvel * dt
	self.y = self.y + self.yvel * dt
	self.xvel = self.xvel * (1 - math.min(dt, 1))
	self.yvel = self.yvel * (1 - math.min(dt, 1))
end

function Rat:draw()
    love.graphics.draw(self.sprite, math.floor(self.x), math.floor(self.y))
end

function Rat:hunt(dt)
    if self.goalx and self.goaly then
        local dx = self.goalx - self.x
        local dy = self.goaly - self.y
        local distance = math.sqrt(dx*dx + dy*dy)
        if distance > 1 then
            local direction = {x = dx/distance, y = dy/distance}
            self.xvel = self.xvel + direction.x * self.speed * dt
            self.yvel = self.yvel + direction.y * self.speed * dt
        else self.goalx = nil
            self.goaly = nil
        end
    end
end

function Rat:sense(radius)
    local nearbyTrees = {}
    for i, tree in ipairs(Trees) do
        local distance = math.sqrt((tree.x - self.x)^2 + (tree.y - self.y)^2)
        if distance < radius then
            table.insert(nearbyTrees, tree)
        end
    end
    return nearbyTrees
end

return Rat