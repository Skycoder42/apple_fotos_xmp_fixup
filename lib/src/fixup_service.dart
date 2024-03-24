import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:rxdart/rxdart.dart';

import 'exif_updater.dart';

class FixupService {
  static const _ext = [
    '.jpg',
    '.jpeg',
  ];

  final ExifUpdater _exifUpdater;

  FixupService(this._exifUpdater);

  Future<void> fixup(Directory dir) async {
    final imageFiles = dir
        .list(recursive: true)
        .where((e) => e is File)
        .cast<File>()
        .where((f) => _ext.contains(path.extension(f.path).toLowerCase()))
        .bufferCount(Platform.numberOfProcessors);

    await for (final pack in imageFiles) {
      await Future.wait(pack.map(_fixup));
    }
  }

  Future<void> _fixup(File file) async {
    try {
      await _exifUpdater.fixDates(file.path);
    } on Exception catch (error, stackTrace) {
      print('ERROR on ${file.path}: $error');
      print(stackTrace);
    }
  }
}
