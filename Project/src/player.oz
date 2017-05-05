functor 
export
   createPlayer: CreatePlayer
import 
   Board at './Board.ozf'
   Rules at './rules.ozf'
      System(printInfo: Print)
   OS
define
   
   /**
   	* Create a new port which handles the message stream.
   	*
   	* Proc: The procedure which handles the messages in the stream
   	*/
   fun {CreatePort Proc}
      Sin in 
         thread for Msg in Sin do {Proc Msg} end 
      end 
      {NewPort Sin}
   end 

   /**
    * Create a new player 
    *
    * Referee: The port of the referee
    * Color: The color of the player
    */
   fun {CreatePlayer Referee Color}
      {CreatePort proc {$ Msg}
         case Msg 
         %Choose the size of the board
         of chooseSize() then 
            {Send Referee setSize(5 5)}
         %Choose a value for K, the amount of pawns to be deleted by every player.
         [] chooseK(GameBoard) then
            local MaxK in
            	%Remove the maximum amount of pawns.
               MaxK = {IntToFloat {Board.getColumnSize GameBoard}}/2.0
               {Send Referee setK({FloatToInt {Floor MaxK}})}  %{FloatToInt {Floor MaxK}}
            end 
         % Remove a pawn of this player.
         [] removePawn(GameBoard) then 
         	%Delete pawns in the same columns as the enemy. As these pawns could be easily captured if not removed.
         	local Found in %Found indicates if a coordinate has been sent. 
	         	for Pawn in {GetPawns GameBoard Color} do 
	         		if {IsFree Found} then
	         			%TODO 
		         		local Coord EnemyPawn in 
		         			Coord = coord(row: {StartRow GameBoard {GetOpponent Color}} col: Pawn.col type:Color)
			         		if {Board.getType GameBoard Coord.row Coord.col}=={GetOpponent Color} 
			         		then EnemyPawn = {AdjoinAt Coord type {GetOpponent Color}} {Send Referee removePawn(EnemyPawn)} Found = true end 
		         		end 
	         		end 
	         	end 
	         	%If no good options are found just sent the first one. (One close to the edges). 
	         	if {IsFree Found} then 
	         	    {Send Referee removePawn({List.nth {GetPawns GameBoard Color} 1})}
	         	end 
         	end 
         % Make a move 
         [] doMove(GameBoard) then
            {Send Referee checkMove({CalculateMove GameBoard Color})}            
         end 
      end}  
   end 

   /**
   	* Choose the best move from the list of possible moves. 
   	*
   	* GameBoard: The current state of the board
   	* Color: The color of the player
   	*/
   fun {CalculateMove GameBoard Color}
      /*Return a random possible move*/
      local PossibleMoves in 
         PossibleMoves = {Rules.getValidMoves GameBoard Color} 
         if Color == white then 
            {List.nth PossibleMoves {OS.rand} mod {List.length PossibleMoves} + 1}
         else 
            local GetBestMove in 
               fun {GetBestMove Moves CurrentBest CurrentValue}
                  local Value in 
                     case Moves
                     of Move|Xs then 
                        Value = {GetValueMove GameBoard Move Color 0 2}
                        if CurrentBest == nil then {GetBestMove Xs Move Value}
                        else 
                           if Value > CurrentValue then {GetBestMove Xs Move Value}
                           else {GetBestMove Xs CurrentBest CurrentValue} end
                        end 
                     [] nil then CurrentBest
                     end 
                  end 
               end  
               {GetBestMove PossibleMoves nil nil}
            end  
         end 
      end 
   end 

   /**
   	* Calculate the value of the given move. The higher the value of the move is, the better the move. This is calculated with a heuristic.
   	*
   	* GameBoard: The current state of the board
   	* Move: A move the player with the given color can make
   	* Color: The color of the player 
   	* Depth: This value indicates the current depth of the simulation. Zero indicates the current iteration is not a simulation but is an actual possible move. 
   	* MaxDepth indicates an upperbound for Depth. 
   	*/
   fun {GetValueMove GameBoard Move Color Depth MaxDepth}
      %If enemies are far, distance will be high, so it's safer to move.
      local Multiplier RowAmount DistanceToFinish Value DepthModifier CanBlockValue in
      	RowAmount = {IntToFloat {Board.getRowSize GameBoard}}
      	DistanceToFinish = {IntToFloat {GetDistanceToFinish GameBoard Move.stop Color}}
      	%If the tile is not far, killing is more important as the enemies tile is far. 
      	if {List.length {GetDiagonalEnemies GameBoard Move.start Color}} > 0 then 
      		Multiplier = 1.0 + DistanceToFinish/RowAmount
      	else 
      		Multiplier = 1.0 
      	end
      	%The closer the pawn gets, the better it is to move this pawn forward. 
      	%If there is 1 tile between 2 pawns in the same column of another type, the pawn should try to block the other pawn. 
      	CanBlockValue = RowAmount*({IntToFloat {BooleanToInt {CanBlockEnemyPawn GameBoard Move Color}}}/4.0)
      	Value = Multiplier *((RowAmount - DistanceToFinish) + Multiplier*CanBlockValue)
      	%The deeper the simulations go, the less influence the value should have as they have less meaning.
      	DepthModifier = {IntToFloat (Depth+1)*2}
      	if Depth mod 2 == 0 then 
      	 Value - {SimulateMove	GameBoard Move Color Depth+1 MaxDepth}/DepthModifier
      	else 
      	 Value + {SimulateMove	GameBoard Move Color Depth+1 MaxDepth}/DepthModifier
      	end
      end 
   end 

   %This function returns the average value of the enemies moves after the current player submits the given Move.
   /** 
   	* 
   	*
   	*/
   fun {SimulateMove GameBoard Move Color Depth MaxDepth}
   if Depth =< MaxDepth then 
   	local UpdatedGameBoard EnemyMoves GetTotalValue in
   		fun {GetTotalValue RemainingMoves CurrentValue}
         	case RemainingMoves
            of X|Xs then {GetTotalValue Xs (CurrentValue+{GetValueMove UpdatedGameBoard X {GetOpponent Color} Depth MaxDepth})}
            [] nil then CurrentValue
          end 
       end  
        UpdatedGameBoard = {Board.submitMove GameBoard Move}
      	EnemyMoves = {Rules.getValidMoves UpdatedGameBoard {GetOpponent	Color}}
   		{GetTotalValue EnemyMoves 0.0}/{IntToFloat {List.length EnemyMoves}}
   	end
   	else 
   		0.0
   	end
   end 

   fun {GetDirection Type}
      case Type 
      of black then 1 
      [] white then ~1 
      else nil
      end 
   end 

   %Returns the row where the given color starts.
   fun {StartRow GameBoard Color}
   		if Color==black then 1 else {Board.getRowSize GameBoard} end 
   end 

   fun {BooleanToInt Bool}
      if Bool then 1 else 0 end 
   end 

   fun {GetDiagonalEnemies GameBoard Coord Color}
   	{List.filter {Board.getNeighbouringTiles GameBoard Coord {GetDirection Color}} fun {$ Tile}
   			 {And (Tile.col\=Coord.col)  ({Board.getType GameBoard Tile.row Tile.col} == {GetOpponent Color})} end}
   end 

   fun {CanBlockEnemyPawn GameBoard Move Color}
   	%{Print GameBoard}
   	local DestinationRow in 
   		DestinationRow = Move.stop.row+{GetDirection Color}
   		if {And DestinationRow > 0 {Board.getRowSize GameBoard} >= DestinationRow} then {Board.getType GameBoard DestinationRow Move.stop.col}=={GetOpponent Color} else false end 
   	end 
   end 

   fun {GetPawns GameBoard Color}
      {Board.filterTiles {Board.toTiles GameBoard} Color}
   end 

   fun {GetDistanceToFinish GameBoard Coord Color}
   		local Finish Size in
         	Size = {Board.getRowSize GameBoard}
     	    Finish = if Color==white then 1 else Size end 
 	   		{Abs Coord.row - Finish}
   		end  
   end 

   fun {GetOpponent Color}
      case Color
      of white then black 
      [] black then white 
      end 
   end

   %GameBoard = {Board.createBoard 5 5}

   %{Browse {GetValidMoves CBoard black}}

end 

