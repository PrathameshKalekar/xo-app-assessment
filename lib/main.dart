import 'package:flutter/material.dart';

void main() => runApp(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: XOGame(),
      ),
    );

class XOGame extends StatefulWidget {
  const XOGame({Key? key}) : super(key: key);

  @override
  _XOGameState createState() => _XOGameState();
}

class _XOGameState extends State<XOGame> {
  List<String> board = List.generate(9, (_) => '');
  bool isXTurn = true;
  String winner = '';
  int xScore = 0;
  int oScore = 0;
  bool gameOver = false;
  String playerX = 'Player X';
  String playerO = 'Player O';
  bool isEditingX = false;
  bool isEditingO = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("XO-Assessment"),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildPlayerEditSection(),
            const SizedBox(height: 20),
            _buildTurnDisplay(),
            const SizedBox(height: 20),
            _buildScoreBoard(),
            const SizedBox(height: 20),
            Expanded(child: _buildBoard()),
            const SizedBox(height: 20),
            _buildRestartButton(),
          ],
        ),
      ),
    );
  }

  // Display current player turn
  Widget _buildTurnDisplay() {
    String currentPlayer = isXTurn ? playerX : playerO;
    return Text(
      '$currentPlayer\'s Turn',
      style: const TextStyle(
          fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }

  Widget _buildPlayerEditSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildPlayerName('X'),
        _buildPlayerName('O'),
      ],
    );
  }

  Widget _buildPlayerName(String player) {
    bool isEditing = player == 'X' ? isEditingX : isEditingO;
    String playerName = player == 'X' ? playerX : playerO;
    return Column(
      children: [
        isEditing
            ? SizedBox(
                width: 100,
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      if (player == 'X') {
                        playerX = value.isNotEmpty ? value : 'Player X';
                      } else {
                        playerO = value.isNotEmpty ? value : 'Player O';
                      }
                    });
                  },
                  decoration: InputDecoration(
                    labelText: player == 'X' ? 'Player X' : 'Player O',
                    filled: true,
                    fillColor: Colors.white12,
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              )
            : Text(
                playerName,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
        IconButton(
          icon: Icon(isEditing ? Icons.check : Icons.edit, color: Colors.black),
          onPressed: () {
            setState(() {
              if (player == 'X') {
                isEditingX = !isEditingX;
              } else {
                isEditingO = !isEditingO;
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildScoreBoard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildScoreTile(playerX, xScore),
        _buildScoreTile(playerO, oScore),
      ],
    );
  }

  Widget _buildScoreTile(String player, int score) {
    return Column(
      children: [
        Text(
          '$player',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        Text(
          '$score',
          style: const TextStyle(fontSize: 32, color: Colors.deepPurpleAccent),
        ),
      ],
    );
  }

  Widget _buildBoard() {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _onTileTap(index),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.deepPurpleAccent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                board[index],
                style: TextStyle(
                  fontSize: 48,
                  color: board[index] == 'X' ? Colors.blue : Colors.pink,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onTileTap(int index) {
    if (board[index].isEmpty && winner.isEmpty && !gameOver) {
      setState(() {
        board[index] = isXTurn ? 'X' : 'O';
        isXTurn = !isXTurn;
        _checkWinner();
      });
    }
  }

  void _checkWinner() {
    const List<List<int>> winConditions = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Horizontal
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Vertical
      [0, 4, 8], [2, 4, 6] // Diagonal
    ];

    for (var condition in winConditions) {
      String a = board[condition[0]];
      String b = board[condition[1]];
      String c = board[condition[2]];
      if (a == b && b == c && a.isNotEmpty) {
        setState(() {
          winner = a;
          gameOver = true;
          _showWinnerDialog(a == 'X' ? playerX : playerO);
          if (a == 'X') {
            xScore++;
          } else {
            oScore++;
          }
        });
        return;
      }
    }

    if (!board.contains('') && winner.isEmpty) {
      setState(() {
        winner = 'Draw';
        gameOver = true;
        _showWinnerDialog('Draw');
      });
    }
  }

  void _resetBoard() {
    setState(() {
      board = List.generate(9, (_) => '');
      winner = '';
      gameOver = false;
      isXTurn = true;
    });
  }

  void _showWinnerDialog(String winnerName) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(winner == 'Draw' ? 'It\'s a Draw!' : '$winnerName Wins!'),
        content: Text(winner == 'Draw'
            ? 'Try again to find a winner.'
            : '$winnerName has won the game!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetBoard();
            },
            child: const Text('Play Again'),
          )
        ],
      ),
    );
  }

  Widget _buildRestartButton() {
    return ElevatedButton(
      onPressed: _resetBoard,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      child: const Text(
        "Restart Game",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
