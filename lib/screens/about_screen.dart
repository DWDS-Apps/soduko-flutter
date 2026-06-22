import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.grid_on, size: 52, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text('Sudoku', style: TextStyle(
                fontSize: 32, fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary)),
              const SizedBox(height: 8),
              Text('Version 1.0.0',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
              const SizedBox(height: 24),
              Text(
                'A production-quality Sudoku game built with Flutter.\n'
                'Features multiple difficulty levels, daily challenges, '
                'statistics tracking, and a clean Material 3 design.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade700, height: 1.5)),
              const SizedBox(height: 32),
              Text('Built with ❤️ using Flutter & Dart',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
            ],
          ),
        ),
      ),
    );
  }
}
