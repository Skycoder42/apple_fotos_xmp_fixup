import 'package:meta/meta.dart';
import 'package:xml/xml.dart';
import 'package:xml_annotation/xml_annotation.dart' as annotation;

part 'xmp.g.dart';

@annotation.XmlSerializable(createMixin: true)
@annotation.XmlRootElement(name: 'xmpmeta', namespace: 'adobe:ns:meta/')
@immutable
class XmpMeta with _$XmpMetaXmlSerializableMixin {
  @annotation.XmlAttribute(name: 'xmptk', namespace: 'adobe:ns:meta/')
  final String xmpTk;

  @annotation.XmlElement(
    name: 'RDF',
    namespace: 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
  )
  final Rdf rdf;

  const XmpMeta({
    required this.xmpTk,
    required this.rdf,
  });

  factory XmpMeta.fromXmlElement(XmlElement element) =>
      _$XmpMetaFromXmlElement(element);

  @override
  String toString() => toXmlElement(
        namespaces: {
          'adobe:ns:meta/': 'x',
          'http://www.w3.org/1999/02/22-rdf-syntax-ns#': 'rdf',
          'http://ns.adobe.com/photoshop/1.0/': 'photoshop',
        },
      ).toXmlString(pretty: true);
}

@annotation.XmlSerializable(createMixin: true)
@immutable
class Rdf with _$RdfXmlSerializableMixin {
  @annotation.XmlElement(
    name: 'Description',
    namespace: 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
  )
  final Description description;

  const Rdf({
    required this.description,
  });

  factory Rdf.fromXmlElement(XmlElement element) =>
      _$RdfFromXmlElement(element);
}

@annotation.XmlSerializable(createMixin: true)
@immutable
class Description with _$DescriptionXmlSerializableMixin {
  @annotation.XmlAttribute(
    namespace: 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
  )
  final String about;

  @annotation.XmlElement(
    name: 'DateCreated',
    namespace: 'http://ns.adobe.com/photoshop/1.0/',
  )
  final DateTime dateCreated;

  const Description({
    required this.about,
    required this.dateCreated,
  });

  factory Description.fromXmlElement(XmlElement element) =>
      _$DescriptionFromXmlElement(element);
}
