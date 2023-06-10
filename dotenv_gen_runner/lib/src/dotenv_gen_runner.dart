import 'dart:async';
import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:dotenv/dotenv.dart';
import 'package:dotenv_gen/dotenv_gen.dart';
import 'package:dotenv_gen_runner/src/helpers.dart';
import 'package:logging/logging.dart';
import 'package:source_gen/source_gen.dart';

import 'environment_field.dart';
import 'fields.dart';

class DotEnvGenAnnotationGenerator extends GeneratorForAnnotation<DotEnvGen> {
  final logger = Logger('dotenv_gen_runner:dotenv_gen');

  DotEnvGenAnnotationGenerator(this.options);

  final BuilderOptions options;

  @override
  FutureOr<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    if (element is! ClassElement) {
      throw Exception('@DotEnvGen annotation only supports classes');
    }

    final filename = annotation.read('filename').stringValue;
    final encryptionTypeName =
        annotation.read('encryptionType').revive().accessor.split('.')[1];
    final encryptionType =
        AESMode.values.firstWhere((v) => v.name == encryptionTypeName);

    final fieldRenameName =
        annotation.read('fieldRename').revive().accessor.split('.')[1];
    final fieldRename =
        FieldRename.values.firstWhere((v) => v.name == fieldRenameName);

    final className = element.name;
    final constructor = element.constructors.firstWhereOrNull((e) {
      return e.isPrivate && e.isConst;
    });
    if (constructor == null) {
      throw Exception(
          '@DotEnvGen annotation requires a const $className._() or private constructor');
    }

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

      final fieldAnnotation =
          fieldAnnotations.firstWhereOrNull((e) => e.name == field.name);
      final parsingName = fieldAnnotation?.nameOverride;

      try {
        fields.add(Field.of(
          element: field,
          rename: fieldRename,
          nameOverride: parsingName,
          values: values,
        ));
      } on UnsupportedError catch (e) {
        if (isAbstract) rethrow;
        logger.warning(e.message);
      }
    }

    final encryptionKey = options.config['ENCRYPTION_KEY'] as String?;
    final isEncrypted = encryptionKey?.isNotEmpty ?? false;

    if (isEncrypted) {
      final key = Key.fromBase64(encryptionKey!.trim());
      final iv = IV.fromLength(16);
      final encrypter = Encrypter(AES(key, mode: encryptionType));

      final List<MapEntry<String, dynamic>> entries = [];
      for (final field in fields) {
        final key = field.jsonKey;
        final value = field.valueAsString();

        // encrypt value and save with key
        if (value == null) {
          entries.add(MapEntry(key, null));
          continue;
        }

        final encrypted = encrypter.encrypt(value, iv: iv);
        entries.add(MapEntry(key, encrypted.base64));
      }

      final jsonEncoded = jsonEncode(Map.fromEntries(entries));
      final encryptedJson = encrypter.encrypt(jsonEncoded, iv: iv);
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

      buffer.writeln("""
      class _\$$className extends $className {
        const _\$$className(this._encryptionKey) : super.${constructor.name}();

        final String? _encryptionKey;
        $encryptedValues

        String _get(String key) {
          final isEncrypted = _encryptionKey != null && _encryptionKey!.isNotEmpty;
          if (isEncrypted) {
            final encryptionKey = Key.fromBase64(_encryptionKey!.trim());
            final iv = IV.fromLength(16);
            final encrypter = Encrypter(
              AES(encryptionKey, mode: AESMode.cbc),
            );
            final decrypted = encrypter.decrypt64(_encryptedValues, iv: iv);
            final jsonMap = json.decode(decrypted) as Map<String, dynamic>;
            if (!jsonMap.containsKey(key)) {
              throw Exception('Key \$key not found in .env file');
            }

            final encryptedValue = jsonMap[key] as String;
            final decryptedValue = encrypter.decrypt64(encryptedValue, iv: iv);
            return decryptedValue;
          }

          final bytes = base64.decode(_encryptedValues);
          final jsonMap = json.decode(String.fromCharCodes(bytes)) as Map<String, dynamic>;
          if (!jsonMap.containsKey(key)) {
            throw Exception('Key \$key not found in .env file');
          }
          return jsonMap[key] as String;
        }

        ${values}
      }
    """);

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

      buffer.writeln("""
      class _\$$className extends $className {
        const _\$$className() : super.${constructor.name}();

        $encryptedValues

        String _get(String key) {
          final bytes = base64.decode(_encryptedValues);
          final stringDecoded = String.fromCharCodes(bytes);
          final jsonMap = json.decode(stringDecoded) as Map<String, dynamic>;
          if (!jsonMap.containsKey(key)) {
            throw Exception('Key \$key not found in .env file');
          }
          final encryptedValue = jsonMap[key] as String;
          final decryptedValue = base64.decode(encryptedValue);
          return String.fromCharCodes(decryptedValue);
        }

        ${values}
      }
    """);

      return buffer.toString();
    }
  }

  InterfaceElement getInterface(Element element) {
    assert(
      element.kind == ElementKind.CLASS || element.kind == ElementKind.ENUM,
      'Only classes or enums are allowed to be annotated with @HiveType.',
    );

    return element as InterfaceElement;
  }

  Set<String> getAllAccessorNames(InterfaceElement interface) {
    var accessorNames = <String>{};

    var supertypes = interface.allSupertypes.map((it) => it.element);
    for (var type in [interface, ...supertypes]) {
      for (var accessor in type.accessors) {
        if (accessor.isSetter) {
          var name = accessor.name;
          accessorNames.add(name.substring(0, name.length - 1));
        } else {
          accessorNames.add(accessor.name);
        }
      }
    }

    return accessorNames;
  }

  List<EnvironmentField> getAccessors(
      InterfaceElement interface, LibraryElement library) {
    var accessorNames = getAllAccessorNames(interface);

    var getters = <EnvironmentField>[];
    var setters = <EnvironmentField>[];
    for (var name in accessorNames) {
      var getter = interface.lookUpGetter(name, library);
      if (getter != null) {
        var getterAnn =
            getFieldAnnotation(getter.variable) ?? getFieldAnnotation(getter);
        if (getterAnn != null) {
          var field = getter.variable;
          getters.add(EnvironmentField(
            field.name,
            getterAnn.name,
            field.type,
            getterAnn.defaultValue,
          ));
        }
      }

      var setter = interface.lookUpSetter('$name=', library);
      if (setter != null) {
        var setterAnn =
            getFieldAnnotation(setter.variable) ?? getFieldAnnotation(setter);
        if (setterAnn != null) {
          var field = setter.variable;
          setters.add(EnvironmentField(
            field.name,
            setterAnn.name,
            field.type,
            setterAnn.defaultValue,
          ));
        }
      }
    }

    return [...getters, ...setters];
  }
}
