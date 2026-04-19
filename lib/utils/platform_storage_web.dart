// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

Future<String> saveJsonFile(String jsonData) async {
  final fileName =
      'shower_records_${DateTime.now().millisecondsSinceEpoch}.json';
  final encodedJson = Uri.encodeComponent(jsonData);
  final dataUrl = 'data:application/json;charset=utf-8,$encodedJson';

  final anchor = html.AnchorElement(href: dataUrl)
    ..setAttribute('download', fileName)
    ..style.display = 'none';

  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();

  return fileName;
}

Future<String> readFileFromPath(String filePath) async {
  throw UnsupportedError('readFileFromPath is not supported on web');
}
