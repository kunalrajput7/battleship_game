import 'dart:convert';
import 'package:battleships/battleship.dart';
import 'package:battleships/completedgames.dart';
import 'package:battleships/gameview.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class GameList extends StatefulWidget {
  final String username;
  final String accessToken;

  const GameList({
    required this.username,
    required this.accessToken,
    super.key,
  });

  @override
  State<GameList> createState() => _GameListState();
}

class _GameListState extends State<GameList> {
  List<dynamic> games = [];
  List<dynamic> completedGames = [];
  final String baseUrl = 'http://165.227.117.48';

  @override
  void initState() {
    super.initState();
    fetchGames();
  }

  Future<void> fetchGames() async {
    final response = await http.get(
      Uri.parse('$baseUrl/games'),
      headers: {'Authorization': 'Bearer ${widget.accessToken}'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> activeGames = [];
      final List<dynamic> newlyCompletedGames = [];

      for (final game in data['games']) {
        if (game['status'] == 0 || game['status'] == 3) {
          activeGames.add(game);
        } else if (game['status'] == 1 || game['status'] == 2) {
          final existingIndex = completedGames.indexWhere(
            (completedGame) => completedGame['id'] == game['id'],
          );

          if (existingIndex == -1) {
            newlyCompletedGames.add(game);
          }
        }
      }
      setState(() {
        completedGames.addAll(newlyCompletedGames);
      });
      setState(() {
        games = activeGames;
        print('Games Fetched Successfully');
      });
    } else {
      print('Failed to fetch games. Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }
  }

  Future<void> forfeitGame(int gameId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/games/$gameId'),
      headers: {'Authorization': 'Bearer ${widget.accessToken}'},
    );

    if (response.statusCode == 200) {
      print('Game forfeited successfully');
      final forfeitedGameIndex =
          games.indexWhere((game) => game['id'] == gameId);

      if (forfeitedGameIndex != -1) {
        final int winner =
            (widget.username == games[forfeitedGameIndex]['player1']) ? 2 : 1;

        final completedGame = {
          'id': gameId,
          'player1': games[forfeitedGameIndex]['player1'],
          'player2': games[forfeitedGameIndex]['player2'],
          'status': winner,
        };

        if (completedGame['player1'] != null &&
            completedGame['player2'] != null) {
          completedGames.add(completedGame);
        }

        games.removeAt(forfeitedGameIndex);

        setState(() {});
      }

      fetchGames();
    } else {
      print('Failed to forfeit the game. Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }
  }

  void _closeDrawer() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game List'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt_sharp),
            onPressed: () {
              fetchGames();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Center(
                child: Column(
                  children: [
                    const Text(
                      'Battleships',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                    const Divider(
                      color: Colors.transparent,
                    ),
                    Text(
                      'Logged in as ${widget.username}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add_sharp),
              title: const Text('New Game'),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BattleshipPage(
                      accessToken: widget.accessToken,
                      onGameCreated: () {
                        fetchGames();
                      },
                    ),
                  ),
                );
                if (result != null && result is bool && result) {
                  fetchGames();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.smart_toy_sharp),
              title: const Text('New Game(AI)'),
              onTap: () async {
                final aiType = await showDialog<String>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Select AI Type'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: const Text('Random AI'),
                            onTap: () => Navigator.pop(context, 'random'),
                          ),
                          ListTile(
                            title: const Text('Perfect AI'),
                            onTap: () => Navigator.pop(context, 'perfect'),
                          ),
                          ListTile(
                            title: const Text('One Ship AI'),
                            onTap: () => Navigator.pop(context, 'oneship'),
                          ),
                        ],
                      ),
                    );
                  },
                );
                if (aiType != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BattleshipPage(
                        accessToken: widget.accessToken,
                        onGameCreated: () {
                          fetchGames();
                        },
                        aiType: aiType,
                      ),
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.menu_book_sharp),
              title: const Text('Show Completed Games'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CompletedGames(
                      completedGames: completedGames,
                      accessToken: widget.accessToken,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout_sharp),
              title: const Text('Log Out'),
              onTap: () {
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: ListTile(
                  leading: const Icon(Icons.close),
                  title: const Text('Close Menu'),
                  onTap: _closeDrawer,
                ),
              ),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: games.length,
        itemBuilder: (BuildContext context, int index) {
          final game = games[index];
          return Dismissible(
            key: UniqueKey(),
            onDismissed: (direction) {
              forfeitGame(game['id']);
            },
            background: Container(
              color: const Color.fromARGB(255, 247, 89, 78),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16.0),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            child: GestureDetector(
              onTap: () {
                if (game['status'] != 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameView(
                        gameId: game['id'],
                        accessToken: widget.accessToken,
                      ),
                    ),
                  );
                }
              },
              child: Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    'Game ID: ${game['id']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('${game['player1'] ?? "(Matchmaking)"}'),
                          const Text("VS"),
                          Text('${game['player2'] ?? "(Matchmaking)"}'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        game['turn'] == 1
                            ? (widget.username == game['player1']
                                ? 'Your Turn'
                                : "Opponent's Turn")
                            : (widget.username == game['player2']
                                ? 'Your Turn'
                                : "Opponent's Turn"),
                        style: TextStyle(
                          color: game['turn'] == 1
                              ? const Color.fromARGB(255, 74, 166, 77)
                              : const Color.fromARGB(255, 255, 18, 1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
