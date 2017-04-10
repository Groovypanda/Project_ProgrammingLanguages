functor 
export
   new: PlayerThread
   calculateMove: CalculateMove
import 
   System
   BoardFunc at './board.ozf'
   Rules at './rules.ozf'
   Browser(browse:Browse)
   OS
define
   
   proc {PlayerThread PlayerStream RefPort Color}
      local ReadStream HandlePMessage in 
         proc {ReadStream PlayerStream}
            case PlayerStream
               of X|Xs then {HandlePMessage X} {ReadStream Xs}
               else skip
            end 
         end 
         proc {HandlePMessage Message}
                     {System.printInfo 6}
            {Port.send RefPort message(color: Color board:Message.board move: {CalculateMove Message.board Color})}
         end 
         {ReadStream PlayerStream}
      end 
   end 

   fun {CalculateMove Board Color}
      /*Return a random possible move*/
      {List.nth {Rules.getValidMoves Board Color} {OS.rand} mod 5 + 1}
   end 

   Board = {BoardFunc.createBoard 5 5}
   fun {GenerateBoards I N}
      {Delay 500}
      if I<N then message(board: {BoardFunc.createBoard 5 5})|{GenerateBoards I+1 N}
      else nil end
   end 
   %{Browse {PlayerThread {GenerateBoards 1 5} white}}
end 