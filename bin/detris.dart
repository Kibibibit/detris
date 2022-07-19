
import 'package:dcurses/dcurses.dart';

import '../game.dart';

void main() async {

  Screen screen = Screen();
  screen.disableBlocking();
  screen.run();


  Game? game;
  
  while ((await game?.run()) ?? true) {
    game = Game(screen);
  }

  screen.close();

}