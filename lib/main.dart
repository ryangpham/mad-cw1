import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

void main() {
  runApp(const CounterImageToggleApp());
}

class CounterImageToggleApp extends StatelessWidget {
  const CounterImageToggleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CW1 Counter & Toggle',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _counter = 0;
  int _goal = 100;
  bool _isDark = false;
  bool _isFirstImage = true;

  late final AnimationController _controller;
  late final Animation<double> _fade;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _confettiController = ConfettiController(duration: const Duration(seconds: 5));
    _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _incrementCounter(int value) {
    setState(() {
      _counter += value;
      if (_counter >= _goal) _confettiController.play();
    });
  }

  void _toggleTheme() {
    setState(() => _isDark = !_isDark);
  }

  void _toggleImage() async {
    // Fade OUT
    await _controller.reverse();

    // Swap image
    setState(() {
      _isFirstImage = !_isFirstImage;
    });

    // Fade IN
    await _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('CW1 Counter & Toggle'),
          actions: [
            IconButton(
              onPressed: _toggleTheme,
              icon: Icon(_isDark ? Icons.light_mode : Icons.dark_mode),
            ),
          ],
        ),
        body: Stack(
          children: [
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 3.14159 / 2, // Downward
              blastDirectionality: BlastDirectionality.explosive, // Spread across screen
              shouldLoop: false,
              colors: const [Colors.red, Colors.blue, Colors.green],
              emissionFrequency: 0.1,
              numberOfParticles: 50,
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Counter: $_counter',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: _counter / _goal.clamp(1, double.infinity)),
                  const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(onPressed: () => _incrementCounter(1), child: const Text('+1')),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: () => _incrementCounter(5), child: const Text('+5')),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: () => _incrementCounter(10), child: const Text('+10')),
                ],
              ),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: _fade,
                child: Image.asset(
                  _isFirstImage ? 'assets/happy.jpg' : 'assets/frown.jpg',
                  width: 180,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _toggleImage,
                child: const Text('Toggle Image'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: TextEditingController(text: _goal.toString()),
                  onChanged: (value) => setState(() => _goal = int.tryParse(value) ?? 100),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Goal'),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
      ),
    );
  }
}