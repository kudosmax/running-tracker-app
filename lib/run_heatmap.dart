import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'run_provider.dart';

class RunHeatmap extends StatelessWidget {
  const RunHeatmap({super.key});

  final int daysToDisplay = 270;
  final int columns = 18;

  // --- Appearance ---
  static const Color colorFilled = Color(0xFFFFA726); // Bright Orange
  static const Color colorUnfilled = Color(0xFF424242); // Dark Grey

  @override
  Widget build(BuildContext context) {
    final runDates = context.watch<RunProvider>().runDates;
    final today = DateTime.now();
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Adjust columns based on screen width for better mobile experience
    final adaptiveColumns = screenWidth < 350 ? 15 : (screenWidth < 400 ? 16 : columns);
    final spacing = screenWidth < 350 ? 3.0 : 4.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double boxSize = (constraints.maxWidth - (adaptiveColumns - 1) * spacing) / adaptiveColumns;
        final double clampedBoxSize = boxSize.clamp(8.0, 20.0); // Ensure reasonable size

        return GridView.builder(
          physics: const BouncingScrollPhysics(), // iOS-style scrolling
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: adaptiveColumns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: 1.0,
          ),
          itemCount: daysToDisplay,
          itemBuilder: (context, index) {
            final date = today.subtract(Duration(days: daysToDisplay - 1 - index));
            final dateString = DateFormat('yyyy-MM-dd').format(date);
            final isRunDay = runDates.contains(dateString);

            return Container(
              width: clampedBoxSize,
              height: clampedBoxSize,
              decoration: BoxDecoration(
                color: isRunDay ? colorFilled : colorUnfilled,
                borderRadius: BorderRadius.circular(screenWidth < 350 ? 1.5 : 2.0),
                boxShadow: isRunDay ? [
                  BoxShadow(
                    color: colorFilled.withOpacity(0.3),
                    blurRadius: 2,
                    spreadRadius: 0.5,
                  )
                ] : null,
              ),
            );
          },
        );
      },
    );
  }
}
