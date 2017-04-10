functor 
export 
	setBoard: SetBoard 
	setTurn: SetTurn
	setGameState: SetGameState
	incrementIncorrectMoves: IncrementIncorrectMoves
import 
   System
   Browser(browse:Browse)
   Referee at './referee.ozf'
   Player at './player.ozf'
   Board at './board.ozf'
define
   
   fun {CreateGameState GameBoard}
   	state(incorrectMoves: 0 turn: white board: GameBoard)
   end 

   fun {SetBoard GameState Board}
   	{Record.adjoinAt GameState board Board}
   end 

   fun {SetTurn GameState Color}
    {Record.adjoinAt GameState turn Color}
    end 

   fun {SetGameState OldGameState NewGameState}
   {Record.adjoin OldGameState NewGameState }
   end 

   fun {IncrementIncorrectMoves GameState}
   	local SetIncorrectMoves in 
   		fun {SetIncorrectMoves GameState Amount}
    		{Record.adjoinAt GameState incorrectMoves Amount}
    	end 
	   	if {Not {Value.hasFeature GameState incorrectMoves}} then {SetIncorrectMoves GameState 1}
	   	else {SetIncorrectMoves GameState (GameState.incorrectMoves+1)} end
    end 
   end 

   fun {GetNextPlayer Color}
   	case Color
   	of white then black 
   	[] black then white 
   	end 
   end 

   proc {ReadStream AppStream}
   	case AppStream 
   		of X|Xs then {Browse X}
   	end 
   end 
   
   local P1Stream P1Port P2Stream P2Port RefStream RefPort AppStream AppPort in

	   proc {GameLoop GameState}
	   	{Port.send P1Port GameState}
	   end 

	   {Port.new P1Stream P1Port}
	   {Port.new P2Stream P2Port}
	   {Port.new RefStream RefPort}
	   {Port.new AppStream AppPort}
	   GameBoard = {Board.createBoard 5 5}
	   GameStateTmp = {CreateGameState GameBoard}
	   GameState = {SetBoard GameStateTmp GameBoard}
	   thread {ReadStream AppStream} end 
	   thread {GameLoop GameState} end
	   thread {Player.new P1Stream RefPort white} end
	   thread {Player.new P2Stream RefPort black} end
	   thread {Referee.new RefStream AppPort} end
   end 


   

/*
	local Move Valid NewGameState in 
   		Move = {Player.calculateMove GameState.board GameState.turn}
   		Valid = {Referee.checkMove GameState Move}
   		if Valid then NewGameState = {SetBoard GameState {Board.submitMove GameState.board Move}}
   		else NewGameState = {IncrementIncorrectMoves GameState} end
   		{Browse NewGameState}
   	end 

   GameState = {CreateGameState {Board.createBoard 5 5}}



   %GamePort = {Port.new GameState}
   {GameLoop GameState}
*/
end  