import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'run_provider.dart';

class ProgressHeader extends StatelessWidget {
  const ProgressHeader({super.key});

  // TODO: Make this configurable
  final int goalDays = 270;

  @override
  Widget build(BuildContext context) {
    final runDays = context.select((RunProvider p) => p.runDates.length);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'RUNNING GOAL',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 22,
                color: Colors.white,
              ),
              children: [
                TextSpan(
                  text: '$runDays',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFA726), // Orange accent
                  ),
                ),
                TextSpan(
                  text: '/$goalDays',
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
