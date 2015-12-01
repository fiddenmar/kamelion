Player = {}
Player.__index = Player

function Player.create(_body)
   local pl = {}  
   setmetatable(pl, Player) 
   pl.body = _body
   return pl
end

function Player:handleInput(dt)
   self.balance = self.balance - amount
end