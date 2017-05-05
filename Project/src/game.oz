functor 
import 
    Player at 'player.ozf'
    Referee at 'referee.ozf'
define 
	%for I in 1..40 do 
      local PWhite PBlack Ref in 
        PWhite = {Player.createPlayer Ref white}
        PBlack = {Player.createPlayer Ref black}
        Ref = {Referee.createReferee PWhite PBlack}
      end      
    %	end 
end 
