import 'package:flutter/material.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Make button more iPhone-friendly
    final buttonWidth = screenWidth * 0.85; // 85% of screen width
    final maxWidth = 320.0; // Maximum width
    final actualWidth = buttonWidth > maxWidth ? maxWidth : buttonWidth;

    return Container(
      width: actualWidth,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: isRunToday
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],
                ),
          boxShadow: [
            BoxShadow(
              color: (isRunToday ? const Color(0xFFEF4444) : const Color(0xFF4F46E5))
                  .withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: provider.isLoading ? null : () {
              context.read<RunProvider>().toggleToday();
            },
            borderRadius: BorderRadius.circular(28),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (provider.isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else
                    Icon(
                      isRunToday ? Icons.close_rounded : Icons.add_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  const SizedBox(width: 12),
                  Text(
                    isRunToday ? 'REMOVE RUN' : 'LOG TODAY',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: screenWidth < 350 ? 14 : 16,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
