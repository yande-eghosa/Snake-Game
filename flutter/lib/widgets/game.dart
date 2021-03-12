
import 'dart:async';
import 'dart:math' as Math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

class Pair {
  static Math.Random _rnd = Math.Random(new DateTime.now().millisecondsSinceEpoch);
  int x, y;
  Pair({
    @required this.x,
    @required this.y
  });
  Pair.random() {
    this.x = _rnd.nextInt(GameMap.cellCnt);
    this.y = _rnd.nextInt(GameMap.cellCnt);
  }
  Pair diff(int dx, int dy) {
    return Pair(x: x+dx, y: y+dy);
  }
  bool inBounds() {
    return x >= 0 && x < GameMap.cellCnt && y >= 0 && y < GameMap.cellCnt;
  }
  @override
  int get hashCode => x*GameMap.cellCnt+y;
  @override
  bool operator ==(other) {
    return other is Pair && (x == other.x) && (y == other.y);
  }
}

class GameMap extends StatefulWidget {
  final EdgeInsets margin;
  static final int cellCnt = 25;
  GameMap({Key key, this.margin}): super(key: key);
  @override
  _GameMapState createState() => _GameMapState();
}

class _GameMapState extends State<GameMap> {
  Timer timer;
  // Location of food
  Pair food;
  // List of snake cells
  List<Pair> points;
  // Snake length
  int length;

  final diffMap = [[0, 1], [1, 0], [0, -1], [-1, 0]];

  int direction = 1;
  int nextDirection = 0;
  set userNextDirection(int dir) {
    // Player shouldn't go backwards
    if((dir+2)%4 != direction) {
      nextDirection = dir;
    }
  }

  _GameMapState() : super() {
    resetGame();
  }

  @override
  void dispose() {
    super.dispose();
    if (timer != null) {
      timer.cancel();
    }
  }

  void resetGame() {
    points = [Pair(x: GameMap.cellCnt~/2, y: GameMap.cellCnt~/2)];
    length = 1;
    nextFood();
    timer = Timer.periodic(Duration(milliseconds: 250), (_) {
      var result = move();
      if (!result) {
        endGame();
      }
    });
  }
  void endGame() {
    timer.cancel();
    timer = null;
    dialogReplay() {
      Navigator.pop(context);
      resetGame();
    }
    dialogExit() {
      Navigator.pop(context);
      Navigator.pop(context);
    }
    showCupertinoDialog(context: context, builder: (context) => CupertinoAlertDialog(
      title: Text('Game over!'),
      content: Text('Score: $length'),
      actions: <Widget>[
        CupertinoDialogAction(
          child: const Text('Play again'),
          isDefaultAction: true,
          onPressed: dialogReplay,
        ),
        CupertinoDialogAction(
          child: const Text('Exit'),
          isDestructiveAction: true,
          onPressed: dialogExit,
        ),
      ],
    ));
  }

  bool move() {
    // Acknowledge direction change
    if (nextDirection != -1) {
      direction = nextDirection;
      nextDirection = -1;
    }
    // Get next head location
    var head = points[0];
    var nextHead = head.diff(diffMap[direction][0], diffMap[direction][1]);
    // CHeck if game ends
    if (!nextHead.inBounds()) {
      return false;
    }
    setState(() {
      // If the next point is food, add length (retain the tail)
      if (nextHead != food) {
        points.removeLast();
      } else {
        nextFood();
        length++;
      }
      points.insert(0, nextHead);
    });
    return true;
  }

  void nextFood() {
    do {
      food = Pair.random();
    } while (points.contains(food));
  }

  List<List<bool>> _buildMap() {
    var retMap = List<List<bool>>.generate(
        GameMap.cellCnt, (_) => List<bool>.filled(GameMap.cellCnt, false));
    for (var point in points) {
      retMap[point.x][point.y] = true;
    }
    return retMap;
  }

  Widget _buildRow(int row, List<bool> rowMap) {
    assert(rowMap.length == GameMap.cellCnt);
    List<Widget> cells = List<Widget>();
    for (var col = 0; col < GameMap.cellCnt; col++) {
      var color = rowMap[col] ? CupertinoColors.activeOrange : CupertinoColors
          .white;
      if (row == food.x && col == food.y) {
        color = CupertinoColors.activeGreen;
      }
      cells.add(Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              color: color,
            ),
          )
      ));
    }
    return Expanded(
        flex: 1,
        child: Row(children: cells)
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> rows = List<Widget>();
    final map = _buildMap();

    for (var i = 0; i < GameMap.cellCnt; i++) {
      rows.add(_buildRow(i, map[i]));
    }
    return Column(
        children: [
          Text('Score: $length'),
          AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              margin: widget.margin ?? EdgeInsets.all(8),
              color: Color.fromARGB(100, 0, 0, 255),
              child: Column(
                  children: rows
              ),
            ),
          ),
          CupertinoButton(
            onPressed: () => (userNextDirection = 3),
            child: Text('Up')
          ),
          CupertinoButton(
              onPressed: () => (userNextDirection = 0),
              child: Text('Right')
          ),
          CupertinoButton(
              onPressed: () => (userNextDirection = 1),
              child: Text('Down')
          ),
          CupertinoButton(
              onPressed: () => (userNextDirection = 2),
              child: Text('Left')
          )
        ]
    );
  }
}