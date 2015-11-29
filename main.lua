--
--  Platformer Tutorial
--

local loader = require "AdvTiledLoader/Loader"
-- set the path to the Tiled map files
loader.path = "maps/"

local HC = require "HardonCollider"

local hero
local hero_type
local collider
local allSolidTiles
local startX
local startY
local kamelion = false
local adopt = false

function love.load()
	
	-- load the level and bind to variable map
	map = loader.load("level1.tmx")
	
	-- load HardonCollider, set callback to on_collide and size of 100
	collider = HC(1000, on_collide)
	
	-- find all the tiles that we can collide with
	allSolidTiles = findTiles(map)

	-- set up the hero object, set him to position 32, 32
	setupHero(startX, startY)

	hero_type = "red"
	
end

function love.update(dt)
	
	-- do all the input and movement
	
	handleInput(dt)
	updateHero(dt)
	
	-- update the collision detection
	
	collider:update(dt)
	
	
end

function love.draw()
	
	-- scale everything 2x
	love.graphics.scale(2,2)
		
	-- draw the level
	map:draw()
	
	-- draw the hero as a rectangle
	hero:draw("fill")
end

function on_collide(dt, shape_a, shape_b, mtv_x, mtv_y)
	
	-- seperate collision function for entities
	collideHeroWithTile(dt, shape_a, shape_b, mtv_x, mtv_y)
	
end

function collideHeroWithTile(dt, shape_a, shape_b, mtv_x, mtv_y)
	
	if kamelion then
		return
	end
	-- sort out which one our hero shape is
	if shape_a.type == "start" or shape_b.type == "start" then
		return
	end
	local hero_shape, tileshape
	if shape_a == hero and shape_b.type ~= hero_type then
		hero_shape = shape_a
		tileshape = shape_b
	elseif shape_b == hero and shape_a.type ~= hero_type then
		hero_shape = shape_b
		tileshape = shape_a
	else
		-- none of the two shapes is a tile, return to upper function
		return
	end

	if adopt and (math.abs(mtv_x) > 8 or math.abs(mtv_y) > 8) then
		adopt = false
		hero_type = tileshape.type
		return
	end
	-- why not in one function call? because we will need to differentiate between the axis later
	hero_shape:move(mtv_x, 0)
	hero_shape:move(0, mtv_y)
	
end

function setupHero(x,y)
	
	hero = collider:addRectangle(x,y,16,16)
	hero.speed = 100
--	hero.img = love.graphics.newImage("img/hero.png")

end

function handleInput(dt)
	
	if love.keyboard.isDown("left") then
		hero:move(-hero.speed*dt, 0)
	end
	if love.keyboard.isDown("right") then
		hero:move(hero.speed*dt, 0)		
	end
	if love.keyboard.isDown("up") then
		hero:move(0, -(hero.speed+50)*dt)
	end
	if love.keyboard.isDown("lctrl") then
		kamelion = true
		adopt = false
	else
		if kamelion then
			adopt = true
			kamelion = false
		end
	end
	
end

function updateHero(dt)
	
	-- apply a downward force to the hero (=gravity)
	hero:move(0,dt*50)
	
end

function findTiles(map)
	local colourTiles = {}
	local ground_types = {"red", "green", "blue", "gray", "finish", "start"} 

	for i, ground_type in ipairs(ground_types) do
		local tileGroup = {}
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

					local ctile = collider:addRectangle((tileX-1)*16,(tileY-1)*16,16,16)
					ctile.type = ground_type
					collider:addToGroup(ground_type, ctile)
					collider:setPassive(ctile)
					table.insert(tileGroup, ctile)
				end
			end
		end
		table.insert(colourTiles, tileGroup)
	end
	
	return colourTiles
end