import 'dart:io';

import 'package:apple_fotos_xmp_fixup/src/exif_updater.dart';
import 'package:apple_fotos_xmp_fixup/src/fixup_service.dart';
import 'package:apple_fotos_xmp_fixup/src/xmp_loader.dart';

void main(List<String> arguments) async {
  try {
    final xmpLoader = XmpLoader();
    final exifUpdater = ExifUpdater(xmpLoader);
    final fixupService = FixupService(exifUpdater);

    final fixupDir = Directory(arguments.first);
    if (!fixupDir.existsSync()) {
      throw Exception('Fixup-Directory ${fixupDir.path} does not exist!');
    }

    await fixupService.fixup(fixupDir);
  } on Exception catch (error) {
    stderr.writeln(error);
  }
}
