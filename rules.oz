functor 
export 
	getValidMoves: GetValidMoves
	isValidMove: IsValidMove
import 
	BoardFunc at './board.ozf'
   	Browser(browse:Browse)
define

	fun {GetValidMoves Board Type}
		local CreateValidMoves TilesToMoves in
			fun {TilesToMoves Start Dests}
				{List.map Dests fun {$ Dest} move(start: Start dest: Dest) end}
			end  
			fun {CreateValidMoves Board FromTiles}
				case FromTiles 
				of X|Xs then {List.append {CreateValidMoves Board Xs} {List.filter 
					{TilesToMoves X {BoardFunc.getNeighbouringTiles Board X {GetDirection Type}}} fun {$ Move} {IsValidMove Board Move.start Move.dest} end}}
				[] nil then nil 
				end 
			end 
			{CreateValidMoves Board {BoardFunc.filterTiles {BoardFunc.toTiles Board} Type}}
		end 
	end 

	fun {IsValidMove Board From To}
      local StartType Direction in 
         StartType = {BoardFunc.getType Board From.x From.y}
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
      case Direction of nil then false else {And Coord1.y == Coord2.y (Coord2.x-(Coord1.x+Direction))==0} end      
   end 

   fun {IsDiagonal Coord1 Coord2 Direction}
      case Direction of nil then false else {And (Coord2.x-(Coord1.x+Direction))==0 {Abs (Coord2.y - Coord1.y)} ==1 } end 
   end 

   fun {IsEmpty Board Coord}
      {BoardFunc.getType Board Coord.x Coord.y} == empty
   end

   fun {HasOppositeType Board Coord Type}
      local Other in 
         Other = {BoardFunc.getType Board Coord.x Coord.y}
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