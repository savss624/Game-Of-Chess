import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_icons/flutter_icons.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(GameOfChess());
}

class GameOfChess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CollectionReference ref = FirebaseFirestore.instance.collection('Players');
  String name = '';
  var white = '';
  var black = '';

  updatePlayers() {
    ref.doc('Player1_Player2').get().then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        if(documentSnapshot['White'] != '' && documentSnapshot['Black'] != ''){
          ref.doc('Player1_Player2').update({
            'White': '',
            'Black': '',
          }).then((value) => print('Updated')).catchError((error) => print('Failed to Update'));
        }
      }
    });
    // ignore: deprecated_member_use
    Firestore.instance.collection('Players').snapshots().listen((QuerySnapshot querySnapshot) {
      // ignore: deprecated_member_use
      querySnapshot.documents.forEach((document) {
        print(document['White'].toString() + ' and ' + document['Black'].toString());
        setState(() {
          white = ' -- ' + document['White'].toString();
          black = ' -- ' + document['Black'].toString();
        });
      });
    });
  }

  @override
  void initState() {
    updatePlayers();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown.shade900,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 90),
            Center(
              child: Text(
                'Game Of Chess',
                style: TextStyle(fontFamily: 'MarcellusSC',
                  color: Colors.brown.shade200,
                  fontSize: 40,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            SizedBox(height: 100),
            Icon(
              FlutterIcons.chess_pawn_faw5s,
              color: Colors.white,
              size: 120,
            ),
            SizedBox(height: 100),
            Container(
              width: 200,
              child: TextField(
                style: TextStyle(fontFamily: 'MarcellusSC',
                    color: Colors.white
                ),
                onChanged: (value) {
                  name = value;
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: 'Your Good Name',
                  labelStyle: TextStyle(fontFamily: 'MarcellusSC',
                    color: Colors.white,
                  )
                ),
              ),
            ),
            SizedBox(height: 60),
            Center(
              child: FlatButton(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    color: Colors.brown.shade500,
                  ),
                  height: 50,
                  width: 240,
                  child: Center(
                    child: Text(
                        'White' + white,
                      style: TextStyle(fontFamily: 'MarcellusSC',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                onPressed: () {
                  if(white == ' -- ' && name != ''){
                    ref.doc('Player1_Player2').update({
                      'White': name,
                    }).then((value) => print('Updated')).catchError((error) => print('Failed to Update'));
                    white = name;
                    Navigator.push(
                        context,
                        PageTransition(
                            child: Match(player: 'WHITE', white: white.replaceAll(' -- ', ''), black: black.replaceAll(' -- ', '')),
                            type: PageTransitionType.fade,
                            duration: Duration(milliseconds: 625)));
                  }
                },
              ),
            ),
            SizedBox(height: 24),
            Center(
              child: FlatButton(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    color: Colors.brown.shade500,
                  ),
                  height: 50,
                  width: 240,
                  child: Center(
                    child: Text(
                      'Black' + black,
                      style: TextStyle(fontFamily: 'MarcellusSC',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                onPressed: () {
                  if(black == ' -- ' && name != ''){
                    ref.doc('Player1_Player2').update({
                      'Black': name,
                    }).then((value) => print('Updated')).catchError((error) => print('Failed to Update'));
                    black = name;
                    Navigator.push(
                        context,
                        PageTransition(
                            child: Match(player: 'BLACK', white: white.replaceAll(' -- ', ''), black: black.replaceAll(' -- ', '')),
                            type: PageTransitionType.fade,
                            duration: Duration(milliseconds: 625)));
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}


class Match extends StatefulWidget {
  String player;
  String black;
  String white;
  Match({this.player, this.black, this.white});
  @override
  _MatchState createState() => _MatchState();
}

class _MatchState extends State<Match> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  FlutterTts flutterTts = FlutterTts();

  message(text) async {
    // ignore: deprecated_member_use
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(text)));
    await flutterTts.setLanguage("en-US");
    await flutterTts.setVoice({"name": "Karen", "locale": "en-AU"});
    await flutterTts.setVolume(1.0);
    await flutterTts.speak(text);
  }

  CollectionReference ref = FirebaseFirestore.instance.collection('Players');
  ChessBoardController controller = ChessBoardController();

  updateMoveAndPlayers() {
    ref.doc('Player1_Player2').update({
      'updateMove': ['', ''],
    }).then((value) => print('Updated')).catchError((error) => print('Failed to Update'));
    // ignore: deprecated_member_use
    Firestore.instance.collection('Players').snapshots().listen((QuerySnapshot querySnapshot) {
      // ignore: deprecated_member_use
      querySnapshot.documents.forEach((document) {
        controller.makeMove(document['updateMove'][0], document['updateMove'][1]);
        print(document['updateMove'][0].toString() + ' to ' + document['updateMove'][1].toString());

        if(document['Black'] != '' && widget.black == '') {
          setState(() {
            widget.black = document['Black'];
          });
          ref.doc('Player1_Player2').update({
            'updateMove': ['', ''],
          }).then((value) => print('Updated')).catchError((error) => print('Failed to Update'));
        }

        if(document['White'] != '' && widget.white == '') {
          setState(() {
            widget.white = document['White'];
          });
          ref.doc('Player1_Player2').update({
            'updateMove': ['', ''],
          }).then((value) => print('Updated')).catchError((error) => print('Failed to Update'));
        }
      });
    });
  }

  @override
  void initState() {
    updateMoveAndPlayers();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
        ref.doc('Player1_Player2').update({
          'Black': '',
          'White': '',
        }).then((value) => print('Updated')).catchError((error) => print('Failed to Update'));
        Fluttertoast.showToast(
            msg: "Game Ended",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black54,
            textColor: Colors.white,
            fontSize: 13.0);
        return Navigator.push(
            context,
            PageTransition(
                child: HomePage(),
                type: PageTransitionType.fade,
                duration: Duration(milliseconds: 625)));
      },
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.brown.shade900,
          body: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                        Icons.person,
                      color: Colors.white,
                      size: 30,
                    ),
                    Text(
                      ' ' +  widget.white,
                      style: TextStyle(fontFamily: 'MarcellusSC',
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      widget.black + ' ',
                      style: TextStyle(fontFamily: 'MarcellusSC',
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 30,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'vs',
                      style: TextStyle(fontFamily: 'MarcellusSC',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        fontSize: 24
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(90.0),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    'Chess - Arena',
                    style: TextStyle(fontFamily: 'MarcellusSC',
                        color: Colors.brown.shade200,
                        fontSize: 24,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
              Center(
                child: ChessBoard(
                  chessBoardController: controller,
                  size: w,
                  onMove: (move) {
                    var status = controller.game.history;
                    String from = status[status.length - 1].move.fromAlgebraic.toString();
                    String to = status[status.length - 1].move.toAlgebraic.toString();
                    ref.doc('Player1_Player2').update({
                      'updateMove': [from, to],
                    }).catchError((error) => print('Failed to Update'));
                    print(from + ' to ' + to);
                  },
                  onCheckMate: (color) {
                    message('CheckMate');
                    if(color.toString().toUpperCase() == 'PIECECOLOR.' + widget.player)
                      Timer(Duration(milliseconds: 1500), () {
                        Fluttertoast.showToast(
                            msg: "You Lost",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.black54,
                            textColor: Colors.white,
                            fontSize: 13.0);
                      });
                    else
                      Timer(Duration(milliseconds: 1500), () {
                        Fluttertoast.showToast(
                            msg: "You Win",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.black54,
                            textColor: Colors.white,
                            fontSize: 13.0);
                      });
                  },
                  onDraw: () {
                    message('Match Draw');
                  },
                  whiteSideTowardsUser: 'Color.' + widget.player == 'Color.WHITE' ? true : false,
                  onCheck: (color) {
                    message('Check');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




