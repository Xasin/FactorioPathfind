require "piece"

-- Return the character for a piece at the given position.
function pieces.char_at(piece, pX, pY)
  local p = maps.get_block(piece[2], pX, pY);

  if(p == nil) then return " "; end

  if(p[1] == 1) then return "X"; end

  if(p[1] == 2) then
    if(p[2] == 0 or p[2] == 2) then return "-"; end
    return "|";
  end

  if(p[1] == 3) then
    if(p[2] == 0) then return ">"; end
    if(p[2] == 1) then return "\\"; end
    if(p[2] == 2) then return "<"; end
    return "^";
  end

  return " ";
end

-- Draw a piece onto the STDOUT
function pieces.draw(piece)
  print("Displaying piece " .. tostring(piece))

  local maxX, maxY, minX, minY = maps.get_size_params(piece[2]);

  local output = "  ";
  for x = minX, maxX do
    output = output .. tostring(math.floor(math.abs(x) / 10));
  end
  print(output);

  output = "  ";
  for x = minX, maxX do
    output = output .. tostring(math.abs(x) % 10)
  end
  print(output);


  for y = maxY, minY, -1 do
    output = tostring(math.floor(math.abs(y) / 10)) .. tostring(math.abs(y) % 10);

    for x = minX, maxX do
      output = output .. pieces.char_at(piece, x, y);
    end
    print(output);
  end
end
