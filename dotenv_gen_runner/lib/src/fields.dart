import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:dotenv/dotenv.dart';
import 'package:dotenv_gen/dotenv_gen.dart';
import 'package:source_helper/source_helper.dart';

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
    DotEnv? values,
  }) {
    assert(
      nameOverride == null || rename == FieldRename.none,
      'Cannot use both nameOverride and rename',
    );

    final key = element.name;
    final type = element.type;
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

    jsonKey = nameOverride ?? jsonKey;
    final value = values?[jsonKey];

    if (type.isDartCoreString) {
      return StringField(element, jsonKey, value);
    } else if (type.isDartCoreInt) {
      return IntField(element, jsonKey, value);
    } else if (type.isDartCoreDouble) {
      return DoubleField(element, jsonKey, value);
    } else if (type.isDartCoreBool) {
      return BoolField(element, jsonKey, value);
    } else if (type.isDartCoreEnum) {
      return EnumField(element, jsonKey, value);
    }
    throw UnsupportedError(
        'Unsupported type for ${element.enclosingElement.name}.$jsonKey: $type');
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
    return value;
  }

  @override
  String? valueAsString() {
    final value = parseValue();
    if (value == null) return null;
    return '${typeWithPrefix(withNullability: false)}.$value';
  }
}
