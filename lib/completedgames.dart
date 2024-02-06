import 'package:battleships/pastgamedetails.dart';
import 'package:flutter/material.dart';

class CompletedGames extends StatefulWidget {
  final List<dynamic> completedGames;
  final String accessToken;

  const CompletedGames(
      {required this.completedGames, required this.accessToken, Key? key})
      : super(key: key);

  @override
  State<CompletedGames> createState() => _CompletedGamesState();
}

class _CompletedGamesState extends State<CompletedGames> {
  late List<dynamic> games;

  @override
  void initState() {
    super.initState();
    games = widget.completedGames;
    games.sort((a, b) => b['id'].compareTo(a['id']));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Games'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: games.length,
        itemBuilder: (BuildContext context, int index) {
          final completedGame = games[index];
          return Card(
            elevation: 5,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PastGameDetails(
                      completedGame: completedGame,
                      accessToken: widget.accessToken,
                    ),
                  ),
                );
              },
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  'Game ID: ${completedGame['id']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          'Player 1',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text("  "),
                        Text(
                          'Player 2',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('${completedGame['player1']}'),
                        const Text("VS"),
                        Text('${completedGame['player2']}'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Text(
                        'Winner: ${getWinnerText(completedGame['status'])}',
                        style: const TextStyle(fontWeight: FontWeight.w400),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String getWinnerText(int status) {
    switch (status) {
      case 1:
        return 'Player 1';
      case 2:
        return 'Player 2';
      default:
        return 'Unknown';
    }
  }
}
