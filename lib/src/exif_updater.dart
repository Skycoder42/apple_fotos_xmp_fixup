// ignore_for_file: avoid_print

import 'dart:io';

import 'package:path/path.dart' as path;

import 'xmp_loader.dart';

class ExifUpdater {
  final XmpLoader _xmpLoader;

  ExifUpdater(this._xmpLoader);

  Future<void> fixDates(String imagePath) async {
    final xmpPath = path.setExtension(imagePath, '.xmp');
    final xmpData = await _xmpLoader.load(xmpPath);
    final createDate = xmpData.rdf.description.dateCreated;

    await _runExifTool([
      '-AllDates=${_toExifDate(createDate)}',
      imagePath,
    ]);
  }

  Future<void> _runExifTool(List<String> arguments) async {
    print('>>> Running exiftool ${arguments.join(' ')}...');
    final proc = await Process.start(
      'exiftool',
      arguments,
      mode: ProcessStartMode.inheritStdio,
    );
    final exitCode = await proc.exitCode;
    print('<<< Finished with exit code: $exitCode');
    if (exitCode != 0) {
      throw Exception('exiftool failed with exit code $exitCode');
    }
  }

  String _toExifDate(DateTime dateTime) {
    final dtUtc = dateTime.toUtc();
    final buffer = StringBuffer()
      ..write(dtUtc.year)
      ..write(':')
      ..writePad2(dtUtc.month)
      ..write(':')
      ..writePad2(dtUtc.day)
      ..write(' ')
      ..writePad2(dtUtc.hour)
      ..write(':')
      ..writePad2(dtUtc.minute)
      ..write(':')
      ..writePad2(dtUtc.second);
    return buffer.toString();
  }
}

extension on StringBuffer {
  void writePad2(int number) => write(number.toString().padLeft(2, '0'));
}
