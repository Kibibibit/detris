import 'dart:math';

import '../windows/board.dart';
import 'block.dart';
import 'point.dart';

class Tetronimo {
  Point pos;

  List<Block> children;

  final PieceType pieceType;

  Tetronimo(this.pos, this.pieceType, [List<Block>? childs])
      : children = childs ?? _shape(pieceType);

  static List<Block> _shape(PieceType type) {
    return _pointMap[type]!.map((p) => Block(p, type)).toList();
  }

  static Map<PieceType, List<Point>> _pointMap = {
    PieceType.square: [Point(0, 0), Point(0, 1), Point(1, 0), Point(1, 1)],
    PieceType.line: [Point(0, -1), Point(0, 0), Point(0, 1), Point(0, 2)],
    PieceType.leftL: [Point(0, -1), Point(0, 0), Point(0, 1), Point(-1, 1)],
    PieceType.rightL: [Point(0, -1), Point(0, 0), Point(0, 1), Point(1, 1)],
    PieceType.leftS: [Point(-1, 1), Point(0, 1), Point(0, 0), Point(1, 0)],
    PieceType.rightS: [Point(1, 1), Point(0, 1), Point(0, 0), Point(-1, 0)],
    PieceType.t: [Point(0, 0), Point(-1, 1), Point(0, 1), Point(1, 1)]
  };

  bool landed(Board board) {
    bool landed = false;
    for (Block b in children) {
      if (board.blocks[min(max(0, pos.y + b.pos.y + 1), Board.height - 1)]
                  [pos.x + b.pos.x] !=
              null ||
          pos.y + b.pos.y + 1 >= Board.height) {
        landed = true;
        break;
      }
    }
    return landed;
  }

  bool _ls(int a, int b) {
    return a < b;
  }

  bool _geq(int a, int b) {
    return a >= b;
  }

  void left(Board board) => _move(board, true);
  void right(Board board) => _move(board, false);

  void _move(Board board, bool left) {
    int Function() bound = left ? leftBound : rightBound;
    int border = left ? 0 : Board.width;
    bool Function(int, int) fn = left ? _geq : _ls;
    int offset = left ? -1 : 1;
    if (fn(bound() + offset, border)) {
      for (Block b in children) {
        if (board.blocks[min(max(0, pos.y + b.pos.y), Board.height - 1)][pos.x + b.pos.x + offset] != null) {
          return;
        }
      }

      pos.x += offset;
    }
  }

  bool clipping(Board board) {
    for (Block b in children) {
      if (b.clipping(this, board)) {
        return true;
      }
    }
    return false;
  }

  void rotate(bool left, Board board) {

    Point oldPos = pos.clone();
    List<Block> oldChildren = List.generate(children.length, (index) => Block(children[index].pos.clone(), children[index].blockType));

    int clips = 0;

    for (Block b in children) {
      b.rotate(left);
    }

    while (clipping(board)) {
      pos.x += clips < 2 ? -1 : 1;
      clips++;
      if (clips >= 4) {
        pos = oldPos;
        children = oldChildren;
        return;
      }
    }


    while (leftBound() < 0) {
      pos.x++;
    }
    while (rightBound() > Board.width-1) {
      pos.x--;
    }
  }

  int leftBound() {
    int out = pos.x;
    for (Block b in children) {
      if (pos.x + b.pos.x < out) {
        out = pos.x + b.pos.x;
      }
    }
    return out;
  }

  int rightBound() {
    int out = pos.x;
    for (Block b in children) {
      if (pos.x + b.pos.x > out) {
        out = pos.x + b.pos.x;
      }
    }
    return out;
  }
}

enum PieceType { square, line, leftL, rightL, leftS, rightS, t }
