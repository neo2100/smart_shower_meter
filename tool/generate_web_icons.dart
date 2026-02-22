import 'dart:io';
import 'package:image/image.dart';

void main() {
  final srcPath = 'smart_shower_meter.png';
  final srcFile = File(srcPath);
  if (!srcFile.existsSync()) {
    stderr.writeln('Source image not found: $srcPath');
    exit(2);
  }

  final bytes = srcFile.readAsBytesSync();
  final src = decodeImage(bytes);
  if (src == null) {
    stderr.writeln('Failed to decode source image');
    exit(3);
  }

  final outDir = Directory('web/icons');
  if (!outDir.existsSync()) outDir.createSync(recursive: true);

  // Sizes to generate for web
  final sizes = <int>[192, 512];
  for (final size in sizes) {
    final resized = copyResize(
      src,
      width: size,
      height: size,
      interpolation: Interpolation.average,
    );
    // Create white background and composite if source has alpha
    final bg = Image(size, size);
    fill(bg, getColor(255, 255, 255));
    // center the resized image
    final x = (bg.width - resized.width) ~/ 2;
    final y = (bg.height - resized.height) ~/ 2;
    drawImage(bg, resized, dstX: x, dstY: y);
    final outPath = 'web/icons/Icon-$size.png';
    File(outPath).writeAsBytesSync(encodePng(bg));
    stdout.writeln('Wrote $outPath');

    // maskable variant (same image but named accordingly)
    final maskPath = 'web/icons/Icon-maskable-$size.png';
    File(maskPath).writeAsBytesSync(encodePng(bg));
    stdout.writeln('Wrote $maskPath');
  }

  // favicon (48x48)
  final fav = copyResize(
    src,
    width: 48,
    height: 48,
    interpolation: Interpolation.average,
  );
  final fb = Image(48, 48);
  fill(fb, getColor(255, 255, 255));
  drawImage(
    fb,
    fav,
    dstX: (fb.width - fav.width) ~/ 2,
    dstY: (fb.height - fav.height) ~/ 2,
  );
  File('web/favicon.png').writeAsBytesSync(encodePng(fb));
  stdout.writeln('Wrote web/favicon.png');
}
