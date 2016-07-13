require "piece"
require "piecedraw"

--[[
  PIECELISTS
  A piecelist is basically a storage center for all the various expanded pieces of a pathfinding iterator.
  This file stores all pieces, filters out pieces worse than the current best, and expands a given piece.
  It thusly is the basic stepping stone for pathfinding.

  It comprises itself out of three things:
    1 - The actual piecelist, with all (un)expanded pieces
    2 - The current winner piece, meaning: the current best piece that has reached the goal
    3 - The heuristic of said winner piece, for quicker comparison to other pieces
]]

piecelists = {};

-- Insert a piece into the piecelist
-- However, before this happens, the piece will be checked for how good it compares to the current winner, if there is one!
-- If it is worse, it will simply be ignored, if it is however better, it will be set as new winner piece!
function piecelists.insert(plist, piece)
  if(plist[3] ~= nil
      and routes.get_heuristic(piece[1], nil, true) >= plist[3]) then
        return false;
  end

  if(routes.at_goal(piece[1], nil)) then
    plist[3] = routes.get_heuristic(piece[1], nil, true);
    plist[2] = piece;
    return false;
  end

  local i = 0;
  while(true) do
    if(plist[1][i] == nil) then
      plist[1][i] = piece;
      return true;
    end
    i = i + 1;
  end
end
-- Remopve a piece from the piecelist, most likely completely deleting it!
function piecelists.remove(plist, piece)
  for k,v in pairs(plist[1]) do
    if(v == piece) then
      plist[1][k] = nil;
      return;
    end
  end
end

-- Return the current best piece!
function piecelists.get_best(plist)
  local cBPiece, cBHeur = nil, 10000000;
  for k,v in pairs(plist[1]) do
    local pHeur = routes.get_heuristic(v[1], nil, nil);
    if(pHeur < cBHeur) then
      cBHeur = pHeur;
      cBPiece = v;
    end
  end

  return cBPiece;
end

-- Expand a piece's route "r" with normal conveyor belts
function piecelists.expand_route_belts(plist, piece, r)
  local pX, pY, pR = newpiece[1][r][1], newpiece[1][r][2], newpiece[1][r][3];

  for i = pR - 1, pR + 1 do
    newpiece = pieces.copy(piece);

    if(pieces.place_if_viable(newpiece, pX, pY, 2, i)) then
      piecelists.insert(plist, newpiece);
      routes.append(newpiece[1], r, pX, pY, i, 1, 1);
    end
  end
end

-- Expand a piece, meaning: Go through all possible next steps of conveyor belts, underground belts, etc. etc.
function piecelists.expand(plist, piece)
  piecelists.remove(plist, piece);

-- Generate a new piecelist, with a startpiece!
function piecelists.new(startpiece)
  local newlist = {};
  newlist[1] = {startpiece};
  return newlist;
end
