import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/services/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() { super.initState(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFF00CEC9)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(24)),
                child: const Icon(Icons.event, size: 80, color: Colors.white),
              ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 32),
              Text('Event Bridge', style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800))
                .animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 8),
              Text('Connect. Collaborate. Celebrate.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70))
                .animate().fadeIn(delay: 500.ms),
              const SizedBox(height: 48),
              const CircularProgressIndicator(color: Colors.white, strokeWidth: 3).animate().fadeIn(delay: 700.ms),
            ],
          ),
        ),
      ),
    );
  }
}
