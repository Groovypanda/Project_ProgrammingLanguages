functor 
export
   createPlayer: CreatePlayer
import 
   Rules at './rules.ozf'
   OS
define
   
   fun {CreatePort Proc}
      Stream in 
         thread for Message in Stream do {Proc Message} end 
      end 
      {Port.new Stream}
   end 

   fun {CreatePlayer Referee Color}
      {CreatePort proc {$ Msg}
         case Msg of chooseSize() then 
            {Port.send Referee setSize(3 3)}
         [] doMove(GameBoard Attempt) then
            {Port.send Referee checkMove(GameBoard {CalculateMove GameBoard Color} Color (Attempt+1))}            
         end 
      end}  
   end 

   fun {CalculateMove Board Color}
      /*Return a random possible move*/
      local PossibleMoves in 
         PossibleMoves = {Rules.getValidMoves Board Color} 
         {List.nth PossibleMoves {OS.rand} mod {List.length PossibleMoves} + 1}
      end 
   end 

end 