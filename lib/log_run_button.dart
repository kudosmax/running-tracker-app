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
      child: FloatingActionButton.extended(
        onPressed: provider.isLoading ? null : () {
          // Add haptic feedback for iOS-like experience
          // Call the provider method to toggle the run status
          context.read<RunProvider>().toggleToday();
        },
        backgroundColor: isRunToday ? Colors.redAccent : const Color(0xFFFFA726),
        elevation: 6,
        extendedPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        icon: provider.isLoading 
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(
                isRunToday ? Icons.close : Icons.add,
                color: Colors.white,
                size: 20,
              ),
        label: Text(
          isRunToday ? 'CANCEL TODAY\'S RUN' : 'LOG TODAY\'S RUN',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth < 350 ? 13 : 14,
            letterSpacing: 0.5,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  }
}
