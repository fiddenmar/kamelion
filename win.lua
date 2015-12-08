win = {}

function win:enter()
love.graphics.setBackgroundColor( 128, 0, 0, 64 )
	end

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

function win:update( dt )
	steps = steps + dt
	if steps >= 1.5 then
		steps = 0
		if bg == 0 then
			love.graphics.setBackgroundColor( 192, 255, 192, 255 )
		elseif bg == 1 then
			love.graphics.setBackgroundColor( 192, 192, 255, 255 )
		else
			love.graphics.setBackgroundColor( 255, 192, 192, 255 )
		end
		bg = bg + 1
		if bg >=3 then
			bg = 0
		end

	end
end