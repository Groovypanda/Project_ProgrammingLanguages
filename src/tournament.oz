functor 
import 
	BC_Player at 'opponents/Benjamin_Cousaert/Player_becousae.ozf'
	BC_Referee at 'opponents/Benjamin_Cousaert/Referee_becousae.ozf'
	BH_Player at 'opponents/Brecht_Hendrickx/player_BrechtHendrickx.ozf'
	BH_Referee at 'opponents/Brecht_Hendrickx/ref.ozf'
	NS_Player at 'opponents/Nick_De_Smedt/Player_Nick.ozf'
	NS_Referee at 'opponents/Nick_De_Smedt/Referee_Nick.ozf'
    RD_Player at 'opponents/Ruben_Dedecker/Player.ozf'
    RD_Referee at 'oppponents/Ruben_Dedecker/Ref.ozf'
    TM_Player at 'opponents/Thibault_Mahieu/Player.ozf'
    TM_Referee at 'opponents/Thibault_Mahieu/Referee.ozf'
    Own_Player at 'player.ozf'
    Own_Referee at 'referee.ozf'
define 
  local Player Opponent Ref in 
    Player = {Own_Player.createPlayer Ref white}
  	Opponent =  {NS_Player.createPlayer Ref black}
    Ref = {Own_Referee.createReferee Player Opponent}
  end      
end 
