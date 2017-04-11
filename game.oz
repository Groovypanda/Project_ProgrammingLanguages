functor 
import 
    Player at 'player.ozf'
    Referee at 'referee.ozf'
define 
    PWhite = {Player.createPlayer Ref white}
    PBlack = {Player.createPlayer Ref black}
    Ref = {Referee.createReferee PWhite PBlack}
end 
