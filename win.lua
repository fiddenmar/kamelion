win = {}

function win:draw()
	love.graphics.print("kamelion game", 10, 10)
    love.graphics.print("You win! Press Enter to restart", love.graphics:getWidth() / 2, love.graphics:getHeight() / 2)
end

function win:keypressed(key, code)
    if key == 'return' then
        Gamestate.switch(game)
    end
    if key == 'escape' then
        love.event.quit()
    end
end