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
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'Running Tracker',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: 22,
              letterSpacing: -0.5,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: isSmallScreen ? 60 : 70,
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
