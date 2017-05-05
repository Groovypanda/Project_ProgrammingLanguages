functor 
export 
   createReferee: CreateReferee
import 
   System(printInfo: Print)
   Rules at './rules.ozf'
   Board at './board.ozf'
define
   
   /**
    * Create a new port which handles the message stream.
    *
    * State: The current state 
    * Fun: The state transition function
    */
   fun {NewPortObject State Fun}
      local Sin in 
         thread {FoldL Sin Fun State _} end 
         {NewPort Sin}
      end 
   end 
   
   /**
    * Create a new referee
    *
    * PlayerWhite: The port of the white player 
    * PlayerBlack: The port of the black player
    */
   fun {CreateReferee PlayerWhite PlayerBlack}
      {Send PlayerBlack chooseSize()} 
      {NewPortObject state(turn: white strikes: 0 i: 0) fun {$ State Msg}
         case Msg 
         %Initialise a N * M board. 
         of makeBoard(N M) then 
            local GameBoard in 
               GameBoard = {Board.createBoard N M}
               {Send PlayerWhite chooseK(GameBoard)}
               {SetBoard State GameBoard}
            end 
         %Decide the amount of pawns which will be removed.
         [] setK(K) then
            local MaxK in 
               MaxK = {FloatToInt {Floor {IntToFloat {Board.getColumnSize State.board}}/2.0}}
               if K =< MaxK then 
                  if K>0 then {Send PlayerWhite removePawn(State.board)} else {Send PlayerWhite doMove(State.board State.strikes)} end      
                  {SetK State K}           
               else 
                  {Print "K is to high. Please do not cheat...\n"}
                  {ShowVictoryMessage black} %White has cheated => Black wins. 
                  State
               end                 
            end        
         %Remove a pawn from the board
         [] removePawn(Pawn) then 
            local GameBoardUpdated in 
               if Pawn.type == State.turn then 
                  GameBoardUpdated = {Board.removePawn State.board Pawn} 
                  if {GetRemovedPawnsAmount State} < 2*State.k-1 then 
                     if State.turn == white then {Send PlayerBlack removePawn(GameBoardUpdated)} else {Send PlayerWhite removePawn(GameBoardUpdated)} end 
                  else
                     {Send PlayerWhite doMove(GameBoardUpdated)}
                  end 
                  {IncrementPawnsRemoved {SetTurn {SetBoard State {Board.removePawn GameBoardUpdated Pawn}} {GetOpponent State.turn}}}
               else 
                  {Print "Please only remove your own pawns...\n"}
                  {ShowVictoryMessage {GetOpponent State.turn}} %Player has cheated => Other player wins. 
                  State 
               end  
            end 
         % Check the validity of the move of a player.
         [] checkMove(Move) then 
            if {Board.getType State.board Move.start.row Move.start.col}==State.turn then 
               local Valid GameBoardUpdated in 
                  Valid = {CheckMove State.board Move State.turn}
                  if Valid then 
                     GameBoardUpdated = {Board.submitMove State.board Move}
                     {Board.print GameBoardUpdated}
                     if {Or {HasReachedFinish GameBoardUpdated State.turn Move} {Not {HasRemainingMoves GameBoardUpdated {GetOpponent State.turn}}}} then {ShowVictoryMessage State.turn} 
                     else 
                        if State.turn == black then 
                           {Send PlayerWhite doMove(GameBoardUpdated)}
                        else 
                           {Send PlayerBlack doMove(GameBoardUpdated)}
                        end 
                     end 
                     {SetTurn {SetBoard State GameBoardUpdated} {GetOpponent State.turn}}
                  else %Let the person try again if he hasn't had a second chance.
                     if State.strikes < 1 then 
                        if State.turn == black then 
                           {Send PlayerBlack doMove(State.board)}
                        else 
                           {Send PlayerWhite doMove(State.board)}
                        end 
                        {SetStrikes State 1}
                     else 
                        {ShowVictoryMessage {GetOpponent State.turn}} 
                        State
                     end 
                  end 
               end 
            else 
               {Print "Please only move your own pawns...\n"}
               {ShowVictoryMessage {GetOpponent State.turn}} %Player has cheated => Other player wins. 
               State
            end 
         end 
      end}  
   end 

   %Get the color of the opponent of the player with the given Color
   fun {GetOpponent Color}
      case Color
      of white then black 
      [] black then white 
      end 
   end

   %Set the board in the state.
   fun {SetBoard GameState Board}
      {Record.adjoinAt GameState board Board}
   end 
 
   %Set the turn in the state.
   fun {SetTurn GameState Color}
      local TmpState in 
         TmpState = {SetStrikes GameState 0}
         {Record.adjoinAt TmpState turn Color}
      end    
   end 

   %Set the amount of incorrect moves the current player has made.
   fun {SetStrikes GameState Strikes}
      {Record.adjoinAt GameState strikes Strikes} 
   end

   %Set the amount of pawns to be removed.
   fun {SetK GameState K}
      {Record.adjoinAt GameState k K}
   end

   %Set the amount of pawns removed.
   fun {IncrementPawnsRemoved GameState}
      {Record.adjoinAt GameState i GameState.i+1}
   end 

   %Return the amount of pawns removed.
   fun {GetRemovedPawnsAmount GameState}
      GameState.i 
   end 

   %Print a message telling the player with the given color wins.
   proc {ShowVictoryMessage Color}
      if Color == black then 
         {Print 'Zwart wint!'}
      else 
         {Print 'Wit wint!'}
      end 
      {Print '\n'}
   end 

   %Check if the player with the given color has reached the finish with the given move.
   fun {HasReachedFinish GameBoard Color Move}
      if Color == black then Move.stop.row == {Board.getRowSize GameBoard} else Move.stop.row == 1 end        
   end 

   %Check if the player can make a move.
   fun {HasRemainingMoves GameBoard Color}
      {List.length {Rules.getValidMoves GameBoard Color}} > 0 
   end 

   %Check the validity of the given move made by the player with the given color.
   fun {CheckMove GameBoard Move Color}
      {And {Board.getType GameBoard Move.start.row Move.start.col}==Color {Rules.isValidMove GameBoard Move.start Move.stop}}
   end   
end 