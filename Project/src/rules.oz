functor 
export 
	getValidMoves: GetValidMoves
	isValidMove: IsValidMove
import 
	BoardFunc at './board.ozf'
define

	fun {GetValidMoves Board Type}
		local CreateValidMoves TilesToMoves in
			fun {TilesToMoves Start Dests}
				{List.map Dests fun {$ Dest} move(start: Start stop: Dest) end}
			end  
			fun {CreateValidMoves Board FromTiles}
				case FromTiles 
				of X|Xs then {List.append {CreateValidMoves Board Xs} {List.filter 
					{TilesToMoves X {BoardFunc.getNeighbouringTiles Board X {GetDirection Type}}} fun {$ Move} {IsValidMove Board Move.start Move.stop} end}}
				[] nil then nil 
				end 
			end 
			{CreateValidMoves Board {BoardFunc.filterTiles {BoardFunc.toTiles Board} Type}}
		end 
	end 

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

   fun {GetDirection Type}
      case Type 
      of black then 1 
      [] white then ~1 
      else nil
      end 
   end 

   fun {IsAdjacent Coord1 Coord2 Direction}
      case Direction of nil then false else {And Coord1.col == Coord2.col (Coord2.row-(Coord1.row+Direction))==0} end      
   end 

   fun {IsDiagonal Coord1 Coord2 Direction}
      case Direction of nil then false else {And (Coord2.row-(Coord1.row+Direction))==0 {Abs (Coord2.col - Coord1.col)} ==1 } end 
   end 

   fun {IsEmpty Board Coord}
      {BoardFunc.getType Board Coord.row Coord.col} == empty
   end

   fun {HasOppositeType Board Coord Type}
      local Other in 
         Other = {BoardFunc.getType Board Coord.row Coord.col}
         case Other of empty then false 
            [] black then Type==white
            [] white then Type==black 
            else false 
         end 
      end 
   end 

   %CBoard = {BoardFunc.createBoard 5 5}
   %{Browse CBoard}
   %{Browse {GetValidMoves CBoard black}}

end 