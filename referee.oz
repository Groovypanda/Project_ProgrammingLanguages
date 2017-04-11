functor 
export 
   createReferee: CreateReferee
import 
   System(printInfo: Print)
   Rules at './rules.ozf'
   Board at './board.ozf'
define
 	
   fun {CreatePort Proc}
      Stream in 
         thread for Message in Stream do {Proc Message} end 
      end 
      {Port.new Stream}
   end 

   fun {CreateReferee PlayerWhite PlayerBlack}
      {Port.send PlayerBlack chooseSize()} 
      {CreatePort proc {$ Msg}
         case Msg of setSize(N M) then 
            local GameBoard in 
               GameBoard = {Board.createBoard N M}
               {Port.send PlayerWhite doMove(GameBoard 1)}
            end 
         [] checkMove(GameBoard Move Color Attempt) then 
            local Valid GameBoardUpdated in 
               Valid = {CheckMove GameBoard Move Color}
               if Valid then 
                  GameBoardUpdated = {Board.submitMove GameBoard Move}
                  {Board.print GameBoardUpdated}
                  if {Or {HasReachedFinish GameBoardUpdated Color Move} {Not {HasRemainingMoves GameBoardUpdated {GetOpponent Color}}}} then {ShowVictoryMessage Color} 
                     else 
                        if Color == black then 
                           {Port.send PlayerWhite doMove(GameBoardUpdated 1)}
                           
                        else 
                           {Port.send PlayerBlack doMove(GameBoardUpdated 1)}
                        end 
                  end 
               else 
                  if Attempt < 2 then 
                     if Color == black then 
                        {Port.send PlayerBlack doMove(GameBoard 2)}
                     else 
                        {Port.send PlayerWhite doMove(GameBoard 2)}
                     end 
                  else 
                     {ShowVictoryMessage {GetOpponent Color}}
                  end 
               end 
            end 
         end 
      end}  
   end 

   fun {GetOpponent Color}
      case Color
      of white then black 
      [] black then white 
      end 
   end 

   proc {ShowVictoryMessage Color}
      if Color == black then 
         {Print 'Zwart wint!'}
      else 
         {Print 'Wit wint!'}
      end 
      {Print '\n'}
   end 

   fun {HasReachedFinish GameBoard Color Move}
      if Color == black then Move.dest.x == {Board.getRowSize GameBoard} else Move.dest.x == 1 end        
   end 

   fun {HasRemainingMoves GameBoard Color}
      {List.length {Rules.getValidMoves GameBoard Color}} > 0 
   end 

   fun {CheckMove GameBoard Move Color}
      {And {Board.getType GameBoard Move.start.x Move.start.y}==Color {Rules.isValidMove GameBoard Move.start Move.dest}}
   end
   
   
end 