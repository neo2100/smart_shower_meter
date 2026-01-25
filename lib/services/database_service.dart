import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import '../models/shower_record.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  List<ShowerRecord> _cachedRecords = [];
  bool _isInitialized = false;
  late SharedPreferences _prefs;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      _prefs = await SharedPreferences.getInstance();
      await _loadRecords();
      _isInitialized = true;
    }
  }

  Future<String> _getFilePath() async {
    late Directory directory;

    if (kIsWeb) {
      // Web: localStorage is handled by SharedPreferences automatically
      return 'web_storage';
    } else if (Platform.isAndroid || Platform.isIOS) {
      // Mobile: use app documents directory
      directory = await getApplicationDocumentsDirectory();
    } else {
      // Desktop: use app support directory
      directory = await getApplicationSupportDirectory();
    }

    return path.join(directory.path, 'shower_records.json');
  }

  Future<void> _loadRecords() async {
    try {
      if (kIsWeb) {
        // Web: load from SharedPreferences
        final jsonString = _prefs.getString('shower_records');
        if (jsonString != null) {
          final jsonData = jsonDecode(jsonString) as List<dynamic>;
          _cachedRecords = jsonData
              .map(
                (item) => ShowerRecord.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        } else {
          _cachedRecords = [];
        }
      } else {
        // Mobile/Desktop: load from file
        final filePath = await _getFilePath();
        final file = File(filePath);

        if (await file.exists()) {
          final content = await file.readAsString();
          final jsonData = jsonDecode(content) as List<dynamic>;
          _cachedRecords = jsonData
              .map(
                (item) => ShowerRecord.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        } else {
          _cachedRecords = [];
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading records: $e');
      }
      _cachedRecords = [];
    }
  }

  Future<void> _saveRecords() async {
    try {
      final jsonData = _cachedRecords.map((record) => record.toJson()).toList();
      final jsonString = jsonEncode(jsonData);

      if (kIsWeb) {
        // Web: save to SharedPreferences (which uses localStorage)
        await _prefs.setString('shower_records', jsonString);
      } else {
        // Mobile/Desktop: save to file
        final filePath = await _getFilePath();
        final file = File(filePath);

        // Create directory if it doesn't exist
        await file.parent.create(recursive: true);
        await file.writeAsString(jsonString);
      }

      _logRecords('saved');
    } catch (e) {
      if (kDebugMode) {
        print('Error saving records: $e');
      }
    }
  }

  // Insert a new shower record
  Future<int> insertRecord(ShowerRecord record) async {
    await _ensureInitialized();
    _cachedRecords.add(record);
    await _saveRecords();
    return record.id;
  }

  // Get all shower records
  Future<List<ShowerRecord>> getAllRecords() async {
    await _ensureInitialized();
    return List.from(_cachedRecords);
  }

  // Delete a specific record by id
  Future<int> deleteRecord(int id) async {
    await _ensureInitialized();
    final initialLength = _cachedRecords.length;
    _cachedRecords.removeWhere((record) => record.id == id);
    await _saveRecords();
    return initialLength - _cachedRecords.length;
  }

  // Update a record
  Future<int> updateRecord(ShowerRecord record) async {
    await _ensureInitialized();
    final index = _cachedRecords.indexWhere((r) => r.id == record.id);
    if (index != -1) {
      _cachedRecords[index] = record;
      await _saveRecords();
      return 1;
    }
    return 0;
  }

  // Delete all records
  Future<int> deleteAllRecords() async {
    await _ensureInitialized();
    final count = _cachedRecords.length;
    _cachedRecords.clear();
    await _saveRecords();
    return count;
  }

  // Get the highest ID in the database
  Future<int> getHighestId() async {
    await _ensureInitialized();
    if (_cachedRecords.isEmpty) {
      return 0;
    }
    return _cachedRecords.map((r) => r.id).reduce((a, b) => a > b ? a : b);
  }

  // Helper method to log records
  void _logRecords(String action) {
    if (kDebugMode) {
      final jsonData = _cachedRecords.map((record) => record.toJson()).toList();
      print('Records $action: ${_cachedRecords.length} total records');
      if (_cachedRecords.isNotEmpty) {
        print('Data: ${jsonEncode(jsonData)}');
      }
    }
  }
}
