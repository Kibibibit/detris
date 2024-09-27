import 'package:dcurses/dcurses.dart';

import '../game.dart';

class ScoreBoard extends Window {
  final Game game;

  ScoreBoard(String label, int y, int x, this.game)
      : super(label, y, x, 42, 4) {
    border = Border.thick();
  }

  @override
  void onDraw() {}

  void update() {
    cx = 1;
    cy = 1;

    addStr("SCORE: ${game.score.toString().padLeft(10, "0")}");
    cy = 2;

    cx = 1;
    addStr("LINES: ${game.linesCleared.toString().padLeft(6, "0")}");

    String level = "LEVEL: ${game.level.toString().padLeft(3, "0")}";

    cx = columns - (level.length + 1);

    addStr(level);

    String combo = "COMBO: ${game.backToBacks}";

    cx = columns - (combo.length + 1);

    cy = 1;
    addStr(combo);
  }

  @override
  void draw() {}
}
