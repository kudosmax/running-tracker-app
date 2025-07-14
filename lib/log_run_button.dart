import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'run_provider.dart';

class LogRunButton extends StatelessWidget {
  const LogRunButton({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RunProvider>();
    final todayString = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final isRunToday = provider.runDates.contains(todayString);
    final size = MediaQuery.of(context).size;
    
    return Container(
      width: size.width - 40,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedScale(
        scale: provider.isLoading ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: isRunToday
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                  )
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
            boxShadow: [
              BoxShadow(
                color: (isRunToday 
                    ? const Color(0xFFFF6B6B) 
                    : const Color(0xFF667EEA)).withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 0,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: provider.isLoading ? null : () {
                // Haptic feedback
                HapticFeedback.lightImpact();
                context.read<RunProvider>().toggleToday();
              },
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (provider.isLoading)
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isRunToday ? Icons.check_rounded : Icons.directions_run_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    const SizedBox(width: 16),
                    Text(
                      isRunToday ? 'Run Logged!' : 'Log Today\'s Run',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
