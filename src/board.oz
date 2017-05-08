functor 
export 
   createBoard: CreateBoard
   getTile: GetTile
   getType: GetType 
   submitMove: SubmitMove
   removePawn: RemovePawn
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

   %Initialise a list of length N with value Value
   fun {CreateList N Value}
      if N==0 then nil else Value | {CreateList N-1 Value} end 
   end

   %Appends a list of N values to the list
   fun {AppendRow List N Value}
      case List 
      of nil then {CreateList N Value}
      [] X|Xs then X|{AppendRow Xs N Value}
      end 
   end

   /**
    * Update the value in the list on the given index with a new value.
    * List: list to swap in
    * I: index to be swapped
    * X: new value for index in list
    */
   fun {Swap Xs I Y}
      case Xs of nil then nil
      [] X|Xr then if I==1 then Y|Xr else X|{Swap Xr I-1 Y} end 
      end 
   end 

   /**
    * Create a N*M board
    * N and M should be in [3,8]
    */
   fun {CreateBoard N M}
      {AppendRow {AppendRow [{CreateList M black}] N-2 {CreateList M empty}} 1 {CreateList M white} }
   end

   % Get the row with index X in the given board.
   fun {GetRow Board X}
      {List.nth Board X}
   end 

   % Get the type of coordinate (X,Y) in the board.
   fun {GetType Board X Y}
      {List.nth {GetRow Board X} Y}
   		
   end 

   % Get the tile of coordinate (X,Y) in the board. A tile is a tuple with a row, col and type value. 
   fun {GetTile Board X Y}
      local Coord=coord(row:X col:Y) in 
         if {IsInBoundaries Board Coord} then tile(row: X col:Y type:{GetType Board X Y}) else nil end 
      end       
   end

   % Sets the value of the tile with row X and col Y
   fun {SetType Board X Y Value}
      {Swap Board X {Swap {GetRow Board X} Y Value}}
   end 

   % Get the amount of rows in the board.
   fun {GetRowSize Board}
      {List.length Board}
   end 

   % Get the amount of columns in the board.
   fun {GetColumnSize Board}
      {List.length {GetRow Board 1}}
   end 

   % Update the board with the given move. 
   fun {SubmitMove Board Move}
      local TmpBoard in
      TmpBoard = {SetType Board Move.stopcoord.row Move.stopcoord.col {GetType Board Move.startcoord.row Move.startcoord.col}}
      {SetType TmpBoard Move.startcoord.row Move.startcoord.col empty}
      end 
   end 

   % Remove a pawn from the board.
   fun {RemovePawn Board Pawn}
   	{SetType Board Pawn.row Pawn.col empty}
   end 

   % Convert the given board to a 2-dimensional list of tiles. 
   % Tiles are tuples with a row, col and type value.
   fun {BoardToTiles Board}
      local BoardToTilesRecursive RowToTiles in 
         fun {RowToTiles Row RowIndex}
            {List.mapInd Row fun {$ I T} tile(type: T row: RowIndex col: I) end}
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

   % Filter the 2-dimensional list of tiles by only return tiles with the given type.
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

   % Check if the given coordinate is in the boundaries of the board.
   fun {IsInBoundaries Board Coord}
      {Not {Or {Or Coord.row < 1  Coord.row > {GetRowSize Board}}  {Or Coord.col < 1  Coord.col > {GetColumnSize Board}}}}
   end 

   % Get the neighbouring tiles of the given coord in the given direction. 
   fun {GetNeighbouringTiles Board Coord Direction}
      {List.filter [{GetTile Board Coord.row+Direction Coord.col} {GetTile Board Coord.row+Direction Coord.col-1} {GetTile Board Coord.row+Direction Coord.col+1}] fun {$ Tile} {Not Tile==nil} end}
   end 

   % Print the board to the console.
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