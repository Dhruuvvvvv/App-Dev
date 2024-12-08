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
      backgroundColor: Colors.deepPurple[200],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Center(
          child: Text(
            "Splitter",
            style: TextStyle(
              color: Colors.blue,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
      body: ListView(
        padding: EdgeInsets.all(150),
        children: [
          TextField(
            controller: participantController,
            decoration: InputDecoration(
              labelText: 'Add People',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(
            width: 20,
            child: ElevatedButton(
              onPressed: _addParticipant,
              child: Text('Store'),
            ),
          ),
          SizedBox(height: 10),
          Text(
            'People: ${participants.join(', ')}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
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
          Text(
            'Amount each person owes:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          ...participants.map((person) {
            double amount = amounts[person] ?? 0.0;
            return ListTile(
              title: Text(
                '$person owes ₹${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

extension on SharedPreferences {
  getStringMap(String s) {}

  setStringMap(String s, Map<String, String> map) {}
}
