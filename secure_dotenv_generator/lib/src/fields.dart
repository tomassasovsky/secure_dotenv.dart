import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:dotenv/dotenv.dart';
import 'package:secure_dotenv/secure_dotenv.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_helper/source_helper.dart';

final _fieldKeyChecker = const TypeChecker.fromRuntime(FieldKey);

abstract class Field<T> {
  const Field(
    this._element,
    this.jsonKey,
    this.value,
  );

  static Field<dynamic> of({
    required FieldElement element,
    required FieldRename rename,
    required String? nameOverride,
    DartObject? defaultValue,
    DotEnv? values,
  }) {
    assert(
      nameOverride == null || rename == FieldRename.none,
      'Cannot use both nameOverride and rename',
    );

    final type = element.type;
    final jsonKey = getElementJsonKey(element, rename, nameOverride);
    final value = values?[jsonKey] ?? defaultValue?.toStringValue();

    if (type.isDartCoreString) {
      return StringField(element, jsonKey, value);
    } else if (type.isDartCoreInt) {
      return IntField(element, jsonKey, value);
    } else if (type.isDartCoreDouble) {
      return DoubleField(element, jsonKey, value);
    } else if (type.isDartCoreBool) {
      return BoolField(element, jsonKey, value);
    } else if (type.isEnum) {
      final name = defaultValue?.getField('_name')?.toStringValue();
      return EnumField(element, jsonKey, value ?? name);
    }

    throw UnsupportedError(
        'Unsupported type for ${element.enclosingElement.name}.$jsonKey: $type');
  }

  static String getElementJsonKey(
    FieldElement element,
    FieldRename rename,
    String? nameOverride,
  ) {
    final key = element.name;
    String jsonKey;

    switch (rename) {
      case FieldRename.none:
        jsonKey = key;
        break;
      case FieldRename.pascal:
        jsonKey = key.pascal;
        break;
      case FieldRename.snake:
        jsonKey = key.snake;
        break;
      case FieldRename.kebab:
        jsonKey = key.kebab;
        break;
      case FieldRename.screamingSnake:
        jsonKey = key.snake.toUpperCase();
        break;
    }

    return nameOverride ?? jsonKey;
  }

  final FieldElement _element;
  final String jsonKey;
  final String? value;

  DartType get type => _element.type;

  String? get typePrefix {
    final identifier = type.element?.library?.identifier;
    if (identifier == null) return null;

    for (final e in _element.library.libraryImports) {
      if (e.importedLibrary?.identifier != identifier) continue;
      return e.prefix?.element.name;
    }
    return null;
  }

  String typeWithPrefix({required bool withNullability}) {
    final typePrefix = this.typePrefix;
    final type = this.type.getDisplayString(withNullability: withNullability);
    return '${typePrefix != null ? '$typePrefix.' : ''}$type';
  }

  bool get isNullable => type.nullabilitySuffix != NullabilitySuffix.none;

  T? parseValue();

  String? valueAsString() => parseValue()?.toString();

  String generate() {
    final value = valueAsString();
    if (value == null && !isNullable) {
      throw Exception('No environment variable found for: $jsonKey');
    }

    return """
      @override
      ${typeWithPrefix(withNullability: true)} get ${_element.name} => _get('$jsonKey');
    """;
  }

  MapEntry<String, String> generateMapEntry() {
    final value = valueAsString();
    if (value == null && !isNullable) {
      throw Exception('No environment variable found for: $jsonKey');
    }

    return MapEntry(jsonKey, value!);
  }
}

class StringField extends Field<String> {
  const StringField(
    super.element,
    super.name,
    super.value,
  );

  @override
  String? parseValue() => value;

  @override
  String? valueAsString() {
    return parseValue();
  }
}

class IntField extends Field<int> {
  const IntField(
    super.element,
    super.name,
    super.value,
  );

  @override
  int? parseValue() {
    if (value == null) return null;
    return int.parse(value!);
  }
}

class DoubleField extends Field<double> {
  const DoubleField(
    super.element,
    super.name,
    super.value,
  );

  @override
  double? parseValue() {
    if (value == null) return null;
    return double.parse(value!);
  }
}

class BoolField extends Field<bool> {
  const BoolField(
    super.element,
    super.name,
    super.value,
  );

  @override
  bool? parseValue() {
    switch (value?.toLowerCase()) {
      case null:
        return null;
      case 'true':
      case '1':
      case 'yes':
        return true;
      case 'false':
      case '0':
      case 'no':
      case '':
        return false;
      default:
        throw Exception('Invalid boolean value: $value');
    }
  }
}

class EnumField extends Field<String> {
  const EnumField(
    super.element,
    super.name,
    super.value,
  );

  @override
  String? parseValue() {
    if (value == null) return null;

    final values = (type as InterfaceType)
        .accessors
        .where((e) => e.returnType.isAssignableTo(type))
        .map((e) => e.name);
    if (!values.contains(value)) {
      throw Exception('Invalid enum value for $type: $value');
    }

    return values.firstWhere((e) => e == value!.split('.').last);
  }

  @override
  String generate() {
    final value = parseValue();
    if (value == null && !isNullable) {
      throw Exception('No environment variable found for: $jsonKey');
    }

    return """
      @override
      ${typeWithPrefix(withNullability: true)} get ${_element.name} => _get(
        '$jsonKey',
        fromString: ${typeWithPrefix(withNullability: false)}.values.byName,
      );
    """;
  }

  @override
  String? valueAsString() {
    final value = parseValue();
    if (value == null) return null;
    return '${typeWithPrefix(withNullability: false)}.$value';
  }
}

class FieldInfo {
  FieldInfo(
    this.name,
    this.defaultValue,
  );

  final String? name;
  final DartObject? defaultValue;
}

FieldInfo? getFieldAnnotation(Element element) {
  var obj = _fieldKeyChecker.firstAnnotationOfExact(element);
  if (obj == null) return null;

  return FieldInfo(
    obj.getField('name')?.toStringValue(),
    obj.getField('defaultValue'),
  );
}
