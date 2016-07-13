require "map"
require "routes"
require "utils"

--[[
  PIECES
  Pieces are the different branching paths of a iterating pathfinding system.
  They contain information about the environment, where the different route-heads currently reside,
  and contain the information to expand themselves.
  ]]

pieces = {};

-- Fucking awesome function to check if it even makes sense to place something somewhere :3
function pieces.is_viable(piece, pX, pY, type, rotation, length)
  rotation = rotation % 4;

  -- If the block type to be set is nil, then it's always possible
  if(type == nil) then return true; end
  -- If the position where the block should be set down is already occupied ... Stupid idea
  if(maps.get_block(piece[2], pX, pY)) then return false; end

  -- Direction offsets for the four different rotations (Up, down, left, right)
  local dX, dY = utils.rotationOffset(rotation);

  -- If it's an obstacle ... True, why not
  if(type == 1) then return true; end

  -- Check if the side of the converyor belt that it faces towards is actually free
  if(type == 2) then
    if(maps.get_block(piece[2], pX + dX, pY + dY)) then return false; end
    return true;
  end

  -- More complex tests are required for the underground conveyor belt!
  if(type == 3) then
    -- Check if the position for the output ubelt is free!
    if(maps.get_block(piece[2], pX + dX * length, pY + dY * length) or maps.get_block(piece[2], pX + dX * (length + 1), pY + dY * (length + 1))) then return false; end
    -- Iterate through all pieces between the entrance and exit of the UBelt, and make sure that there's no other Ubelt interfering!
    for i = 1, length - 1 do
      local mapblock = maps.get_block(piece[2], pX + dX * i, pY + dY * i);
      if(mapblock ~= nil and (mapblock[1] == 3 and (mapblock[2] % 2) == (rotation % 2))) then return false; end
    end

    return true;
  end

  -- Return false, just for good measure.
  return false;
end

-- Place a block if it is "viable" (makes sense), and return true. Otherwise false.
function pieces.place_if_viable(piece, pX, pY, type, rotation, length)
  if(not pieces.is_viable(piece, pX, pY, type, rotation, length)) then return false; end

  if(type == 1) then
    maps.set_block(piece[2], pX, pY, 1);
    return true;
  end

  if(type == 2) then
    maps.set_block(piece[2], pX, pY, 2, rotation);
    return true;
  end

  if(type == 3) then
    local dX, dY = utils.rotationOffset(rotation);
    
    maps.set_block(piece[2], pX, pY, 3, rotation);
    maps.set_block(piece[2], pX + dX * length, pY + dY * length, 3, rotation);
    return true;
  end

  return false;
end

-- Copy a piece and return the new table!
function pieces.copy(piece)
  local newpiece = {};
  newpiece[1] = routes.copy(piece[1]);
  newpiece[2] = maps.copy(piece[2]);

  return newpiece;
end

-- Generate a new piece, initialising the routes and the map.
function pieces.new(mapref)
  newpiece = {};

  newpiece[1] = routes.new();
  newpiece[2] = maps.new(mapref);

  return newpiece;
end
