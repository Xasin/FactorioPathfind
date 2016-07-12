require "utils"

--[[
  ROUTES
  Routes are the main way of storing heuristic values, as well as the current position of a path.
  They consist of:
    1 - The current headpoint, with X and Y coordinates, as well as rotation
    2 - The current endpoint, with X and Y coordinates
    3 - The current total length of the route
    4 - The current total cost of the route
]]--

-- The heuristic factor values for the pathfinding. Used as defaults to compute, well, the heuristic
heuristicFactors = {costPerLen = 1.2, assumption = 1.2, length = 1, cost = 1.2};

routes = {};

-- Add a route to an existing routeobject. Mainly used for initialising.
function routes.add(routeobject, startX, startY, endX, endY)
  local newroute = { {startX - 1, startY, 0}, {endX, endY}, 0, 0};
  routeobject[#routeobject + 1] = newroute;
end

-- "Append" a route, meaning that its headpoint is re-set, and length and cost factors are added up.
function routes.append(routeobject, r, headX, headY, rotation, addLength, addCost)
  local newroute = routeobject[r];

  newroute[1] = {headX, headY, rotation};
  newroute[3] = newroute[3] + addLength;
  newroute[4] = newroute[4] + addCost;
end
-- Check if a specific route R, or, if R is nil, all routes, is/are at its/their goal(s)
function routes.at_goal(routeobject, r)
  if(r == nil) then
    for i = 1, #routeobject do
      if(not routes.at_goal(routeobject, i)) then
        return false;
      end
      return true;
    end
  else
    local cHead = routeobject[r][1];
    local cEnd = routeobject[r][2];
    return cHead[1] == cEnd[1] and cHead[2] == cEnd[2];
  end
end
-- Return the known length of route R, or, if R is nil, all routes
function routes.get_known_length(routeobject, r)
  if(r == nil) then
    local tLength = 0;
    for i = 1,#routeobject do
      tLength = tLength + routeobject[i][3];
    end

    return tLength;
  else
    return routeobject[r][3];
  end
end
-- Return the known cost of route R, or, if R is nil, for all routes
function routes.get_known_cost(routeobject, r)
  if(r == nil) then
    local tCost = 0;
    for i = 1,#routeobject do
      tCost = tCost + routeobject[i][4];
    end

    return tCost;
  else
    return routeobject[r][4];
  end
end
-- Return the expected remaining length for route R, or all routes if R is nil
function routes.get_remaining_length(routeobject, r)
  if(r == nil) then
    local tRemLength = 0;
    for i = 1,#routeobject do
      tRemLength = tRemLength + routes.get_remaining_length(routeobject, i);
    end

    return tRemLength;
  else
    local cHead = routeobject[r][1];
    local cEnd = routeobject[r][2];
    local dX, dY = utils.rotationOffset(routeobject[r][1][3]);

    return math.abs(cEnd[1] - cHead[1] - dX) + math.abs(cEnd[2] - cHead[2] - dY);
  end
end
-- Return the expected remaining cost for route R, or all routes if R is nil
function routes.get_remaining_cost(routeobject, r)
  return routes.get_remaining_length(routeobject, r) * heuristicFactors.costPerLen;
end
-- Return the total length, known and expected. Note: If "absolute" is set it will give the absolute minimum that can not be underscored, instead of a guestimated value.
function routes.get_total_length(routeobject, r, absolute)
  local assmFactor = heuristicFactors.assumption;
  if(absolute) then assmFactor = 1; end

  return routes.get_known_length(routeobject, r) + routes.get_remaining_length(routeobject, r) * assmFactor;
end
-- Return the total cost, known and expected. As above, if "absolute" is set it will return the absolute best value.
function routes.get_total_cost(routeobject, r, absolute)
  local assmFactor = heuristicFactors.assumption;
  if(absolute) then assmFactor = 1; end

  return routes.get_known_cost(routeobject, r) + routes.get_remaining_cost(routeobject, r) * assmFactor;
end
-- Return the total heuristic of the route R, or of all routes if R is nil.
function routes.get_heuristic(routeobject, r, absolute)
  return routes.get_total_length(routeobject, r, absolute) * heuristicFactors.length + routes.get_total_cost(routeobject, r, absolute) * heuristicFactors.cost;
end

-- Copy a route to a new table, preserving all data. Used to branch new paths.
function routes.copy(routeobject)
  local newobject = {};
  for i=1, #routeobject do
    local oldroute = routeobject[i];
    local newroute = {{oldroute[1][1], oldroute[1][2], oldroute[1][3]}, {oldroute[2][1], oldroute[2][2]}, oldroute[3], oldroute[4]};
    newobject[i] = newroute;
  end

  return newobject;
end

function routes.new()
  local newobject = {};

  return newobject;
end
