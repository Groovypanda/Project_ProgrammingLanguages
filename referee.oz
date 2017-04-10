functor 
export 
	new: RefThread
	checkMove: CheckMove
import 
	System 
   Game at './game.ozf'
   Rules at './rules.ozf'
   Board at './board.ozf'
   Browser(browse:Browse)
define
     
 	proc {RefThread RefStream AppPort}
	  local ReadStream HandleMessage in 
         proc {ReadStream RefStream}
            case RefStream
               of X|Xs then {HandleMessage X} {ReadStream Xs}
               else skip
            end 
         end 
         proc {HandleMessage Message}
         	{Port.send AppPort {Record.adjoinAt Message correct {CheckMove Message.board Message.move Message.color}}}
         end 
         {ReadStream RefStream}
      end 	
   	end 

   	fun {CheckMove GameBoard Move Color}
   		{And {Board.getType GameBoard Move.start.x Move.start.y}==Color {Rules.isValidMove GameBoard Move.start Move.dest}}
   	end
end 

