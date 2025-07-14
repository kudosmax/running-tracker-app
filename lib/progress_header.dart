import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'run_provider.dart';

class ProgressHeader extends StatelessWidget {
  const ProgressHeader({super.key});

  // Annual running goal: 365 days
  final int goalDays = 365;

  @override
  Widget build(BuildContext context) {
    final runDays = context.select((RunProvider p) => p.runDates.length);
    final progressPercentage = runDays / goalDays;
    final daysLeft = goalDays - runDays;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF1F2937),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Annual Goal',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    daysLeft > 0 ? '$daysLeft days to go' : 'Goal achieved! 🎉',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF06B6D4)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(progressPercentage * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Progress display
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF06B6D4)],
            ).createShader(bounds),
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  height: 1.0,
                ),
                children: [
                  TextSpan(text: runDays.toString()),
                  TextSpan(
                    text: ' / $goalDays',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Progress bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: const Color(0xFF1F2937),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progressPercentage.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF06B6D4)],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
