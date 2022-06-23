import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:dotenv/dotenv.dart';
import 'package:dotenv_gen/dotenv_gen.dart';
import 'package:logging/logging.dart';
import 'package:source_gen/source_gen.dart';

import 'fields.dart';

class DotEnvGenAnnotationGenerator extends GeneratorForAnnotation<DotEnvGen> {
  final logger = Logger('dotenv_gen_runner:dotenv_gen');

  @override
  FutureOr<String> generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) throw Exception('@DotEnvGen annotation only supports classes');

    final filenames = annotation.read('filenames').listValue.map((e) => e.toStringValue()!);

    final className = element.name;
    final hasValidConstructor = element.constructors.any((e) {
      return e.name == '_' && e.isConst && e.parameters.isEmpty;
    });
    if (!hasValidConstructor) throw Exception('@DotEnvGen annotation requires a const $className._() constructor');

    final values = DotEnv()..load(filenames);
    final fields = [];
    for (final field in element.fields) {
      final value = values[field.name];
      final isAbstract = field.isAbstract || field.getter?.isAbstract == true;
      if (value == null && !isAbstract) continue;

      try {
        fields.add(Field.of(field, value));
      } on UnsupportedError catch (e) {
        if (isAbstract) rethrow;
        logger.warning(e.message);
      }
    }
  
    return """
      class _\$$className extends $className {
        const _\$$className() : super._();

        ${fields.map((e) => e.generate()).join('\n')}
      }
    """;
  }
}
