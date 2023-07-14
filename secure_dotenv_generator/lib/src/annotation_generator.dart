import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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
      Element element, ConstantReader annotation, BuildStep buildStep) async {
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

    final encryptionTypeName =
        annotation.read('encryptionType').revive().accessor.split('.')[1];
    final encryptionType =
        AESMode.values.firstWhere((v) => v.name == encryptionTypeName);

    final paddingName =
        annotation.read('padding').revive().accessor.split('.')[1];
    final padding =
        PaddingEncoding.values.firstWhere((v) => v.name == paddingName);

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
      CipherKey key;
      CipherIV iv;

      if (encryptionKey == null || initializationVector == null) {
        key = CipherKey.fromRandom(32);
        iv = CipherIV.fromRandom(16);
      } else if (outputFile == null) {
        throw Exception(
            "Output file must be provided when encryptionKey and initializationVector are present.");
      } else {
        key = CipherKey.fromUTF8(encryptionKey.trim());
        iv = CipherIV.fromUTF8(initializationVector.trim());
      }

      final encrypter = AES(key: key, mode: encryptionType, padding: padding);

      final List<MapEntry<String, dynamic>> entries = [];
      for (final field in fields) {
        final key = field.jsonKey;
        final value = field.parseValue();

        // encrypt value and save with key
        if (value == null || value is String && value.isEmpty) {
          entries.add(MapEntry(key, null));
          continue;
        }

        final encrypted = encrypter.encrypt(
          CryptoBytes(Uint8List.fromList(value.toString().codeUnits)),
          iv: iv,
        );
        entries.add(MapEntry(key, encrypted.base64));
      }

      final jsonEncoded = jsonEncode(Map.fromEntries(entries));
      final encryptedJson = encrypter.encrypt(
        CryptoBytes(Uint8List.fromList(jsonEncoded.codeUnits)),
        iv: iv,
      );
      final encryptedBase64 = encryptedJson.base64;

      String encryptedValues;
      if (encryptedBase64.contains("'")) {
        encryptedValues =
            'static const String _encryptedValues = "$encryptedBase64";';
      } else {
        encryptedValues =
            "static const String _encryptedValues = '$encryptedBase64';";
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

          final encryptionKey = CipherKey.fromBase64(_encryptionKey);
          final iv = CipherIV.fromBase64(_iv);
          final encrypter = AES(
            key: encryptionKey,
            mode: AESMode.$encryptionTypeName,
            padding: PaddingEncoding.$paddingName,
          );
          final decrypted = encrypter.decrypt(
            CryptoBytes.fromBase64(_encryptedValues),
            iv: iv,
          );
          final decryptedString = decrypted.toString();
          final jsonMap = json.decode(decryptedString) as Map<String, dynamic>;
          if (!jsonMap.containsKey(key)) {
            throw Exception('Key \$key not found in .env file');
          }

          final encryptedValue = jsonMap[key] as String;
          final decryptedValue = encrypter.decrypt(
            CryptoBytes.fromBase64(encryptedValue),
            iv: iv,
          );
          return _parseValue(decryptedValue.toString());
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
        secretsMap['ENCRYPTION_KEY'] = key.base64;
        secretsMap['IV'] = iv.base64;
        file.writeAsStringSync(jsonEncode(secretsMap));
      }

      final out = buffer.toString();
      logger.info('Generated encrypted values for $className');

      return out;
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
