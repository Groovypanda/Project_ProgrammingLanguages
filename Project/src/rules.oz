functor 
export 
   getValidMoves: GetValidMoves
   isValidMove: IsValidMove
import 
   BoardFunc at './board.ozf'
define

   %Get a list of valid moves for the player with the given color.
   fun {GetValidMoves Board Color}
      local CreateValidMoves TilesToMoves in
         % Make a list of moves from a list of tiles. The moves will all have Start as starting coordinate and a move will be made for every destination coordinate in Dests.
         fun {TilesToMoves Start Dests}
            {List.map Dests fun {$ Dest} move(start: Start stop: Dest) end}
         end  
         % This function will return a list of moves the player can make starting from the given tiles. 
         fun {CreateValidMoves Board FromTiles}
            case FromTiles 
            of X|Xs then {List.append {CreateValidMoves Board Xs} {List.filter 
               {TilesToMoves X {BoardFunc.getNeighbouringTiles Board X {GetDirection Color}}} fun {$ Move} {IsValidMove Board Move.start Move.stop} end}}
            [] nil then nil 
            end 
         end 
         {CreateValidMoves Board {BoardFunc.filterTiles {BoardFunc.toTiles Board} Color}}
      end 
   end 

   /** 
    * Check if a player can move from the From coordinate to the To coordinate.
    *
    * From: Start coordinate
    * To: Stop coordinate 
    */
   fun {IsValidMove Board From To}
      local StartType Direction in 
         StartType = {BoardFunc.getType Board From.row From.col}
         Direction = {GetDirection StartType}
         {And 
            {Or {BoardFunc.isInBoundaries Board From} {BoardFunc.isInBoundaries Board To}} 
            {And 
               {Not {IsEmpty Board From}} 
               {Or 
                  {And {IsEmpty Board To} {IsAdjacent From To Direction}} 
                  {And {HasOppositeType Board To StartType} {IsDiagonal From To Direction}}}}}
      end 
   end 

   %Get the destination of the player with the given color in the gameboard.
   fun {GetDirection Color}
      case Color 
      of black then 1 
      [] white then ~1 
      else nil
      end 
   end 

   %Check if 2 coordinates are adjacent, the player can move from Coord1 to Coord2. 
   fun {IsAdjacent Coord1 Coord2 Direction}
      case Direction of nil then false else {And Coord1.col == Coord2.col (Coord2.row-(Coord1.row+Direction))==0} end      
   end 

   %Check if 2 coordinates are diagonal, the player can move from Coord1 to Coord2 if there is an enemy pawn in the other coordinate.
   fun {IsDiagonal Coord1 Coord2 Direction}
      case Direction of nil then false else {And (Coord2.row-(Coord1.row+Direction))==0 {Abs (Coord2.col - Coord1.col)} ==1 } end 
   end 

   %Check if the given coordinate is empty.
   fun {IsEmpty Board Coord}
      {BoardFunc.getType Board Coord.row Coord.col} == empty
   end

   %Check if the given coordinate has the opposite color.
   fun {HasOppositeType Board Coord Color}
      local Other in 
         Other = {BoardFunc.getType Board Coord.row Coord.col}
         case Other of empty then false 
            [] black then Color==white
            [] white then Color==black 
            else false 
         end 
      end 
   end 
end 