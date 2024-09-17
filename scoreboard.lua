-- scoreboard

function makeScoreboard()
    local scoreboard = {
        playerScores = {0 , 0},
        WINNING_SCORE = 10,
        SCORE_SCALE = 2.5
    }

    -- resets scores to 0
    function scoreboard:reset()
        scoreboard.playerScores = {0, 0}
    end

    -- increases score based on id
    function scoreboard:score(id)
        scoreboard.playerScores[id] = scoreboard.playerScores[id] + 1
    end

    -- returns winner, if no one has won, returns 0
    function scoreboard:win()
        for i = 1, 2 do 
            if scoreboard.playerScores[i] >= scoreboard.WINNING_SCORE then
                return i 
            end
        end
        return 0
    end

    function scoreboard:draw()
       local curFont = love.graphics.getFont()
       love.graphics.setFont(titleFont)
        love.graphics.print(tostring(scoreboard.playerScores[1]), WINDOW_WIDTH / 3, WINDOW_HEIGHT / 10, 0, scoreboard.SCORE_SCALE)
        love.graphics.print(tostring(scoreboard.playerScores[2]), WINDOW_WIDTH * 2 / 3, WINDOW_HEIGHT / 10, 0, scoreboard.SCORE_SCALE)
love.graphics.setFont(curFont)
    end

    return scoreboard
end
