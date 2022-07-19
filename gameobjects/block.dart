
import 'dart:math';

import 'package:dcurses/dcurses.dart';

import '../windows/board.dart';
import 'point.dart';
import 'tetronimo.dart';

class Block {

  Point pos;
  PieceType blockType;
  Ch ch;

  Block(this.pos, this.blockType, [bool preview = false]) : ch = getBlockCh(blockType, preview);

  void rotate(bool left) {
    if (left) {
      int t = pos.x;
      pos.x = pos.y;
      pos.y = -t;
    } else {
      int t = pos.x;
      pos.x = -pos.y;
      pos.y = t;
    }
  }

  bool clipping(Tetronimo tetronimo, Board board) {
    int x = tetronimo.pos.x + pos.x;
    if (x < 0 || x > Board.width-1) {
      return true;
    }
    return board.blocks[min(Board.height-1, max(0,tetronimo.pos.y+pos.y))][tetronimo.pos.x+pos.x] != null;
  }

  static Ch getBlockCh(PieceType blockType, [bool preview = false]) {
    return Ch(preview ? _previewCode : blockCode, [_blockMap[blockType] ?? Modifier.fg(Colour.white)]);
  }

  static Map<PieceType, Modifier> _blockMap = {
    PieceType.square:Modifier.fg(Colour.brightorange),
    PieceType.line:Modifier.fg(Colour.cyan),
    PieceType.t:Modifier.fg(Colour.brightmagenta),
    PieceType.leftS:Modifier.fg(Colour.red),
    PieceType.rightS:Modifier.fg(Colour.green),
    PieceType.leftL:Modifier.fg(Colour.blue),
    PieceType.rightL: Modifier.fg(Colour.orange)
  };


  static final int blockCode = 0x2588;
  static int _previewCode = 0x2591;

}


