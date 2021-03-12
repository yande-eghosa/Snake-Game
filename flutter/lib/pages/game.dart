
import 'package:flutter/cupertino.dart';
import 'package:snake/widgets/game.dart';

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Game'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            GameMap()
          ],
        )
      )
    );
  }
}