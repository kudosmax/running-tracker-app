import 'package:flutter/material.dart';
import 'data_migration_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  Map<String, dynamic>? _legacyData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLegacyData();
  }

  Future<void> _loadLegacyData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await DataMigrationService.getLegacyUserData();
      setState(() {
        _legacyData = data;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Legacy Data'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: const Color(0xFF111827),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Legacy User: escriboy',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: const Color(0xFF8B5CF6),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_legacyData != null) ...[
                            _buildInfoRow('User ID', _legacyData!['userId']),
                            _buildInfoRow('Total Runs', '${_legacyData!['totalRuns']}'),
                            if (_legacyData!['metadata'] != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                'Metadata:',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              ..._buildMetadataRows(_legacyData!['metadata']),
                            ],
                          ] else ...[
                            const Text('No legacy data found'),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_legacyData != null && _legacyData!['runs'] != null) ...[
                    Card(
                      color: const Color(0xFF111827),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recent Runs (Last 10)',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 12),
                            ..._buildRunsList(_legacyData!['runs']),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loadLegacyData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Refresh Data'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMetadataRows(Map<String, dynamic> metadata) {
    return metadata.entries.map((entry) {
      return _buildInfoRow(entry.key, entry.value.toString());
    }).toList();
  }

  List<Widget> _buildRunsList(List<dynamic> runs) {
    final recentRuns = runs.take(10).toList();
    return recentRuns.map<Widget>((run) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.directions_run,
              color: Color(0xFF8B5CF6),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              run.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }).toList();
  }
}