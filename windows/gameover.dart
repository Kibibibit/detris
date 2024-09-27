import 'package:dcurses/dcurses.dart';

import '../game.dart';
import 'windowint.dart';

class GameOver extends WindowInterface {
  final Game game;

  GameOver(String label, this.game) : super(label, 0, 0, 40, 11) {
    border = Border.rounded();
  }

  @override
  void onDraw() {}

  void draw() {
    String gameOver = "GAME OVER!";
    cx = cen(gameOver);
    cy = 1;
    addStr(gameOver);

    String cleared = "You cleared ${game.linesCleared} lines,";

    cx = cen(cleared);
    cy = 3;

    addStr(cleared);

    String levels = "got to level ${game.level},";

    cx = cen(levels);
    cy = 4;

    addStr(levels);

    String scored = "and scored a total of:";

    cx = cen(scored);
    cy = 5;
    addStr(scored);

    String points = "${game.score} pts";

    cx = cen(points);
    cy = 6;
    addStr(points);

    String restart = "Press 'r' to restart";

    cx = cen(restart);
    cy = 8;
    addStr(restart);

    String quit = "Press 'q' to quit";

    cx = cen(quit);
    cy = 9;
    addStr(quit);
  }
}
