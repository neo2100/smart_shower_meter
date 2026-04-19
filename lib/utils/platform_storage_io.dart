import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

Future<String> saveJsonFile(String jsonData) async {
  final directory = Platform.isAndroid || Platform.isIOS
      ? await getApplicationDocumentsDirectory()
      : await getApplicationSupportDirectory();

  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final fileName = 'shower_records_$timestamp.json';
  final filePath = path.join(directory.path, fileName);
  final file = File(filePath);
  await file.writeAsString(jsonData);

  return fileName;
}

Future<String> readFileFromPath(String filePath) async {
  final file = File(filePath);
  return await file.readAsString();
}
