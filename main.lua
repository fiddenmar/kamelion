--
--  Platformer Tutorial
--

local loader = require "AdvTiledLoader/Loader"
-- set the path to the Tiled map files
loader.path = "maps/"

local hero
local allSolidTiles
local startX
local startY

function love.load()
	
	-- load the level and bind to variable map
	map = loader.load("level3.tmx")
	
	world = love.physics.newWorld(0, 200, true)
		world:setCallbacks(beginContact, endContact, preSolve, postSolve)
 
    text       = ""
    persisting = 0 
	
	-- find all the tiles that we can collide with
	allSolidTiles = findTiles(map)

	-- set up the hero object, set him to position 32, 32
	setupHero(startX, startY)
end

function beginContact(a, b, coll)
 
end
 
function endContact(a, b, coll)
 
end
 
function preSolve(a, b, coll)
 
end
 
function postSolve(a, b, coll, normalimpulse1, tangentimpulse1, normalimpulse2, tangentimpulse2)
 
end

function love.update(dt)
	
	-- do all the input and movement
	hero.b:setFixedRotation( true )
	handleInput(dt)
	world:update(dt)

end

function love.draw()
	
	-- scale everything 2x
	love.graphics.scale(2,2)
		
	-- draw the level
	map:draw()
	
	-- draw the hero as a rectangle
	love.graphics.polygon("line", hero.b:getWorldPoints(hero.s:getPoints()))
end

function setupHero(x,y)
	
	hero = {}
        hero.b = love.physics.newBody(world, 8+x, 8+y, "dynamic")  -- set x,y position (400,200) and let it move and hit other objects ("dynamic")
        hero.b:setMass(100)                                        -- make it pretty light
        hero.s = love.physics.newRectangleShape(16, 16)                 -- give it a radius of 50
        hero.f = love.physics.newFixture(hero.b, hero.s)          -- connect body to shape
        hero.f:setMask(1, 2, 3)
	hero.xSpeedLimit = 100
	hero.yJumpSpeed = 175
	hero.onAir = false
	hero.ySpeed = 0
	hero.kamelion = false
	hero.adopt = false
end

function handleInput(dt)
	if love.keyboard.isDown("right") then
		local x, y = hero.b:getLinearVelocity()
        if x < 100 then
        	hero.b:applyForce(100, 0)
        	hero.b:setLinearVelocity(x, y)
        end
    elseif love.keyboard.isDown("left") then
        local x, y = hero.b:getLinearVelocity()
        if x < 100 then
        	hero.b:applyForce(-100, 0)
        	hero.b:setLinearVelocity(x, y)
        end
    end
    if love.keyboard.isDown("up") and not hero.onAir then
    	hero.onAir = true
        hero.b:applyForce(0, -2200)
    end
	if love.keyboard.isDown("lctrl", "rctrl") then
		hero.kamelion = true
		hero.adopt = false
	else
		if hero.kamelion then
			hero.adopt = true
			hero.kamelion = false
		end
	end
end

function updateHero(dt)
	
end

function findTiles(map)
	local colourTiles = {}
	local ground_types = {"start", "finish", "red", "green", "blue", "gray", "dark_gray"} 

	for i, ground_type in ipairs(ground_types) do
		local layer = map.tl["map"]
		
		for tileX=1,map.width do
			for tileY=1,map.height do
				
				local tile
				
				if layer.tileData[tileY] then
					tile = map.tiles[layer.tileData[tileY][tileX]]
				end

				if tile and tile.properties[ground_type] then

					if ground_type == "start" then
						startX = (tileX-1) * 16
						startY = (tileY-1) * 16
					end

					local static = {}
				        static.b = love.physics.newBody(world, 8+(tileX-1)*16, 8+(tileY-1)*16, "static")
				        static.s = love.physics.newRectangleShape(16, 16)
				        static.f = love.physics.newFixture(static.b, static.s)
				        static.f:setUserData(ground_type)
				        static.f:setCategory(i)
					table.insert(colourTiles, static)
				end
			end
		end
	end
	
	return colourTiles
end