functor 
export
   createPlayer: CreatePlayer
import 
   Browser(browse: Browse)
   System(printInfo: Print)
   Board at './Board.ozf'
   Rules at './rules.ozf'
   OS
define
   
   fun {CreatePort Proc}
      Sin in 
         thread for Msg in Sin do {Proc Msg} end 
      end 
      {NewPort Sin}
   end 

   fun {CreatePlayer Referee Color}
      {CreatePort proc {$ Msg}
         case Msg 
         of chooseSize() then 
            {Send Referee setSize(4 4)}
         [] chooseK(GameBoard) then
            local MaxK in
               MaxK = {IntToFloat {Board.getColumnSize GameBoard}}/2.0
               {Send Referee setK({FloatToInt {Floor MaxK}})} 
            end 
         [] removePawn(GameBoard) then 
            {Send Referee removePawn({List.nth {GetPawns GameBoard Color} 1})}
         [] doMove(GameGameBoard) then
            {Send Referee checkMove({CalculateMove GameGameBoard Color})}            
         end 
      end}  
   end 

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
                        Value = {GetValueMove GameBoard Move Color}
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

   fun {GetValueMove GameBoard Move Color}
      %If enemies are far, distance will be high, so it's safer to move.
      ({Board.getRowSize GameBoard} - {GetDistanceToFinish GameBoard Move.dest Color})
      + {GetNearestEnemyDistance GameBoard Move.dest Color} 
      + 10*{Board.getRowSize GameBoard}*{BooleanToInt ({Board.getType GameBoard Move.dest.x Move.dest.y} == {GetOpponent Color})}
      + {Board.getRowSize GameBoard}*{BooleanToInt {HasOppositeNeighbour GameBoard Move.start Color}} %Run away if this tile can be caught!
   end 

   fun {HasOppositeNeighbour GameBoard Coord Color}
      local HasOppositeNeighbourRecursive in 
         fun {HasOppositeNeighbourRecursive Neighbours Color}
            case Neighbours 
                  of Tile|Xs then if Tile.type == {GetOpponent Color} then true else {HasOppositeNeighbourRecursive Xs Color} end 
                  [] nil then false 
            end 
         end 
         {HasOppositeNeighbourRecursive {Board.getNeighbouringTiles GameBoard Coord {GetDirection Color}} Color}
      end 
   end 

    fun {GetDirection Type}
      case Type 
      of black then 1 
      [] white then ~1 
      else nil
      end 
   end 

   fun {BooleanToInt Bool}
      if Bool then 1 else 0 end 
   end 

   fun {GetEnemies GameBoard Color}
      {GetPawns GameBoard {GetOpponent Color}}
   end 

   fun {GetPawns GameBoard Color}
      {Board.filterTiles {Board.toTiles GameBoard} Color}
   end 

   fun {GetNearestEnemyDistance GameBoard Coord Color}
      local GetNearestEnemyRecursive in 
         fun {GetNearestEnemyRecursive Enemies CurrentNearest CurrentDistance}
            local Distance in 
               case Enemies
               of Enemy|Xs then 
                  Distance = {GetDistance Enemy Coord}
                  if CurrentNearest == nil then {GetNearestEnemyRecursive Xs Enemy Distance}
                  else 
                     if Distance < CurrentDistance then {GetNearestEnemyRecursive Xs Enemy Distance}
                     else {GetNearestEnemyRecursive Xs CurrentNearest CurrentDistance} end
                  end 
               [] nil then CurrentDistance
               end 
            end 
         end 
         {GetNearestEnemyRecursive {GetEnemies GameBoard Color} nil nil}
      end 
   end


   fun {SortMovesByValue Moves}
      {Sort Moves fun {$ Move1 Move2} Move1.start.x < Move2.start.x end}
   end 

   fun {GetDistanceToFinish GameBoard Coord Color}
      local Size in 
         Size = {Board.getRowSize GameBoard}
         case Color 
         of white then Size - Coord.x
         [] black then Coord.x - 1
         end 
      end 
   end 

   fun {GetDistance Coord1 Coord2} 
      {FloatToInt {Sqrt {IntToFloat {Pow Coord2.y - Coord1.y 2}} + {IntToFloat {Pow Coord2.x - Coord1.x 2}}}}
   end 

   fun {GetOpponent Color}
      case Color
      of white then black 
      [] black then white 
      end 
   end

   Moves = [move(start: coord(x:1 y:2) dest: coord(x:1 y:2)) move(start: coord(x:5 y:2) dest: coord(x:5 y:2)) move(start: coord(x:3 y:2) dest: coord(x:3 y:2))]
   {Browse {SortMovesByValue Moves}}
end 


