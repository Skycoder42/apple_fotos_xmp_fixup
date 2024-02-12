import 'dart:io';

import 'package:xml/xml.dart';

import 'models/xmp.dart';

class XmpLoader {
  Future<XmpMeta> load(String path) async {
    final file = File(path);
    final stringData = await file.readAsString();
    final xmlData = XmlDocument.parse(stringData);
    final rootElement = xmlData.rootElement;
    final xmpMeta = XmpMeta.fromXmlElement(rootElement);
    return xmpMeta;
  }
}
