
import 'package:dcurses/dcurses.dart';

import '../gameobjects/block.dart';
import '../gameobjects/point.dart';
import '../gameobjects/tetronimo.dart';

abstract class WindowInterface extends Window {
  WindowInterface(String label, int y, int x, int columns, int lines) : super(label, y, x, columns, lines);


  int cen(String s) {
    return (columns / 2).floor() - (s.length / 2).floor();
  }

  void draw();

  void drawTetronimo(PieceType type) {
    Tetronimo t = Tetronimo(Point(0,0), type);

    int y = cy;
    int x = cx;

    for (Block b in t.children) {
      cy = y + b.pos.y;
      cx = x + (b.pos.x*2);
      add(b.ch);
      cx++;
      add(b.ch);
    }

    cy = y;
    cx = x;
  }

}