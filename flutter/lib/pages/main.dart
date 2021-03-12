

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:snake/pages/game.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Home'),
      ),
      child: SizedBox.expand(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Snake Game',
              style: TextStyle(
                fontSize: 48,
              )
            ),
            Text('github: yande-eghosa'),
            Container(
              margin: EdgeInsets.fromLTRB(0, 16, 0, 0),
              child: CupertinoButton(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                child: Text('Start'),
                color: CupertinoColors.activeBlue,
                onPressed: () => Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => GamePage())
                ),
              )
            )
          ],
        ),
      )
    );
  }
}
