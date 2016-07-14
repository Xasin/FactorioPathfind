require "piece"
require "piecedraw"

--[[
  PIECELISTS
  A piecelist is basically a storage center for all the various expanded pieces of a pathfinding iterator.
  This file stores all pieces, filters out pieces worse than the current best, and expands a given piece.
  It thusly is the basic stepping stone for pathfinding.

  It comprises itself out of three things:
    1 - The actual piecelist, with all (un)expanded pieces
    winner - The current winner piece, meaning: the current best piece that has reached the goal
    winnerHeuristic - The heuristic of said winner piece, for quicker comparison to other pieces
]]

piecelists = {};

-- Insert a piece into the piecelist
-- However, before this happens, the piece will be checked for how good it compares to the current winner, if there is one!
-- If it is worse, it will be deleted.
function piecelists.insert(plist, piece)
  if(plist.winnerHeuristic ~= nil
      and routes.get_heuristic(piece[1], nil, true) >= plist.winnerHeuristic) then
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
-- Compare a piece against the current winner, and insert it as new, better winner
function piecelists.update_winner(plist, winnerP)
  if(plist.winnerHeuristic ~= nil
      and routes.get_heuristic(winnerP[1], nil, true) >= plist.winnerHeuristic) then
        return false;
  end

  if(routes.at_goal(winnerP[1], nil)) then

    plist.winnerHeuristic = routes.get_heuristic(winnerP[1], nil, true);
    plist.winner = winnerP;
    plist.winnerTime = os.time();

    return true;
  end

  return false;
end

-- Expand a piece's route "r" with normal conveyor belts
function piecelists.expand_route_belts(plist, piece, r)
  local pX, pY, pR = piece[1][r][1][1], piece[1][r][1][2], piece[1][r][1][3];
  local dX, dY = utils.rotationOffset(pR);

  -- The current head needs to be moved forwards, since it saves the current belt position, not the current free space following that head!
  pX, pY = pX + dX, pY + dY;

  for i = pR - 1, pR + 1 do
    local newpiece = pieces.copy(piece);

    if(pieces.place_if_viable(newpiece, pX, pY, 2, i)) then
      routes.append(newpiece[1], r, pX, pY, i, 1, 1);

      piecelists.insert(plist, newpiece);
    end
  end
end
-- Expand a piece's route "r" with underground conveyor belts :3
function piecelists.expand_route_ubelts(plist, piece, r)
  local pX, pY, pR = piece[1][r][1][1], piece[1][r][1][2], piece[1][r][1][3];
  local dX, dY = utils.rotationOffset(pR);

  -- The current head needs to be moved forwards, since it saves the current belt position, not the current free space following that head!
  pX, pY = pX + dX, pY + dY;

  for i = 2, 6 do
    local newpiece = pieces.copy(piece);

    if(pieces.place_if_viable(newpiece, pX, pY, 3, pR, i)) then
      routes.append(newpiece[1], r, pX + dX * i, pY + dY * i, pR, i + 1, 8);

      piecelists.insert(plist, newpiece);
    end
  end
end

-- Expand a piece, meaning: Go through all possible next steps of conveyor belts, underground belts, etc. etc.
function piecelists.expand(plist, piece)
  for i = 1, #piece[1] do
    if(not routes.at_goal(piece[1], i)) then
      piecelists.expand_route_belts(plist, piece, i);
      piecelists.expand_route_ubelts(plist, piece, i);
    end
  end
end

-- Just expand the current best piece. Best function to be used in an iterator. Also checks for a winner condition!
function piecelists.expand_best(plist);
  local bPiece = piecelists.get_best(plist);

  if(not piecelists.update_winner(plist, bPiece)) then
    piecelists.expand(plist, piecelists.get_best(plist));
  end

  piecelists.remove(plist, bPiece);
end

-- Return the current length of the piecelist
function piecelists.get_length(plist)
  local l = 0;
  for k, v in pairs(plist[1]) do
    l = l + 1;
  end
  return l;
end

-- Generate a new piecelist, with a startpiece!
function piecelists.new(startpiece)
  local newlist = {winner = nil, winnerHeuristic = nil, winnerTime = nil};
  newlist[1] = {startpiece};

  setmetatable(newlist, {__len = piecelists.get_length});

  return newlist;
end
