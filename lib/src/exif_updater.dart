import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

import 'xmp_loader.dart';

class ExifUpdater {
  final XmpLoader _xmpLoader;

  const ExifUpdater(this._xmpLoader);

  Future<void> fixDates(String imagePath) async {
    final hasRequiredDates = await _streamExifTool([
          '-DateTimeOriginal',
          '-CreateDate',
          imagePath,
        ]).length ==
        2;

    if (hasRequiredDates) {
      return;
    }

    final xmpPath = path.setExtension(imagePath, '.xmp');
    final xmpData = await _xmpLoader.load(xmpPath);
    final createDate = xmpData.rdf.description.dateCreated;

    await _runExifTool([
      '-SubSecDateTimeOriginal=${_toExifDate(createDate)}',
      '-SubSecCreateDate=${_toExifDate(createDate)}',
      '-SubSecModifyDate=${_toExifDate(createDate)}',
      imagePath,
    ]);

    stderr.writeln('Updated timestamps of $imagePath to $createDate');
  }

  Future<void> _runExifTool(List<String> arguments) =>
      _streamExifTool(arguments).listen(stdout.writeln).asFuture();

  Stream<String> _streamExifTool(List<String> arguments) async* {
    StreamSubscription? errSub;
    try {
      final proc = await Process.start(
        'exiftool',
        arguments,
      );

      errSub = proc.stderr
          .transform(systemEncoding.decoder)
          .transform(const LineSplitter())
          .listen(stderr.writeln);

      yield* proc.stdout
          .transform(systemEncoding.decoder)
          .transform(const LineSplitter());

      final exitCode = await proc.exitCode;
      if (exitCode != 0) {
        throw Exception(
          'exiftool ${arguments.join(' ')} failed with exit code $exitCode',
        );
      }
    } finally {
      await errSub?.cancel();
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
