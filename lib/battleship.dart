import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class BattleshipPage extends StatefulWidget {
  final String accessToken;
  final Function? onGameCreated;
  final String? aiType;

  const BattleshipPage(
      {required this.accessToken, this.onGameCreated, this.aiType, super.key});
  @override
  State<BattleshipPage> createState() => _BattleshipPageState();
}

class _BattleshipPageState extends State<BattleshipPage> {
  List<List<bool>> selectedBoxes =
      List.generate(6, (_) => List.filled(6, false));
  List<String> selectedShips = [];
  final String baseUrl = 'http://165.227.117.48';

  Future<void> submitGame(BuildContext context) async {
    if (selectedBoxes.expand((row) => row).where((box) => box).length == 5) {
      List<String> alpha = ['', 'A', 'B', 'C', 'D', 'E'];

      for (int i = 1; i < 6; i++) {
        for (int j = 1; j < 6; j++) {
          if (selectedBoxes[i][j] == true) {
            selectedShips.add(alpha[j] + i.toString());
          }
        }
      }
      final Map<String, dynamic> requestBody = {'ships': selectedShips};

      if (widget.aiType != null) {
        requestBody['ai'] = widget.aiType;
      }

      print(selectedShips);

      final response = await http.post(
        Uri.parse('$baseUrl/games'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.accessToken}',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Game created successfully: ${data['message']}');
        if (widget.onGameCreated != null) {
          widget.onGameCreated!();
        }
        Navigator.pop(context, data);
      } else {
        print('Failed to create a game. Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Token Expired. Login again.'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select at least 5 boxes'),
        ),
      );
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Battleship'),
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

                return GestureDetector(
                  onTap: () {
                    if ((row == 0 && col == 0) ||
                        (row > 0 && col == 0 || row == 0 && col > 0)) {
                      return;
                    }

                    if (selectedBoxes[row][col]) {
                      setState(() {
                        selectedBoxes[row][col] = false;
                      });
                    } else {
                      if (selectedBoxes
                              .expand((row) => row)
                              .where((box) => box)
                              .length >=
                          5) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('You can select only 5 blocks'),
                          ),
                        );
                      } else {
                        setState(
                          () {
                            selectedBoxes[row][col] = true;
                          },
                        );
                      }
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      color:
                          selectedBoxes[row][col] ? Colors.blue : Colors.white,
                    ),
                    child: Center(
                      child: Text((row == 0 && col > 0)
                          ? String.fromCharCode('A'.codeUnitAt(0) + col - 1)
                          : (col == 0 && row > 0)
                              ? row.toString()
                              : row == 0 && col == 0
                                  ? ""
                                  : ""),
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: (selectedBoxes
                        .expand((row) => row)
                        .where((box) => box)
                        .length ==
                    5)
                ? () {
                    submitGame(context);
                  }
                : null,
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
