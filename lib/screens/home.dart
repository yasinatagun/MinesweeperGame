import 'dart:math';

import 'package:flutter/material.dart';
import 'package:minesweeper_app/widgets/bomb_widget.dart';
import 'package:minesweeper_app/widgets/box_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //* GRID VARIABLES
  int numberOfSquares = 9 * 9;
  int numberEachRow = 9;
  //* NUMBER OF BOMBS AROUND
  var squareStatus = [];
  //* BOMB LOCATIONS
  final List<int> bombLocations = [];
  bool bombRevealed = false;

  void putBombs() {
    Random random = Random();
    while (bombLocations.length < 10) {
      int a = random.nextInt(numberOfSquares);
      if (!bombLocations.contains(a)) {
        bombLocations.add(a);
      }
    }
  }

  void revealBoxNumbers(int index) {
    if (index < 0 || index >= numberOfSquares || squareStatus[index][1]) return;

    setState(() {
      squareStatus[index][1] = true; 
    });

    if (squareStatus[index][0] != 0) return;

    List<int> dx = [-1, 1, 0, 0, -1, -1, 1, 1];
    List<int> dy = [0, 0, -1, 1, -1, 1, -1, 1];

    for (int direction = 0; direction < 8; direction++) {
      int newRow = index ~/ numberEachRow + dx[direction];
      int newCol = index % numberEachRow + dy[direction];
      if (newRow >= 0 &&
          newRow < numberEachRow &&
          newCol >= 0 &&
          newCol < numberEachRow) {
        int newIndex = newRow * numberEachRow + newCol;
        if (!squareStatus[newIndex][1]) {
          revealBoxNumbers(newIndex);
        }
      }
    }
  }

  void restartGame() {
    setState(() {
      bombRevealed = false;
      for (var i = 0; i < numberOfSquares; i++) {
        squareStatus[i][1] = false;
      }
    });
  }

  void playerWon() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[700],
          title: const Center(
            child: Text(
              "YOU WON",
              style: TextStyle(color: Colors.white),
            ),
          ),
          actions: [
            MaterialButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
              color: Colors.white,
              onPressed: () {
                restartGame();
                Navigator.pop(context);
              },
              child: Center(child: Icon(Icons.refresh)),
            ),
          ],
        );
      },
    );
  }

  void checkWinner() {
    int unrevealedBoxes = 0;
    for (var i = 0; i < numberOfSquares; i++) {
      if (squareStatus[i][1] == false) {
        unrevealedBoxes++;
      }
    }

    if (unrevealedBoxes == bombLocations.length) {
      playerWon();
    }
  }

  void playerLost() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[700],
          title: const Center(
            child: Text(
              "YOU LOST",
              style: TextStyle(color: Colors.white),
            ),
          ),
          actions: [
            MaterialButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
              color: Colors.white,
              onPressed: () {
                restartGame();
                Navigator.pop(context);
              },
              child: const Center(child: Icon(Icons.refresh)),
            ),
          ],
        );
      },
    );
  }

  void scanBombs() {
    for (var i = 0; i < numberOfSquares; i++) {
      int numberOfBombsAround = 0;

      // Left
      if (i % numberEachRow != 0 && bombLocations.contains(i - 1)) {
        numberOfBombsAround++;
      }
      // Right
      if (i % numberEachRow != numberEachRow - 1 &&
          bombLocations.contains(i + 1)) {
        numberOfBombsAround++;
      }
      // Top
      if (i >= numberEachRow && bombLocations.contains(i - numberEachRow)) {
        numberOfBombsAround++;
      }
      // Bottom
      if (i < numberOfSquares - numberEachRow &&
          bombLocations.contains(i + numberEachRow)) {
        numberOfBombsAround++;
      }
      // Top Left
      if (i >= numberEachRow &&
          i % numberEachRow != 0 &&
          bombLocations.contains(i - 1 - numberEachRow)) {
        numberOfBombsAround++;
      }
      // Top Right
      if (i >= numberEachRow &&
          i % numberEachRow != numberEachRow - 1 &&
          bombLocations.contains(i + 1 - numberEachRow)) {
        numberOfBombsAround++;
      }
      // Bottom Left
      if (i < numberOfSquares - numberEachRow &&
          i % numberEachRow != 0 &&
          bombLocations.contains(i - 1 + numberEachRow)) {
        numberOfBombsAround++;
      }
      // Bottom Right
      if (i < numberOfSquares - numberEachRow &&
          i % numberEachRow != numberEachRow - 1 &&
          bombLocations.contains(i + 1 + numberEachRow)) {
        numberOfBombsAround++;
      }

      setState(() {
        squareStatus[i][0] = numberOfBombsAround;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < numberOfSquares; i++) {
      squareStatus.add([0, false]);
    }
    putBombs();
    scanBombs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          //* GAME STATS AND MENU
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //Display number of bombs
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(bombLocations.length.toString(),
                        style: const TextStyle(fontSize: 40)),
                    const Text("B O M B"),
                  ],
                ),
                // Refresh The Game
                GestureDetector(
                  onTap: restartGame,
                  child: Card(
                    color: Colors.grey[700],
                    child: const Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                // Display Time
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("6", style: TextStyle(fontSize: 40)),
                    Text("T I M E"),
                  ],
                ),
              ],
            ),
          ),
          //* GRID
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: numberOfSquares,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: numberEachRow),
              itemBuilder: (context, index) {
                if (bombLocations.contains(index)) {
                  return BombWidget(
                    revealed: bombRevealed,
                    function: () {
                      //PLAYER LOSE
                      setState(() {
                        bombRevealed = true;
                      });
                      playerLost();
                    },
                  );
                } else {
                  return BoxWidget(
                    child: squareStatus[index][0],
                    revealed: squareStatus[index][1],
                    function: () {
                      //PLAYER CONTINUE
                      revealBoxNumbers(index);
                      checkWinner();
                    },
                  );
                }
              },
            ),
          ),
          //* BRANDING
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text("C R E A T E D B Y Y A S I N"),
          )
        ],
      ),
    );
  }
}
