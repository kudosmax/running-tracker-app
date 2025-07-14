import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'run_provider.dart';

class RunHeatmap extends StatelessWidget {
  const RunHeatmap({super.key});

  final int daysToDisplay = 365;
  final int columns = 24;

  // Modern color scheme
  static const Color colorUnfilled = Color(0xFF1F2937);
  static const Color colorFilled = Color(0xFF8B5CF6);

  @override
  Widget build(BuildContext context) {
    final runDates = context.watch<RunProvider>().runDates;
    final today = DateTime.now();
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 3.0;
        final boxSize = (constraints.maxWidth - (columns - 1) * spacing) / columns;
        final clampedBoxSize = boxSize.clamp(8.0, 18.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Legend
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Text(
                    'Less',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ...List.generate(5, (index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 2),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: index == 0 
                            ? colorUnfilled 
                            : colorFilled.withOpacity(0.2 + (index * 0.2)),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                  const SizedBox(width: 8),
                  Text(
                    'More',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Heatmap
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                  childAspectRatio: 1.0,
                ),
                itemCount: daysToDisplay,
                itemBuilder: (context, index) {
                  final date = today.subtract(Duration(days: daysToDisplay - 1 - index));
                  final dateString = DateFormat('yyyy-MM-dd').format(date);
                  final isRunDay = runDates.contains(dateString);
                  final isToday = DateFormat('yyyy-MM-dd').format(today) == dateString;

                  return GestureDetector(
                    onTap: () {
                      // Optional: Show date tooltip
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isRunDay 
                                ? 'Ran on ${DateFormat('MMM d').format(date)}' 
                                : 'No run on ${DateFormat('MMM d').format(date)}',
                          ),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: clampedBoxSize,
                      height: clampedBoxSize,
                      decoration: BoxDecoration(
                        color: isRunDay ? colorFilled : colorUnfilled,
                        borderRadius: BorderRadius.circular(4),
                        border: isToday 
                            ? Border.all(
                                color: Colors.white.withOpacity(0.6),
                                width: 2,
                              )
                            : null,
                        boxShadow: isRunDay 
                            ? [
                                BoxShadow(
                                  color: colorFilled.withOpacity(0.3),
                                  blurRadius: 4,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 2),
                                )
                              ] 
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
