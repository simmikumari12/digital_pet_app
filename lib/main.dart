import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: DigitalPetApp(),
    debugShowCheckedModeBanner: false,
  ));
}

class DigitalPetApp extends StatefulWidget {
  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  String petName = "Kitten";
  int happinessLevel = 50;
  int hungerLevel = 50;
  
  final TextEditingController _nameController = TextEditingController();
  Timer? _hungerTimer;
  Timer? _winTimer;
  int _winSecondsThreshold = 0; // Tracks seconds spent > 80 happiness

  @override
  void initState() {
    super.initState();
    // Advanced Feature: Passive Hunger and Win Condition Check
    _hungerTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      _incrementHungerPassively();
    });

    // Check for Win Condition every second
    _winTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _checkWinCondition();
    });
  }

  void _checkWinCondition() {
    if (happinessLevel > 80) {
      _winSecondsThreshold++;
    } else {
      _winSecondsThreshold = 0; // Reset if happiness drops
    }

    if (_winSecondsThreshold >= 180) { // 3 minutes
      _showGameOverDialog("You Win!", "You kept your pet happy for 3 minutes!");
      _winSecondsThreshold = 0;
    }
  }

  void _incrementHungerPassively() {
    setState(() {
      hungerLevel = (hungerLevel + 5).clamp(0, 100);
      if (hungerLevel >= 100 && happinessLevel <= 10) {
        _showGameOverDialog("Game Over", "Your pet is too hungry and sad.");
      }
    });
  }

  void _showGameOverDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                happinessLevel = 50;
                hungerLevel = 50;
              });
            },
            child: Text("Restart"),
          )
        ],
      ),
    );
  }

  // --- Logic Methods ---
  void _playWithPet() {
    setState(() {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
      hungerLevel = (hungerLevel + 5).clamp(0, 100);
    });
  }

  void _feedPet() {
    setState(() {
      hungerLevel = (hungerLevel - 10).clamp(0, 100);
      happinessLevel = (hungerLevel < 30) 
          ? (happinessLevel - 20).clamp(0, 100) 
          : (happinessLevel + 10).clamp(0, 100);
    });
  }

  Color _getMoodColor() {
    if (happinessLevel > 70) return Colors.green;
    if (happinessLevel >= 30) return Colors.yellow;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Digital Pet Game')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Rename your pet',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => setState(() => petName = _nameController.text),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text('Pet Name: $petName', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              
              // Advanced Feature: Progress Bars
              Text("Happiness"),
              LinearProgressIndicator(
                value: happinessLevel / 100,
                backgroundColor: Colors.grey[300],
                color: _getMoodColor(),
                minHeight: 10,
              ),
              SizedBox(height: 10),
              Text("Hunger"),
              LinearProgressIndicator(
                value: hungerLevel / 100,
                backgroundColor: Colors.grey[300],
                color: Colors.orange,
                minHeight: 10,
              ),
              
              SizedBox(height: 30),
              ColorFiltered(
                colorFilter: ColorFilter.mode(_getMoodColor(), BlendMode.modulate),
                child: Image.asset('assets/pet_image.png', height: 150),
              ),
              
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: _playWithPet, child: Text("Play")),
                  ElevatedButton(onPressed: _feedPet, child: Text("Feed")),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hungerTimer?.cancel();
    _winTimer?.cancel();
    _nameController.dispose();
    super.dispose();
  }
}