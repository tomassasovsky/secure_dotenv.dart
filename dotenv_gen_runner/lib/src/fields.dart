import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_helper/source_helper.dart';

abstract class Field<T> {
  static Field of(FieldElement element, String? value) {
    final name = element.name;
    final type = element.type;

    if (type.isDartCoreString) {
      return StringField(element, value);
    } else if (type.isDartCoreInt) {
      return IntField(element, value);
    } else if (type.isDartCoreDouble) {
      return DoubleField(element, value);
    } else if (type.isDartCoreBool) {
      return BoolField(element, value);
    } else if (type.isEnum) {
      return EnumField(element, value);
    }
    throw UnsupportedError('Unsupported type for ${element.enclosingElement.name}.$name: $type');
  }

  const Field(
    this.element,
    this.envValue,
  );

  final FieldElement element;
  final String? envValue;

  String get name => element.name;
  DartType get type => element.type;
  DartObject? get defaultValue => element.computeConstantValue();

  String? get typePrefix {
    final identifier = type.element?.library?.identifier;
    if (identifier == null) return null;

    for (final e in element.library.imports) {
      if (e.importedLibrary?.identifier != identifier) continue;
      return e.prefix?.name;
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
    if (value == null && !isNullable) throw Exception('No env or default value found for: $name');

    return """
      @override
      final ${typeWithPrefix(withNullability: true)} $name = $value;
    """;
  }
}

class StringField extends Field<String> {
  const StringField(
    super.element,
    super.value,
  );

  @override
  String? parseValue() {
    return envValue ?? defaultValue?.toStringValue();
  }

  @override
  String? valueAsString() {
    final value = parseValue();
    if (value == null) return null;
    return escapeDartString(value);
  }
}

class IntField extends Field<int> {
  const IntField(
    super.element,
    super.envValue,
  );

  @override
  int? parseValue() {
    if (envValue != null) return int.parse(envValue!);
    return defaultValue?.toIntValue();
  }
}

class DoubleField extends Field<double> {
  const DoubleField(
    super.element,
    super.envValue,
  );

  @override
  double? parseValue() {
    if (envValue != null) return double.parse(envValue!);
    return defaultValue?.toDoubleValue();
  }
}

class BoolField extends Field<bool> {
  const BoolField(
    super.element,
    super.envValue,
  );

  @override
  bool? parseValue() {
    if (envValue != null) return envValue?.toLowerCase() == 'true';
    return defaultValue?.toBoolValue();
  }
}

class EnumField extends Field<String> {
  const EnumField(
    super.element,
    super.envValue,
  );

  @override
  String? parseValue() => envValue ?? defaultValue?.getField('_name')?.toStringValue();

  @override
  String? valueAsString() {
    final value = parseValue();
    if (value == null) return null;
    return '${typeWithPrefix(withNullability: false)}.$value';
  }
}
