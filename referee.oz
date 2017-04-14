functor 
export 
   createReferee: CreateReferee
import 
   System(printInfo: Print)
   Rules at './rules.ozf'
   Board at './board.ozf'
define
 	
   /* State contains a board, the turn of the current player, and a boolean invalid which implies if there is a previous move this turn which was invalid*/
   
   fun {NewPortObject State Fun}
      local Sin in 
         thread {FoldL Sin Fun State _} end 
         {NewPort Sin}
      end 
   end 
   

   fun {CreateReferee PlayerWhite PlayerBlack}
      {Send PlayerBlack chooseSize()} 
      {NewPortObject state(turn: white invalid: false) fun {$ State Msg}
         case Msg of setSize(N M) then 
            local GameBoard in 
               GameBoard = {Board.createBoard N M}
               {Send PlayerWhite doMove(GameBoard)}
               {SetBoard State GameBoard}
            end 
         [] checkMove(Move) then 
            local Valid GameBoardUpdated in 
               Valid = {CheckMove State.board Move State.turn}
               if Valid then 
                  GameBoardUpdated = {Board.submitMove State.board Move}
                  %{Board.print GameBoardUpdated}
                  if {Or {HasReachedFinish GameBoardUpdated State.turn Move} {Not {HasRemainingMoves GameBoardUpdated {GetOpponent State.turn}}}} then {ShowVictoryMessage State.turn} 
                  else 
                     if State.turn == black then 
                        {Send PlayerWhite doMove(GameBoardUpdated)}
                     else 
                        {Send PlayerBlack doMove(GameBoardUpdated)}
                     end 
                  end 
                  {SetTurn {SetInvalidMove {SetBoard State GameBoardUpdated} false} {GetOpponent State.turn}}
               else 
                  if {Not State.invalidMove} then 
                     if State.turn == black then 
                        {Send PlayerBlack doMove(State.board)}
                     else 
                        {Send PlayerWhite doMove(State.board)}
                     end 
                  else 
                     {ShowVictoryMessage {GetOpponent State.turn}} 
                  end 
                  {SetInvalidMove State true}
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
 
   fun {SetBoard GameState Board}
      {Record.adjoinAt GameState board Board}
   end 
 
   fun {SetTurn GameState Color}
      {Record.adjoinAt GameState turn Color}
   end 

   fun {SetInvalidMove GameState Invalid}
      {Record.adjoinAt GameState invalid Invalid}
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