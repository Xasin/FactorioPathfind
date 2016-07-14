require "piece"
require "piecedraw"
require "piecelist"

tPiece = pieces.new();
routes.add(tPiece[1], -50, -50, 50, 50);
tList = piecelists.new(tPiece);

while(not tList.winner) do
  piecelists.expand_best(tList);
end


pieces.draw(tList.winner);
