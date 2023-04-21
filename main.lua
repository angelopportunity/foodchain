Cat = require 'modules/cat'
Rat = require 'modules/rat'
Bird = require 'modules/bird'
Tree = require 'modules/tree'



function love.load()
    math.randomseed(os.time())
    love.graphics.setDefaultFilter("nearest", "nearest") 
    love.graphics.setBackgroundColor(.5, .5, .5)
    love.window.setMode(1000,1000)


    Cats = {}
    Rats = {}
    Birds = {}
    Trees = {}

    for i = 1, 3 do 
        table.insert(Birds, Bird:newBird(math.random(100, 900), math.random(100, 900)))
    end

    for i = 1, 90 do 
        table.insert(Cats, Cat:newCat(math.random(100, 900), math.random(100, 900)))
    end

    for i = 1, 20 do 
        table.insert(Rats, Rat:newRat(math.random(100, 900), math.random(100, 900)))
    end

    for i = 1, 10 do 
        table.insert(Trees, Tree:newTree(math.random(100, 900), math.random(100, 900)))
    end
end

function love.update(dt)
    for i, cat in ipairs(Cats) do
        cat:physics(dt)
        cat:live(dt)
    end

    for i, bird in ipairs(Birds) do
        bird:physics(dt)
        bird:live(dt)
    end

    for i, rat in ipairs(Rats) do
        rat:physics(dt)
        rat:live(dt)
    end
end

function love.draw()

    if Test1 then
        love.graphics.print(Test1)
    end

    if Test2 then
        love.graphics.print(Test2, 0, 10)
    end

    if Test3 then
        love.graphics.print(Test3, 0, 20)
    end

    if love.mouse.isDown(1) then
        local x, y = love.mouse.getPosition()
        for i, cat in ipairs(Cats) do
            if x >= cat.x - 20 and x <= cat.x + 20 and y >= cat.y - 20 and y <= cat.y + 20 then
                Test1 = cat.goal
                Test2 = cat.goalx
                Test3 = cat.goaly
            end
        end
    end

    if Test1 then 
        love.graphics.print(Test1)
    end
    
    for i, bird in ipairs(Birds) do
        bird:draw()
    end

    for i, cat in ipairs(Cats) do
        cat:draw()
    end

    for i, rat in ipairs(Rats) do
        rat:draw()
    end

    for i, tree in ipairs(Trees) do
        tree:draw()
    end
end