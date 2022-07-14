import 'dart:io';
import 'dart:math';

import 'package:dcurses/dcurses.dart';

import '../game.dart';
import '../gameobjects/block.dart';
import '../gameobjects/tetronimo.dart';

class Board extends Window {
  List<List<Block?>> blocks =
      List.generate(height, (_) => List.generate(width, (_) => null));

  final Game game;
  final double tetrisMult = 1.2;

  Board(String label, int y, int x, this.game) : super(label, y, x, 22, 22) {
    border = Border.double();
  }

  static final Map<int, int> _scoring = {
    1: 100,
    2: 300,
    3: 500,
    4: 800
  };

  static final int height = 20;
  static final int width = 10;

  bool offTop(Tetronimo tetronimo) {
    for (Block b in tetronimo.children) {
      if (b.pos.y + tetronimo.pos.y < 0) {
        return true;
      }
    }
    return false;
  }

  void addPiece(Tetronimo tetronimo, [int hardDropped = 0]) {
    for (Block b in tetronimo.children) {
      blocks[tetronimo.pos.y + b.pos.y][tetronimo.pos.x + b.pos.x] = b;
    }
    drawBlocks();
    screen?.refresh();
    List<int> clearedLines = [];

    for (int y = 0; y < height; y++) {
      bool cleared = true;
      for (int x = 0; x < width; x++) {
        if (blocks[y][x] == null) {
          cleared = false;
          break;
        }
      }
      if (cleared) clearedLines.add(y);
    }

    if (clearedLines.isNotEmpty) {
      if (clearedLines.length == 4) {
        game.backToBacks = game.backToBacks+1;
      } else {
        game.backToBacks = 0;
      }
      game.linesCleared += clearedLines.length;

      int b = _scoring[clearedLines.length]!;

      game.score += max(b, b*((game.backToBacks-1)*tetrisMult).floor())*game.level + hardDropped;
      screen?.refresh();
      int flashes = 20;
      for (int f = 0; f < flashes; f++) {

        Colour flashColour = clearedLines.length != 4 ? Colour.white : Colour.values[Random().nextInt(Colour.values.length)];

        for (int line in clearedLines) {
          for (int x = 0; x < columns; x++) {
            cx = x;
            cy = line + 1;
            add(Ch(Block.blockCode,
                [Modifier.fg(f % 2 == 0 ? Colour.black :  flashColour)]));
          }
        }

        screen?.refresh();
        sleep(Duration(milliseconds: 25));
      }

      for (int line in clearedLines) {
        for (int x = 0; x < width; x++) {
          int y = line;
          while (y > 0) {
            blocks[y][x] = blocks[y - 1][x];
            blocks[y - 1][x] = null;
            y--;
          }
        }
      }
      screen?.refresh();
    }
  }

  void drawBlocks() {
    this.clear();

    

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        cy = y + 1;
        cx = (x * 2) + 1;

        List<Modifier> mods = [Modifier.fg(Colour.gray)];
        if ((cx-1)/2 % 2 == 0) {
          mods.add(Modifier.decoration(Decoration.faint));
        }

        add(Ch(0x2595, mods ));
        
        if (blocks[y][x] != null) {
          add(blocks[y][x]!.ch);
          cx++;
          add(blocks[y][x]!.ch);
        }
        
      }
    }
  }

  void update(Tetronimo? tetronimo) {
    drawBlocks();
    for (Block b in tetronimo?.children ?? []) {
      cx = ((tetronimo!.pos + b.pos).x * 2) + 1;
      cy = (tetronimo.pos + b.pos).y + 1;
      add(b.ch);
      cx++;
      add(b.ch);
    }
  }
}
