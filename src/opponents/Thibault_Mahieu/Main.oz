% Make sure to update the paths
declare [BoardMod] = {Module.link ['/home/thibault/PLproject/BoardModule.ozf']}
declare [PlayerMod] = {Module.link ['/home/thibault/PLproject/Player.ozf']}
declare [RefereeMod] = {Module.link ['/home/thibault/PLproject/Referee.ozf']}
local Ref S1 S2 S3 P1 P2 P3 B1 B2 in
   Player1 = {PlayerMod.createPlayer Referee black}
   Player0 = {PlayerMod.createPlayer Referee white}
   Referee = {RefereeMod.createReferee Player0 Player1}
   % Last argument for Referee.newagent sets the delay between moves in ms
   % {Referee.newagent S3 P1 P2 5 5 1000}
end
