--[[
  MAPS
  Maps are the main way of storing the different environment data
  To save on space, only important things are stored, and a map reference for the static environment is used!

  A MAPS array consists of:
    1 - The map reference. This is just a table.
    2 - The actual map itself, with the various blocks, saved as integer numbers!

  Block types:
    Any block saved consists of a table of two integers, one being type, the other rotation. Types are set as the following:
      1 - OBSTACLE
      2 - Conveyor belt
      3 - Underground belt
]]--

maps = {};


-- Return the block at position pX pY, or nil if this block does not exist.
-- This will always preference the map reference!! If a mapref block exists at that position, any block in the actual map gets ignored!
function maps.get_block(map, pX, pY)
  if(map[1] ~= nil) then
    local refblock = maps.get_block(map[1], pX, pY) ~= nil;
    if(refblock) then return refblock; end
  end

  if(map[2][pX] == nil) then return nil;
  else return map[2][pX][pY][1], map[2][pX][pY][2]; end
end
-- Set the block at position pX, pY.
-- This completely ignores the map-ref, so don't be confused if a set block doesn't change anything - The mapref might have overridden it!
function maps.set_block(map, pX, pY, type, rotation)
  if(map[2][pX] == nil) then map[2][pX] = {}; end

  map[2][pX][pY] = {type, rotation};
end


-- Copy a map piece and return the copied table.
-- The map reference does NOT get copied! Instead, only the table pointer is.
function maps.copy(map)
  local newmap = {};
  newmap[1] = map[1];

  local newmapdata = {};
  for x, v in pairs(map[2]) do
    newmapdata[x] = {};
    for y, b in pairs(v) do
      newmapdata[x][y] = {b[1], b[2]};
    end
  end

  newmap[2] = newmapdata;

  return newmap;
end

-- Create a new map. Can be done with a mapref!
function maps.new(mapref)
  local newobject = {mapref, {}};

  return newobject;
end
