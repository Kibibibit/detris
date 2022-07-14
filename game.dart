import 'dart:async';

import 'package:dcurses/dcurses.dart';

import 'gameobjects/point.dart';
import 'gameobjects/tetronimo.dart';
import 'windows/board.dart';
import 'windows/gameover.dart';
import 'windows/holdwindow.dart';
import 'windows/nextwindow.dart';
import 'windows/scoreboard.dart';

class Game {
  bool _running = false;
  bool get running => _running;
  late final Screen _screen;
  StreamSubscription<Key>? _subscription;

  int backToBacks = 0;
  int _score = 0;
  int get score => _score;
  void set score(int s) => _updateScore(s);

  void _updateScore(int s) {
    _score = s;
    _scoreBoard.update();
    _screen.refresh();
  }

  int linesCleared = 0;

  bool _gameOver = false;

  bool _canHold = true;

  int get level => (linesCleared / 10).floor() + 1;

  late Timer _timer;
  late Board _board;
  late ScoreBoard _scoreBoard;
  late HoldWindow _hold;
  late NextWindow _next;

  PieceType? hold;

  late Completer<bool> _gameCompleter;

  static final Map<int, int> _speed = {
    0: 48,
    1: 43,
    2: 38,
    3: 33,
    4: 28,
    5: 23,
    6: 18,
    7: 13,
    8: 8,
    9: 6,
    10: 5,
    13: 4,
    16: 3,
    19: 2,
    29: 1
  };

  int speed() {
    int l = level - 1;
    int frames = _speed[l] ?? 48;

    while (_speed[l] == null) {
      l--;
      frames = _speed[l] ?? 48;
    }

    return frames * 17; // Constant for 16.7 milliseconds per frame
  }

  int _hardDropped = 0;

  Tetronimo? _tetronimo;

  List<PieceType> order = [];

  Game(Screen screen) {
    _screen = screen;

    _createWindows();
  }

  void _addOrder() {
    if (order.length < 7) {
      List<PieceType> pieces = List.generate(
          PieceType.values.length, (index) => PieceType.values[index]);
      pieces.shuffle();
      order.addAll(pieces);
    }
  }

  Future<bool> run() async {
    _gameCompleter = Completer();
    _subscription = _screen.listen(_onKey);
    _running = true;
    _addOrder();
    _dropPiece();
    return await _gameCompleter.future;
  }

  void close() {
    _timer.cancel();
    _running = false;
    _subscription?.cancel();
  }

  void _createWindows() {
    _hold = HoldWindow("SCREEN::HOLD", 4, 0, this);
    _board = Board("SCREEN::BOARD", 4, 10, this);
    _scoreBoard = ScoreBoard("SCREEN::SCOREBOARD", 0, 0, this);
    _next = NextWindow("SCREEN::NEXT", 4, 10 + _board.columns, this);
    _screen.addWindow(_hold);
    _screen.addWindow(_next);
    _screen.addWindow(_scoreBoard);
    _screen.addWindow(_board);
    _updateScore(0);
    _next.draw();
    _hold.draw();
  }

  void _onKey(Key key) {
    if (!_gameOver) {
      if (key == Key.fromChar("R")) {
        close();
        _gameCompleter.complete(true);
        return;
      }

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
            _hardDropped++;
          }
          _dropPiece(null, true);
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
      if (key == Key.fromChar("w") && _canHold) {
        if (_tetronimo != null) {
          PieceType other = _tetronimo!.pieceType;
          _tetronimo = null;
          if (hold != null) {
            _timer.cancel();
            _dropPiece(hold);
          }
          hold = other;
          _canHold = false;
          _hold.draw();
        }
      }

      _board.update(_tetronimo);
    } else {
      if (key == Key.fromChar("q")) {
        close();
        _gameCompleter.complete(false);
        return;
      }
      if (key == Key.fromChar("r")) {
        close();
        _screen.removeWindow("SCREEN::GAMEOVER");
        _gameCompleter.complete(true);
        return;
      }
    }
    _screen.refresh();
  }

  void _dropPiece([PieceType? pieceType, bool hard = false]) {
    int timer = speed();
    if (_tetronimo != null) {
      if (_tetronimo!.clipping(_board)) {
        _endOfGame();
        return;
      }

      if (_tetronimo!.landed(_board)) {
        if (!hard) {
          timer = (timer * 1.5).floor();
        } else {
          timer = 0;
        }
        if (_board.offTop(_tetronimo!)) {
          _endOfGame();
          return;
        }

        _board.addPiece(_tetronimo!, _hardDropped * 2);
        _hardDropped = 0;
        _tetronimo = null;
      } else {
        _tetronimo!.pos.y += 1;
        _board.update(_tetronimo);
      }
    } else {
      _tetronimo = Tetronimo(Point(5, 0), pieceType ?? order.first);
      _canHold = true;
      if (pieceType != null) {
        hold = null;
      } else {
        order.removeAt(0);
      }

      _addOrder();
      _next.draw();
      _board.update(_tetronimo);
    }

    _screen.refresh();
    _timer = Timer(Duration(milliseconds: timer), _dropPiece);
  }

  void _endOfGame() {
    _gameOver = true;
    GameOver g = GameOver("SCREEN::GAMEOVER", this);
    _screen.addWindow(g);
    g.draw();
    _screen.refresh();
  }
}
