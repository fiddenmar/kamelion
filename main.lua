Gamestate = require "hump.gamestate"

require "menu"
require "game"
require "win"

function love.load()
	love.window.setMode(0, 0, {fullscreen=true, fullscreentype="desktop", vsync=true, resizable=false})
    Gamestate.registerEvents()
    Gamestate.switch(menu)
end
