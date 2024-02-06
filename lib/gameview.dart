import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class GameView extends StatefulWidget {
  final int gameId;
  final String accessToken;

  const GameView({required this.gameId, required this.accessToken, Key? key})
      : super(key: key);

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  late Map<String, dynamic> gameDetails = {};
  final String baseUrl = 'http://165.227.117.48';
  String? selectedCoordinate;

  @override
  void initState() {
    super.initState();
    fetchGameDetails();
  }

  Future<void> fetchGameDetails() async {
    final response = await http.get(
      Uri.parse('$baseUrl/games/${widget.gameId}'),
      headers: {'Authorization': 'Bearer ${widget.accessToken}'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        gameDetails = data;
        gameDetails['shots']?.removeWhere(
            (shot) => gameDetails['sunk']?.contains(shot) == true);
      });
    } else {
      print(
          'Failed to fetch game details. Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }
  }

  Future<void> playShot(String shot) async {
    final response = await http.put(
      Uri.parse('$baseUrl/games/${widget.gameId}'),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'shot': shot}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final sunkShip = data['sunk_ship'];
      final won = data['won'];
      setState(() {
        if (sunkShip) {
          gameDetails['sunk']?.add(shot);
          gameDetails['shots']?.remove(shot);
          print("Enemy ship hit.");
          print(gameDetails['wrecks']);
          print(gameDetails['shots']);
          print(gameDetails['ships']);
          print(gameDetails['sunk']);
        } else {
          if (!gameDetails['sunk']?.contains(shot) == true) {
            gameDetails['shots']?.add(shot);
            print("No enemy ship on this coordinate.");
            print(gameDetails['wrecks']);
            print(gameDetails['shots']);
            print(gameDetails['ships']);
            print(gameDetails['sunk']);
          }
        }
      });
      if (won) {
        _showWinDialog('YOU WON THE GAME!');
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.pop(context, true);
        });
      }
    } else if ((gameDetails['position'] == 1) && (gameDetails['turn'] == 2) ||
        (gameDetails['position'] == 2) && (gameDetails['turn'] == 1)) {
      const snackBar = SnackBar(
        content: Text('Waiting for Opponent to play'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      print('Failed to play shot. Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      _showLoseDialog("YOU LOSE THE GAME!");
    }
  }

  void _showWinDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Result'),
          content: Text(message),
        );
      },
    );
  }

  void _showLoseDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Result'),
          content: Text(message),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: fetchGameDetails(),
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Game #${widget.gameId}'),
          ),
          body: Column(
            children: [
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                  ),
                  itemCount: 36,
                  itemBuilder: (context, index) {
                    final row = index ~/ 6;
                    final col = index % 6;
                    final labelCoordinate = (row == 0 && col > 0)
                        ? String.fromCharCode('A'.codeUnitAt(0) + col - 1)
                        : (col == 0 && row > 0)
                            ? row.toString()
                            : "";
                    final coordinate = (row > 0 && col > 0)
                        ? String.fromCharCode('A'.codeUnitAt(0) + col - 1) +
                            (row).toString()
                        : "";
                    if (row == 0 && col == 0) {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          color: Colors.white,
                        ),
                      );
                    }
                    if (row == 0 || col == 0) {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          color: Colors.grey[300],
                        ),
                        child: Center(
                          child: Text(
                            labelCoordinate,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }
                    if (gameDetails['ships'] != null &&
                        gameDetails['ships'].contains(coordinate)) {
                      final isInShots =
                          gameDetails['shots']?.contains(coordinate) == true;
                      final isInSunk =
                          gameDetails['sunk']?.contains(coordinate) == true;
                      return GestureDetector(
                        onTap: () {
                          playShot(coordinate);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Text(
                              isInShots ? '🚤💣' : (isInSunk ? '🚤💥' : '🚤'),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    if (gameDetails['shots'] != null &&
                        gameDetails['shots'].contains(coordinate)) {
                      final isShip =
                          gameDetails['ships']?.contains(coordinate) == true;
                      final isInWrecks =
                          gameDetails['wrecks']?.contains(coordinate) == true;
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          color: Colors.grey,
                        ),
                        child: Center(
                          child: isShip
                              ? const Text(
                                  '🚤💣',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                )
                              : isInWrecks
                                  ? const Text(
                                      '💦💣',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    )
                                  : const Text(
                                      '💣',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                        ),
                      );
                    }
                    if (gameDetails['wrecks'] != null &&
                        gameDetails['wrecks'].contains(coordinate)) {
                      final isInSunk =
                          gameDetails['sunk']?.contains(coordinate) == true;
                      final isInShots =
                          gameDetails['shots']?.contains(coordinate) == true;
                      return GestureDetector(
                        onTap: () {
                          playShot(coordinate);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            color: Colors.grey,
                          ),
                          child: Center(
                            child: Text(
                              isInSunk ? '💦💥' : (isInShots ? '💦💣' : '💦'),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    if (gameDetails['sunk'] != null &&
                        gameDetails['sunk'].contains(coordinate)) {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          color: Colors.grey,
                        ),
                        child: const Center(
                          child: Text(
                            '💥',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    }
                    return GestureDetector(
                      onTap: () {
                        final currentCoordinate = coordinate;
                        setState(() {
                          selectedCoordinate = currentCoordinate;
                        });
                        playShot(selectedCoordinate!);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          color: Colors.white,
                        ),
                        child: const Center(
                          child: Text(''),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
