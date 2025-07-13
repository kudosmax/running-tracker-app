import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'log_run_button.dart';
import 'progress_header.dart';
import 'run_heatmap.dart';
import 'run_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700;
    
    return Scaffold(
      backgroundColor: const Color(0xFF1e1e1e),
      appBar: AppBar(
        title: const Text(
          'Running Tracker',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: isSmallScreen ? 50 : 56,
      ),
      body: Consumer<RunProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.runDates.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth > 400 ? 20.0 : 16.0,
                vertical: isSmallScreen ? 8.0 : 16.0,
              ),
              child: Column(
                children: [
                  // 1. Progress Header
                  const ProgressHeader(),
                  SizedBox(height: isSmallScreen ? 16 : 24),
                  // 2. Run Heatmap
                  Expanded(
                    child: const RunHeatmap(),
                  ),
                  // Add bottom padding for floating button
                  SizedBox(height: isSmallScreen ? 80 : 100),
                ],
              ),
            ),
          );
        },
      ),
      // 3. Log Run Button
      floatingActionButton: const LogRunButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
