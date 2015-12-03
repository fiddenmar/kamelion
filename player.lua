require "globals"

Player = {}
Player.__index = Player

function Player.create(x, y)
   	local player = {}
   	setmetatable(player, Player)
        player.b = love.physics.newBody(world, x + Globals.getInstance().getTranslation(), y + Globals.getInstance().getTranslation(), "dynamic")
        player.b:setMass(100) 
        player.s = love.physics.newRectangleShape(16, 16)
        player.f = love.physics.newFixture(player.b, player.s)
        player.f:setUserData("player")
        player.f:setMask(1, 3)
    player.deleting = false
	player.xSpeedLimit = 100
	player.onAir = false
	player.kamelion = false
	player.adopt = false
	player.normalImage = love.graphics.newImage("img/player.png")
	player.kamelionImage = love.graphics.newImage("img/kamelion.png")
	player.startX = x
	player.startY = y
	return player
end

function Player:handleInput(dt)
	if love.keyboard.isDown("right") then
		local x, y = self.b:getLinearVelocity()
        if x < self.xSpeedLimit then
        	self.b:applyForce(100, 0)
        	self.b:setLinearVelocity(x, y)
        end
    elseif love.keyboard.isDown("left") then
        local x, y = self.b:getLinearVelocity()
        if x > -self.xSpeedLimit then
        	self.b:applyForce(-100, 0)
        	self.b:setLinearVelocity(x, y)
        end
    end
    if love.keyboard.isDown("up") and not self.onAir then
    	self.onAir = true
        self.b:applyForce(0, -3000)
    end
	if love.keyboard.isDown("lctrl", "rctrl") then
		self.kamelion = true
		self.adopt = false
	else
		if self.kamelion then
			self.adopt = true
			self.kamelion = false
		end
	end
end

function Player:draw()
	if not self.kamelion then
		love.graphics.draw(self.normalImage, self.b:getX(), self.b:getY(), self.b:getAngle(),  1, 1, self.normalImage:getWidth()/2, self.normalImage:getHeight()/2)
	else
		love.graphics.draw(self.kamelionImage, self.b:getX(), self.b:getY(), self.b:getAngle(),  1, 1, self.kamelionImage:getWidth()/2, self.kamelionImage:getHeight()/2)
	end
end

function Player:getPosition()
	local x, y = self.b:getWorldCenter()
	return x, y
end

function Player:getAABB()
	local coord1, coord2, coord3, coord4 = self.f:getBoundingBox()
	return coord1, coord2, coord3, coord4
end

function Player:update()
	if self.kamelion then
		self.f:setMask(1, 3, 4, 5)
	end

	if self.deleting then
		local x = self.startX
		local y = self.startY
		self.b:destroy()
		return false, x, y
	end
	return true, 0, 0
end