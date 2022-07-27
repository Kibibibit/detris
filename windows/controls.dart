
import 'package:dcurses/dcurses.dart';

class Controls extends Window {
  Controls(String label, int y, int x, int columns, int lines) : super(label, y, x, columns, lines) {

    cx = 1;
    cy = 1;
    addStr("← →/j l : left/right");
    cy = 2;
    cx = 1;
    addStr("    ↑/i : hard drop");
    cy = 3;
    cx = 1;
    addStr("    ↓/k : soft drop");
    cx = 1;
    cy = 4;
    addStr("    q e : rotate");
    cx = 1;
    cy = 5;
    addStr("      w : hold");
    cx = 1;
    cy = 6;
    addStr("      R : restart");

  }
  
  @override
  void draw() {
  }

}