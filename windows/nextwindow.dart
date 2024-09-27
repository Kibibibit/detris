import 'package:dcurses/dcurses.dart';

import '../game.dart';
import '../gameobjects/tetronimo.dart';
import 'board.dart';
import 'windowint.dart';

class NextWindow extends WindowInterface {
  final Game game;

  NextWindow(String label, int y, int x, this.game)
      : super(label, y, x, 10, Board.height + 2) {
    border = Border.rounded();
  }

  @override
  void onDraw() {}

  void draw() {
    clear();
    String n = "NEXT";
    cx = cen(n);
    cy = 1;
    addStr(n);

    cy = 3;
    cx = 4;
    for (PieceType t in game.order.take(4).toList()) {
      drawTetronimo(t);

      cy += 5;
    }
  }
}
