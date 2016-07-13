require "piece"
require "piecedraw"
require "piecelist"

tPiece = pieces.new();
routes.add(tPiece[1], 1, 1, 10, 10);
tList = piecelists.new(tPiece);

while(tList.winner == nil) do
  pieces.draw(piecelists.get_best(tList));
  piecelists.expand_best(tList);

  os.execute("sleep 1");
end
