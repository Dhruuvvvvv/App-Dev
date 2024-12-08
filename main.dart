import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(SplitterApp());
}

class SplitterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bill Splitter',
      home: BillSplitterScreen(),
    );
  }
}

class BillSplitterScreen extends StatefulWidget {
  @override
  _BillSplitterScreenState createState() => _BillSplitterScreenState();
}

class _BillSplitterScreenState extends State<BillSplitterScreen> {
  List<String> participants = [];
  Map<String, double> amounts = {};
  TextEditingController participantController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController customAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      participants = prefs.getStringList('participants') ?? [];
      amounts = Map<String, double>.from(
        Map<String, double>.from(prefs.getStringMap('amounts') ?? {}),
      );
    });
  }

  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('participants', participants);
    await prefs.setStringMap('amounts',
        amounts.map((key, value) => MapEntry(key, value.toString())));
  }

  void _addParticipant() {
    String participant = participantController.text.trim();
    if (participant.isNotEmpty && !participants.contains(participant)) {
      setState(() {
        participants.add(participant);
      });
      participantController.clear();
      _saveData();
    }
  }

  void _addExpense() {
    double amount = double.tryParse(amountController.text.trim()) ?? 0.0;
    if (amount > 0 && participants.isNotEmpty) {
      setState(() {
        double splitAmount = amount / participants.length;
        for (var participant in participants) {
          amounts[participant] = (amounts[participant] ?? 0.0) + splitAmount;
        }
      });
      amountController.clear();
      _saveData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: Text("Splitter"
      style: TextStyle(color: Colors.blue),),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                participants.clear();
                amounts.clear();
              });
              _saveData();
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: participantController,
              decoration: InputDecoration(
                labelText: 'Add Participant',
                border: OutlineInputBorder(),
              ),
            ),
            ElevatedButton(
              onPressed: _addParticipant,
              child: Text('Add Participant'),
            ),
            SizedBox(height: 10),
            Text('Participants: ${participants.join(', ')}'),
            SizedBox(height: 20),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter Total Bill Amount',
                border: OutlineInputBorder(),
              ),
            ),
            ElevatedButton(
              onPressed: _addExpense,
              child: Text('Split Bill Equally'),
            ),
            SizedBox(height: 10),
            Text('Amount each person owes:'),
            ...participants.map((person) {
              double amount = amounts[person] ?? 0.0;
              return ListTile(
                title: Text('$person owes ₹${amount.toStringAsFixed(2)}'),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

extension on SharedPreferences {
  getStringMap(String s) {}

  setStringMap(String s, Map<String, String> map) {}
}
