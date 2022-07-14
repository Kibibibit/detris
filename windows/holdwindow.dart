import 'package:dcurses/dcurses.dart';

import '../game.dart';
import 'windowint.dart';

class HoldWindow extends WindowInterface {

  final Game game;

  HoldWindow(String label, int y, int x, this.game) : super(label, y, x, 10, 8) {
    border = Border.rounded();
  }

  @override
  void draw() {
    clear();

    String hold = "HOLD";
    cx = cen(hold);
    cy = 1;

    addStr(hold);
    cy = 4;

    if (game.hold != null) {
      cx = 4;
      drawTetronimo(game.hold!);
    }

  }

}