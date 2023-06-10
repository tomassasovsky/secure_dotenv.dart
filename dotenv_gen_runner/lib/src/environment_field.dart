import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/type.dart';

class EnvironmentField {
  final String name;
  final String? nameOverride;
  final DartType type;
  final DartObject? defaultValue;

  EnvironmentField(
    this.name,
    this.nameOverride,
    this.type,
    this.defaultValue,
  );
}
