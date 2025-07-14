import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'log_run_button.dart';
import 'progress_header.dart';
import 'run_heatmap.dart';
import 'run_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Consumer<RunProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.runDates.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                ),
              );
            }

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Modern App Bar
                SliverAppBar(
                  expandedHeight: 120,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.black,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    title: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF06B6D4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        'Running',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    centerTitle: false,
                    titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
                  ),
                ),
                // Content
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 24),
                      // Progress Card
                      const ProgressHeader(),
                      const SizedBox(height: 32),
                      // Heatmap Section
                      _buildSectionTitle(context, 'Activity'),
                      const SizedBox(height: 16),
                      Container(
                        height: size.height * 0.4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF111827),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFF1F2937),
                            width: 1,
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(20),
                          child: RunHeatmap(),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Quick Stats
                      _buildQuickStats(context, provider),
                      SizedBox(height: 120 + padding.bottom), // Space for FAB
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: const LogRunButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, RunProvider provider) {
    final runDays = provider.runDates.length;
    final today = DateTime.now();
    final thisWeek = provider.runDates.where((date) {
      final runDate = DateTime.parse(date);
      final weekStart = today.subtract(Duration(days: today.weekday - 1));
      return runDate.isAfter(weekStart.subtract(const Duration(days: 1)));
    }).length;
    
    final thisMonth = provider.runDates.where((date) {
      final runDate = DateTime.parse(date);
      return runDate.month == today.month && runDate.year == today.year;
    }).length;

    return Container(
      padding: const EdgeInsets.all(24),
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
          Text(
            'Quick Stats',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(context, thisWeek.toString(), 'This Week'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(context, thisMonth.toString(), 'This Month'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(context, runDays.toString(), 'Total'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF06B6D4)],
          ).createShader(bounds),
          child: Text(
            value,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
