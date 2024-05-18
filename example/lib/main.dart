import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ChessController controller = ChessController();

  @override
  void initState() {
    controller.loadPGN("1. e4 e5 2. Nf3 Nc6 3. Bc4 Bc5");
    super.initState();
  }

  final list = ["Bb5", "Ba6"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess Demo'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: ChessBoardWidget(
                controller: controller,
                boardColor: BoardColor.green,
                square: BoardSquare(positions: list),
                onMove: () {},
                boardOrientation: PlayerColor.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
