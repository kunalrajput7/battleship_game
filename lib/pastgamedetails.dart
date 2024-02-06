import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class PastGameDetails extends StatefulWidget {
  final Map<String, dynamic> completedGame;
  final String accessToken;

  const PastGameDetails(
      {required this.completedGame, required this.accessToken, super.key});

  @override
  State<PastGameDetails> createState() => _PastGameDetailsState();
}

class _PastGameDetailsState extends State<PastGameDetails> {
  late Map<String, dynamic> gameDetails = {};
  final String baseUrl = 'http://165.227.117.48';

  @override
  void initState() {
    super.initState();
    fetchGameDetails();
  }

  Future<void> fetchGameDetails() async {
    final response = await http.get(
      Uri.parse('$baseUrl/games/${widget.completedGame['id']}'),
      headers: {'Authorization': 'Bearer ${widget.accessToken}'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        gameDetails = data;
        gameDetails['shots']?.removeWhere(
          (shot) => gameDetails['sunk']?.contains(shot) == true,
        );
      });
    } else {
      print(
          'Failed to fetch game details. Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: fetchGameDetails(),
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Game #${widget.completedGame['id']} Details'),
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
                          color: Colors.grey,
                        ),
                      );
                    }
                    if (row == 0 || col == 0) {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          color: Colors.grey,
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
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          color: Colors.white, // No blue color
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
                          color: Colors.white,
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
                                      '💥💣',
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
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          color: Colors.white,
                        ),
                        child: Center(
                          child: Text(
                            isInSunk ? '💦🚤' : (isInShots ? '💦💣' : '💦'),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
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
                          color: Colors.white,
                        ),
                        child: const Center(
                          child: Text(
                            '🚤',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    }
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        color: Colors.white,
                      ),
                      child: const Center(
                        child: Text(''),
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
