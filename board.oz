functor 
export 
   createBoard: CreateBoard
   getTile: GetTile
   getType: GetType 
   submitMove: SubmitMove
   toTiles: BoardToTiles
   filterTiles: FilterTiles
   getColumnSize: GetColumnSize
   getRowSize: GetRowSize
   isInBoundaries: IsInBoundaries
   getNeighbouringTiles: GetNeighbouringTiles
   print: PrintBoard 
import 
   System(printInfo: Print)
define

  /*Initialise a list of length N with value Value*/
   fun {CreateList N Value}
      if N==0 then nil else Value | {CreateList N-1 Value} end 
   end

   /*Appends a list of N values to the list*/
   fun {AppendRow List N Value}
      case List 
      of nil then {CreateList N Value}
      [] X|Xs then X|{AppendRow Xs N Value}
      end 
   end

   /*
   List: list to swap in
   I: index to be swapped
   X: new value for index in list
   */
   fun {Swap Xs I Y}
      case Xs of nil then nil
      [] X|Xr then if I==1 then Y|Xr else X|{Swap Xr I-1 Y} end 
      end 
   end 

   /* Default values are N = 5 and M = 5. N and M should be in [3,8] */
   fun {CreateBoard N M}
      {AppendRow {AppendRow [{CreateList M black}] N-2 {CreateList M empty}} 1 {CreateList M white} }
   end

   fun {GetRow Board X}
      {List.nth Board X}
   end 

   fun {GetType Board X Y}
      {List.nth {GetRow Board X} Y}
   end 

   fun {GetTile Board X Y}
      local Coord=coord(x:X y:Y) in 
         if {IsInBoundaries Board Coord} then tile(x: X y:Y type:{GetType Board X Y}) else nil end 
      end       
   end

   /*Sets the value of the tile with row X and col Y*/
   fun {SetType Board X Y Value}
      {Swap Board X {Swap {GetRow Board X} Y Value}}
   end 

   fun {GetRowSize Board}
      {List.length Board}
   end 

   fun {GetColumnSize Board}
      {List.length {GetRow Board 1}}
   end 

   fun {SubmitMove Board Move}
      local TmpBoard in
      TmpBoard = {SetType Board Move.dest.x Move.dest.y {GetType Board Move.start.x Move.start.y}}
      {SetType TmpBoard Move.start.x Move.start.y empty}
      end 
   end 

   fun {BoardToTiles Board}
      local BoardToTilesRecursive RowToTiles in 
         fun {RowToTiles Row RowIndex}
            {List.mapInd Row fun {$ I T} tile(type: T x: RowIndex y: I) end}
         end 
         fun {BoardToTilesRecursive Board RowIndex}
            case Board 
               of X|Xs then {RowToTiles X RowIndex}|{BoardToTilesRecursive Xs RowIndex+1} 
               [] nil then nil 
            end 
         end 
         {BoardToTilesRecursive Board 1}
      end 
   end 

   fun {FilterTiles Tiles Type}
      local FilterRow in 
         fun {FilterRow Row Type}
            {List.filter Row fun {$ Tile} Type == Tile.type end}
         end
         case Tiles 
            of X|Xs then 
            {List.append {FilterTiles Xs Type} {FilterRow X Type}}
            [] nil then nil 
         end 
      end 
   end 

   fun {IsInBoundaries Board Coord}
      {Not {Or {Or Coord.x < 1  Coord.x > {GetRowSize Board}}  {Or Coord.y < 1  Coord.y > {GetColumnSize Board}}}}
   end 

   fun {GetNeighbouringTiles Board Coord Direction}
      {List.filter [{GetTile Board Coord.x+Direction Coord.y} {GetTile Board Coord.x+Direction Coord.y-1} {GetTile Board Coord.x+Direction Coord.y+1}] fun {$ Tile} {Not Tile==nil} end}
   end 

   proc {PrintBoard Board}
      for I in 1..{GetColumnSize Board} do 
         {Print ' '}
      end 
      {Print '\n '}
      for Row in Board do 
         for Tile in Row do 
            case Tile of empty then {Print '- '}
            [] black then {Print 'b '}
            [] white then {Print 'w '}
            end 
         end 
         {Print '\n '}
      end 
      for I in 1..{GetColumnSize Board} do 
         {Print ' '}
      end 
      {Print '\n\n'}
   end 
end 