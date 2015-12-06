Loader = require "AdvTiledLoader/Loader"
	Loader.path = "maps/"
Camera = require "hump.camera"

require "globals"
require "colortile"
require "player"

local player
local allSolidTiles

game = {}

function game:init()
    map = Loader.load("level5.tmx")
	
	world = love.physics.newWorld(0, 200, true)
		world:setCallbacks(beginContact, endContact, preSolve, postSolve)
 
	translateToCenterX = love.graphics:getWidth() / 2 - map.width*Globals.getInstance().getTileSize() / 2
    translateToCenterY = love.graphics:getHeight() / 2 - map.height*Globals.getInstance().getTileSize() / 2
	
	allSolidTiles, startX, startY = findTiles(map)
	startX = 50
	startY = 50

	player = Player.create(startX, startY)
	cam = Camera(startX, startY)
	cam:zoomTo(4)
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
		player.onAir = false
	end

	if tileObject:getCategory() == 2 then
		love.event.quit()
	end

	if tileObject:getCategory() == 7 then
		player.deleting = true
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
	if player.adopt then
		if f:getUserData() ~= "player" then
			local category = f:getCategory()
			if category > 2 and category <= 5 then
				player.adopt = false
				player:setMask(category)
				return 0
			end
		end
	end
	return 1
end

function game:update(dt)
    handleInput(dt)
	local alive, x, y = player:update()
	if not alive then
		player = Player.create(x, y)
	end

	if player.adopt then	
		local coord1, coord2, coord3, coord4 = player:getAABB()
		world:rayCast(coord1, coord2, coord3, coord4, adoption)
	end

	local posX, posY = player:getPosition()
	cam:lockPosition(posX, posY)

	world:update(dt)
end

function game:draw()
    cam:attach()
	map:draw()
	player:draw()
	cam:detach()
end

function handleInput(dt)
	player:handleInput(dt)
	if love.keyboard.isDown("escape") then
		Gamestate.switch(menu)
	end
end

function findTiles(map)
	local colorTiles = {}
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
						startX = (tileX-1) * Globals.getInstance().getTileSize()
						startY = (tileY-1) * Globals.getInstance().getTileSize()
					end

					local tile = ColorTile.create((tileX-1)*Globals.getInstance().getTileSize(), (tileY-1)*Globals.getInstance().getTileSize(), ground_type, i)
					table.insert(colorTiles, tile)
				end
			end
		end
	end
	
	return colorTiles, startX, startY
end