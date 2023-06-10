import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:secure_dotenv_generator/src/environment_field.dart';
import 'package:secure_dotenv_generator/src/fields.dart';

/// Returns a quoted String literal for [value] that can be used in generated
/// Dart code.
String escapeDartString(String value) {
  var hasSingleQuote = false;
  var hasDoubleQuote = false;
  var hasDollar = false;
  var canBeRaw = true;

  value = value.replaceAllMapped(_escapeRegExp, (match) {
    final value = match[0]!;
    if (value == "'") {
      hasSingleQuote = true;
      return value;
    } else if (value == '"') {
      hasDoubleQuote = true;
      return value;
    } else if (value == r'$') {
      hasDollar = true;
      return value;
    }

    canBeRaw = false;
    return _escapeMap[value] ?? _getHexLiteral(value);
  });

  if (!hasDollar) {
    if (hasSingleQuote) {
      if (!hasDoubleQuote) {
        return '"$value"';
      }
      // something
    } else {
      // trivial!
      return "'$value'";
    }
  }

  if (hasDollar && canBeRaw) {
    if (hasSingleQuote) {
      if (!hasDoubleQuote) {
        // quote it with single quotes!
        return 'r"$value"';
      }
    } else {
      // quote it with single quotes!
      return "r'$value'";
    }
  }

  // The only safe way to wrap the content is to escape all of the
  // problematic characters - `$`, `'`, and `"`
  final string = value.replaceAll(_dollarQuoteRegexp, r'\');
  return "'$string'";
}

extension DartTypeExtension on DartType {
  bool isAssignableTo(DartType other) {
    final me = this;

    if (me is InterfaceType) {
      final library = me.element.library;
      return library.typeSystem.isAssignableTo(this, other);
    }
    return true;
  }
}

final _dollarQuoteRegexp = RegExp(r"""(?=[$'])""");

/// A [Map] between whitespace characters & `\` and their escape sequences.
const _escapeMap = {
  '\b': r'\b', // 08 - backspace
  '\t': r'\t', // 09 - tab
  '\n': r'\n', // 0A - new line
  '\v': r'\v', // 0B - vertical tab
  '\f': r'\f', // 0C - form feed
  '\r': r'\r', // 0D - carriage return
  '\x7F': r'\x7F', // delete
  r'\': r'\\' // backslash
};

/// Given single-character string, return the hex-escaped equivalent.
String _getHexLiteral(String input) {
  final rune = input.runes.single;
  final value = rune.toRadixString(16).toUpperCase().padLeft(2, '0');
  return '\\x$value';
}

/// A [RegExp] that matches whitespace characters that should be escaped and
/// single-quote, double-quote, and `$`
final _escapeRegExp = RegExp('[\$\'"\\x00-\\x07\\x0E-\\x1F$_escapeMapRegexp]');

final _escapeMapRegexp = _escapeMap.keys.map(_getHexLiteral).join();
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
