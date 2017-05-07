functor 
import 
	Opponent at 'opponent/Player.ozf'
    Player at 'player.ozf'
    Referee at 'referee.ozf'
define 
  local PWhite PBlack Ref in 
    PWhite = {Player.createPlayer Ref white}
    PBlack = {Opponent.createPlayer Ref black}
    Ref = {Referee.createReferee PWhite PBlack}
  end      
end 
