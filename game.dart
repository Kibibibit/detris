import 'dart:async';
import 'dart:math';

import 'package:dcurses/dcurses.dart';

import 'gameobjects/point.dart';
import 'gameobjects/tetronimo.dart';
import 'windows/board.dart';

class Game {
  bool _running = false;
  late final Screen _screen;
  StreamSubscription<Key>? _subscription;

  int score = 0;

  late Timer _timer;
  late Board _board;
  late Window _hold;
  late Window _next;

  Tetronimo? _tetronimo;

  List<PieceType> _order = [];

  Game() {
    _screen = Screen();

    _createWindows();
    _screen.disableBlocking();
  }

  void _addOrder() {
    if (_order.length < 7) {
      List<PieceType> pieces = List.generate(PieceType.values.length, (index) => PieceType.values[index]);
      pieces.shuffle();
      _order.addAll(pieces);
    }
  }

  void run() {
    _subscription = _screen.listen(_onKey);
    _screen.run();
    _running = true;
    _addOrder();
    _dropPiece();
  }

  void close() {
    _timer.cancel();
    _running = false;
    _subscription?.cancel();
    _screen.close();
  }

  void _createWindows() {
    _hold = Window("SCREEN::HOLD", 4, 0, 10, 5)..border=Border.rounded();
    _board = Board("SCREEN::BOARD", 4, 10);
    _next = Window("SCREEN::NEXT", 4, 10+_board.columns, 10, 5)..border=Border.rounded();
    _screen.addWindow(_hold);
    _screen.addWindow(_next);
    _screen.addWindow(_board);
  }

  void _onKey(Key key) {
    if (_tetronimo != null) {
      if (key == Key.leftArrow) {
        _tetronimo?.left(_board);
      }
      if (key == Key.rightArrow) {
        _tetronimo?.right(_board);
      }

      if (key == Key.upArrow) {
        _timer.cancel();
        while (!_tetronimo!.landed(_board)) {
          _tetronimo!.pos.y += 1;
        }
        _dropPiece();
      }

      if (key == Key.downArrow) {
        if (!_tetronimo!.landed(_board)) {
          _tetronimo!.pos.y += 1;
        }
      }
    }
    if (key == Key.fromChar("q")) {
      _tetronimo?.rotate(true, _board);
    }
    if (key == Key.fromChar("e")) {
      _tetronimo?.rotate(false, _board);
    }

    _board.update(_tetronimo);
    _screen.refresh();
  }

  void _dropPiece([bool setTimer = true]) {
    _addOrder();
    if (_tetronimo != null) {
      if (_tetronimo!.landed(_board)) {
        _board.addPiece(_tetronimo!);
        _tetronimo = null;
      } else {
        _tetronimo!.pos.y += 1;
        _board.update(_tetronimo);
      }
    } else {
      _tetronimo = Tetronimo(Point(5, 0), _order.first);
      _order.removeAt(0);
      _board.update(_tetronimo);
    }

    _screen.refresh();
    if (setTimer) {
      _timer = Timer(Duration(milliseconds: 500), _dropPiece);
    }
  }

  bool get running => _running;
}
