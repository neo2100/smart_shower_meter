import 'package:flutter/material.dart';
import '../models/shower_record.dart';
import '../services/database_service.dart';

class HistoryPage extends StatefulWidget {
  final List<ShowerRecord> records;

  const HistoryPage({super.key, required this.records});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final DatabaseService _databaseService = DatabaseService();

  Future<void> _editRecord(ShowerRecord record) async {
    double editedFlow = record.waterFlow;
    double editedCostFactor = record.waterUsageCostFactor;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Record Details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Shower ${record.id} - ${record.formattedDate}'),
                const SizedBox(height: 24),
                // Water Flow Section
                const Text(
                  'Water Flow Rate (L/s)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                Slider(
                  value: editedFlow,
                  min: 0.01,
                  max: 1.0,
                  divisions: 99,
                  label: editedFlow.toStringAsFixed(2),
                  onChanged: (value) {
                    setState(() {
                      editedFlow = value;
                    });
                  },
                ),
                Text(
                  '${editedFlow.toStringAsFixed(2)} L/s',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Water Usage: ${(record.duration.inSeconds * editedFlow).toStringAsFixed(2)} L',
                  style: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),
                // Cost Factor Section
                const Text(
                  'Cost per Liter (€/L)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                Slider(
                  value: editedCostFactor,
                  min: 0.0001,
                  max: 0.01,
                  divisions: 99,
                  label: editedCostFactor.toStringAsFixed(4),
                  onChanged: (value) {
                    setState(() {
                      editedCostFactor = value;
                    });
                  },
                ),
                Text(
                  '${editedCostFactor.toStringAsFixed(4)} €/L',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Shower Cost: ${((record.duration.inSeconds * editedFlow) * editedCostFactor).toStringAsFixed(2)} €',
                  style: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final updatedRecord = ShowerRecord(
        id: record.id,
        startTime: record.startTime,
        endTime: record.endTime,
        duration: record.duration,
        waterFlow: editedFlow,
        waterUsageCostFactor: editedCostFactor,
      );

      try {
        await _databaseService.updateRecord(updatedRecord);
        // Update the local list
        setState(() {
          final index = widget.records.indexWhere((r) => r.id == record.id);
          if (index != -1) {
            widget.records[index] = updatedRecord;
          }
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Record updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating record: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteRecord(ShowerRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: Text(
          'Are you sure you want to permanently delete Shower ${record.id} from ${record.formattedDate}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _databaseService.deleteRecord(record.id);
        // Update the local list
        setState(() {
          widget.records.removeWhere((r) => r.id == record.id);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Record deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting record: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedRecords = List<ShowerRecord>.from(widget.records)
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shower History'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: sortedRecords.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No shower records yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start recording your shower to see history',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: sortedRecords.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final record = sortedRecords[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.shower,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      'Shower ${record.id}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 14),
                            const SizedBox(width: 6),
                            Text(record.formattedDate),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 14),
                            const SizedBox(width: 6),
                            Text(record.formattedTime),
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              record.formattedDuration,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '(${record.waterFlow.toStringAsFixed(2)} L/s)',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  record.formattedWaterUsage,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        PopupMenuButton(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _editRecord(record);
                            } else if (value == 'delete') {
                              _deleteRecord(record);
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Edit'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: 18,
                                    color: Colors.red[600],
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Delete'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
