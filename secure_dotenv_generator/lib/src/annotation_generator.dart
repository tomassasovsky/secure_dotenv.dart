import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:dotenv/dotenv.dart';
import 'package:logging/logging.dart';
import 'package:secure_dotenv/secure_dotenv.dart';
import 'package:secure_dotenv_generator/src/helpers.dart';
import 'package:source_gen/source_gen.dart';

import 'fields.dart';

final logger = Logger('secure_dotenv_generator:secure_dotenv');

class SecureDotEnvAnnotationGenerator
    extends GeneratorForAnnotation<DotEnvGen> {
  const SecureDotEnvAnnotationGenerator(this.options);

  final BuilderOptions options;

  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    if (element is! ClassElement) {
      throw Exception('@DotEnvGen annotation only supports classes');
    }

    final className = element.name;
    final constructor = element.constructors.firstWhereOrNull((e) {
      return e.isPrivate && e.isConst;
    });
    if (constructor == null) {
      throw Exception(
          '@DotEnvGen annotation requires a const $className._() or private constructor');
    }

    final filename = annotation.read('filename').stringValue;

    final fieldRenameName =
        annotation.read('fieldRename').revive().accessor.split('.')[1];
    final fieldRename =
        FieldRename.values.firstWhere((v) => v.name == fieldRenameName);

    var interface = getInterface(element);
    var library = await buildStep.inputLibrary;
    var fieldAnnotations = getAccessors(interface, library);

    final values = DotEnv()..load([filename]);
    final fields = <Field<dynamic>>[];

    // iterate through element fields, even inherited ones
    final classFields = [
      ...element.allSupertypes.expand((e) => e.element.fields).where(
          (element) =>
              !element.isStatic &&
              !element.isPrivate &&
              element.kind == ElementKind.FIELD &&
              element.name != 'hashCode' &&
              element.name != 'runtimeType'),
      ...element.fields,
    ];

    for (final field in classFields) {
      final isAbstract = field.isAbstract || field.getter?.isAbstract == true;

      final annotation =
          fieldAnnotations.firstWhereOrNull((e) => e.name == field.name);
      final parsingName = annotation?.nameOverride;
      final defaultValue = annotation?.defaultValue;

      try {
        fields.add(Field.of(
          element: field,
          rename: fieldRename,
          nameOverride: parsingName,
          defaultValue: defaultValue,
          values: values,
        ));
      } on UnsupportedError catch (e) {
        if (isAbstract) rethrow;
        logger.warning(e.message);
      }
    }

    var encryptionKey = options.config['ENCRYPTION_KEY'] as String?;
    var initializationVector = options.config['IV'] as String?;
    final outputFile = options.config['OUTPUT_FILE'] as String?;

    final isEncrypted = ((encryptionKey?.isNotEmpty ?? false) &&
            (initializationVector?.isNotEmpty ?? false)) ||
        (outputFile?.isNotEmpty ?? false);

    if (isEncrypted) {
      Uint8List key;
      Uint8List iv;

      if (encryptionKey == null || initializationVector == null) {
        key = AESCBCEncryper.generateRandomBytes(32);
        iv = AESCBCEncryper.generateRandomBytes(16);
      } else if (outputFile == null) {
        throw Exception(
          "Output file must be provided when encryptionKey and initializationVector are present.",
        );
      } else {
        key = base64.decode(encryptionKey.trim());
        iv = base64.decode(initializationVector.trim());
      }

      final List<MapEntry<String, dynamic>> entries = [];
      for (final field in fields) {
        final fieldKey = field.jsonKey;
        final value = field.parseValue();

        // encrypt value and save with key
        if (value == null || value is String && value.isEmpty) {
          entries.add(MapEntry(fieldKey, null));
          continue;
        }

        final encrypted = base64.encode(
          AESCBCEncryper.aesCbcEncrypt(key, iv, value.toString()),
        );
        entries.add(MapEntry(fieldKey, encrypted));
      }

      final jsonEncoded = jsonEncode(Map.fromEntries(entries));
      final encryptedJson = AESCBCEncryper.aesCbcEncrypt(
        key,
        iv,
        jsonEncoded,
      );
      String encryptedValues;

      encryptedValues =
          'static final Uint8List _encryptedValues = Uint8List.fromList($encryptedJson);';

      final values = fields.map((e) => e.generate()).join('\n');
      final buffer = StringBuffer();
      final tGet = """
        T _get<T>(
          String key, {
          T Function(String)? fromString,
        }) {
          T _parseValue(String strValue) {
            if (T == String) {
              return (strValue) as T;
            } else if (T == int) {
              return int.parse(strValue) as T;
            } else if (T == double) {
              return double.parse(strValue) as T;
            } else if (T == bool) {
              return (strValue.toLowerCase() == 'true') as T;
            } else if (T == Enum || fromString != null) {
              if (fromString == null) {
                throw Exception('fromString is required for Enum');
              }

              return fromString(strValue.split('.').last);
            }

            throw Exception('Type \${T.toString()} not supported');
          }

          final encryptionKey = base64.decode(_encryptionKey.trim());
          final iv = base64.decode(_iv.trim());
          final decrypted = AESCBCEncryper.aesCbcDecrypt(encryptionKey, iv, _encryptedValues);
          final jsonMap = json.decode(decrypted) as Map<String, dynamic>;
          if (!jsonMap.containsKey(key)) {
            throw Exception('Key \$key not found in .env file');
          }

          final encryptedValue = jsonMap[key] as String;
          final decryptedValue = AESCBCEncryper.aesCbcDecrypt(
            encryptionKey,
            iv,
            base64.decode(encryptedValue),
          );
          return _parseValue(decryptedValue);
        }
        """;

      buffer.writeln("""
      class _\$$className extends $className {
        const _\$$className(this._encryptionKey, this._iv) : super.${constructor.name}();

        final String _encryptionKey;
        final String _iv;
        $encryptedValues
        $values

        $tGet
      }
    """);

      if (outputFile != null) {
        final file = File(outputFile);
        final secretsMap = <String, String>{};
        secretsMap['ENCRYPTION_KEY'] = base64.encode(key);
        secretsMap['IV'] = base64.encode(iv);
        file.writeAsStringSync(jsonEncode(secretsMap));
      }

      return buffer.toString();
    } else {
      final List<MapEntry<String, dynamic>> entries = [];
      for (final field in fields) {
        final key = field.jsonKey;
        final value = field.valueAsString();

        // encrypt value and save with key
        if (value == null) {
          entries.add(MapEntry(key, null));
          continue;
        }

        final encrypted = base64.encode(value.codeUnits);
        entries.add(MapEntry(key, encrypted));
      }

      final jsonEncoded = jsonEncode(Map.fromEntries(entries));
      final encryptedJson = base64.encode(jsonEncoded.codeUnits);

      String encryptedValues;
      if (encryptedJson.contains("'")) {
        encryptedValues =
            'static const String _encryptedValues = "$encryptedJson";';
      } else {
        encryptedValues =
            "static const String _encryptedValues = '$encryptedJson';";
      }
      final values = fields.map((e) => e.generate()).join('\n');
      final buffer = StringBuffer();
      final tGet = """
  T _get<T>(
    String key, {
    T Function(String)? fromString,
  }) {
    T _parseValue(String strValue) {
      if (T == String) {
        return (strValue) as T;
      } else if (T == int) {
        return int.parse(strValue) as T;
      } else if (T == double) {
        return double.parse(strValue) as T;
      } else if (T == bool) {
        return (strValue.toLowerCase() == 'true') as T;
      } else if (T == Enum || fromString != null) {
        if (fromString == null) {
          throw Exception('fromString is required for Enum');
        }

        return fromString(strValue.split('.').last);
      }

      throw Exception('Type \${T.toString()} not supported');
    }

    final bytes = base64.decode(_encryptedValues);
    final stringDecoded = String.fromCharCodes(bytes);
    final jsonMap = json.decode(stringDecoded) as Map<String, dynamic>;
    if (!jsonMap.containsKey(key)) {
      throw Exception('Key \$key not found in .env file');
    }
    final encryptedValue = jsonMap[key] as String;
    final decryptedValue = base64.decode(encryptedValue);
    final stringValue = String.fromCharCodes(decryptedValue);
    return _parseValue(stringValue);
  }
""";
      buffer.writeln("""
      class _\$$className extends $className {
        const _\$$className() : super.${constructor.name}();

        $encryptedValues
        $values

        $tGet
      }""");

      return buffer.toString();
    }
  }
}
