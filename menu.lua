menu = {}

function menu:draw()
	love.graphics.print("kamelion game", 10, 10)
    love.graphics.print("Press Enter to continue", love.graphics:getWidth() / 2, love.graphics:getHeight() / 2)
end

function menu:keypressed(key, code)
    if key == 'return' then
        Gamestate.switch(game)
    end
    if key == 'escape' then
        love.event.quit()
    end
end