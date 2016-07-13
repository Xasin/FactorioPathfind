utils = {}

function utils.rotationOffset(r)
  r = r % 4;

  if(r == 0) then return 1, 0;
  elseif(r == 1) then return 0, -1;
  elseif(r == 2) then return -1, 0;
  elseif(r == 3) then return 0, 1;
  else return; end
end
