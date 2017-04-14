functor 
import 
    Player at 'player.ozf'
    Referee at 'referee.ozf'
define 
    for I in 1..10 do 
      local PWhite PBlack Ref in 
        PWhite = {Player.createPlayer Ref white random}
        PBlack = {Player.createPlayer Ref black heuristic}
        Ref = {Referee.createReferee PWhite PBlack}
      end 
    end 
    
end 
