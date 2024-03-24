import 'dart:io';

import 'package:path/path.dart' as path;

import 'xmp_loader.dart';

class ExifUpdater {
  final XmpLoader _xmpLoader;

  const ExifUpdater(this._xmpLoader);

  Future<void> fixDates(String imagePath) async {
    final xmpPath = path.setExtension(imagePath, '.xmp');
    final xmpData = await _xmpLoader.load(xmpPath);
    final createDate = xmpData.rdf.description.dateCreated;

    await _runExifTool([
      '-SubSecDateTimeOriginal=${_toExifDate(createDate)}',
      '-SubSecCreateDate=${_toExifDate(createDate)}',
      '-SubSecModifyDate=${_toExifDate(createDate)}',
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
    final buffer = StringBuffer()
      ..write(dateTime.year)
      ..write(':')
      ..writePad2(dateTime.month)
      ..write(':')
      ..writePad2(dateTime.day)
      ..write(' ')
      ..writePad2(dateTime.hour)
      ..write(':')
      ..writePad2(dateTime.minute)
      ..write(':')
      ..writePad2(dateTime.second);

    if (!dateTime.isUtc) {
      final hours = dateTime.timeZoneOffset.inHours;
      final minutes =
          (dateTime.timeZoneOffset - Duration(hours: hours)).inMinutes;
      buffer
        ..write('+')
        ..writePad2(hours)
        ..write(':')
        ..writePad2(minutes);
    }

    return buffer.toString();
  }
}

extension on StringBuffer {
  void writePad2(int number) => write(number.toString().padLeft(2, '0'));
}
