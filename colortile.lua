require "globals"

ColorTile = {}
ColorTile.__index = ColorTile

function ColorTile.create(x, y, ground_type, i)
   	local colorTile = {}
   	setmetatable(colorTile, ColorTile)
        colorTile.b = love.physics.newBody(world, x + Globals.getInstance().getTranslation(), y + Globals.getInstance().getTranslation(), "static") 
        colorTile.s = love.physics.newRectangleShape(Globals.getInstance().getTileSize(), Globals.getInstance().getTileSize())
        colorTile.f = love.physics.newFixture(colorTile.b, colorTile.s)
        colorTile.f:setUserData(ground_type)
        colorTile.f:setCategory(i)
	return colorTile
end