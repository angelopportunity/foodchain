local Tree = {}

Tree.sprite = love.graphics.newImage("sprites/tree.png")

function Tree:newTree(x,y) 
    local tree = {}
    setmetatable(tree, self)
    self.__index = self
    tree.x = x
    tree.y = y 
    return tree
end

function Tree:draw()
love.graphics.draw(self.sprite, self.x, self.y)
end


return Tree