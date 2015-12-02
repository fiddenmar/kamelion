--
--  Platformer Tutorial
--

local Loader = require "AdvTiledLoader/Loader"
local Camera = require "hump.camera"
-- set the path to the Tiled map files
Loader.path = "maps/"

local hero
local allSolidTiles
local startX
local startY

local translateMapBody = 8

function love.load()
	love.window.setMode(0, 0, {fullscreen=true, fullscreentype="desktop", vsync=false})
	map = Loader.load("level1.tmx")
	
	world = love.physics.newWorld(0, 200, true)
		world:setCallbacks(beginContact, endContact, preSolve, postSolve)
 
    text       = ""
    persisting = 0 

	translateToCenterX = love.graphics:getWidth() / 2 - map.width*16 / 2
    translateToCenterY = love.graphics:getHeight() / 2 - map.height*16 / 2
	
	allSolidTiles = findTiles(map)

	setupHero(startX, startY)
	cam = Camera(startX, startY)
	cam:zoomTo(6)
end

function beginContact(a, b, coll)
	local playerObject = nil
	local tileObject = nil
	if a:getUserData() == "player" then
		playerObject = a
		tileObject = b
	elseif b:getUserData() == "player" then
		playerObject = b
		tileObject = a
	else
		return
	end

	x, y = playerObject:getBody():getLinearVelocity()
	if playerObject:getBody():getY() < tileObject:getBody():getY() and y >= 0 then
		hero.onAir = false
	end

	if tileObject:getCategory() == 2 then
		love.event.quit()
	end

	if tileObject:getCategory() == 7 then
		hero.deleting = true
		return
	end

end
 
function endContact(a, b, coll)

end
 
function preSolve(a, b, coll)

end
 
function postSolve(a, b, coll, normalimpulse1, tangentimpulse1, normalimpulse2, tangentimpulse2)

end

function adoption(f)
	if hero.adopt then
		if f:getUserData() ~= "player" then
			local category = f:getCategory()
			if category > 2 and category <= 5 then
				hero.adopt = false
				hero.f:setMask(1, category)
				return 0
			end
		end
	end
	return 1
end

function love.update(dt)
	handleInput(dt)
	if hero.kamelion then
		hero.f:setMask(1, 3, 4, 5)
	end

	coord1 = 0
	coord2 = 0
	coord3 = 0
	coord4 = 0
	if hero.adopt then	
		coord1, coord2, coord3, coord4 = hero.f:getBoundingBox()
		world:rayCast(coord1, coord2, coord3, coord4, adoption)
	end

	local heroX, heroY = hero.b:getWorldCenter()
	cam:lockPosition(heroX, heroY)

	if hero.deleting then
		hero.b:destroy()
		hero = nil
		setupHero(startX, startY)
	end

	world:update(dt)
end

function love.draw()
	cam:attach()
	map:draw()
	love.graphics.polygon("line", hero.b:getWorldPoints(hero.s:getPoints()))
	cam:detach()
end

function setupHero(x,y)
	
	hero = {}
        hero.b = love.physics.newBody(world, x + translateMapBody, y + translateMapBody, "dynamic")
        hero.b:setMass(100) 
        hero.s = love.physics.newRectangleShape(16, 16)
        hero.f = love.physics.newFixture(hero.b, hero.s)
        hero.f:setUserData("player")
        hero.f:setMask(1, 3)
    hero.deleting = false
	hero.xSpeedLimit = 100
	hero.onAir = false
	hero.kamelion = false
	hero.adopt = false
end

function handleInput(dt)
	if love.keyboard.isDown("right") then
		local x, y = hero.b:getLinearVelocity()
        if x < hero.xSpeedLimit then
        	hero.b:applyForce(100, 0)
        	hero.b:setLinearVelocity(x, y)
        end
    elseif love.keyboard.isDown("left") then
        local x, y = hero.b:getLinearVelocity()
        if x < hero.xSpeedLimit then
        	hero.b:applyForce(-100, 0)
        	hero.b:setLinearVelocity(x, y)
        end
    end
    if love.keyboard.isDown("up") and not hero.onAir then
    	hero.onAir = true
        hero.b:applyForce(0, -12000)
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
				        static.b = love.physics.newBody(world, (tileX-1)*16 + translateMapBody, (tileY-1)*16 + translateMapBody, "static")
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