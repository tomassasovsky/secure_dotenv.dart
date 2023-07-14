🚨WARNING: YOUR SECRETS **ARE NOT** SECURE🚨

If you are using one of the following packages, your secrets are **NOT** secure:
- https://pub.dev/packages/flutter_dotenv
- https://pub.dev/packages/dotenv

# secure_dotenv

Introducing `secure_dotenv` for Flutter and Dart: Enhancing Security for Your Secrets ✨🔒

`secure_dotenv` takes the security of your sensitive data in dotenv files to the next level. Unlike other dotenv packages that may leave your secrets vulnerable, `secure_dotenv` prioritizes reliability and protection. Through advanced encryption, robust key management, and efficient secret decryption, `secure_dotenv` ensures your secrets remain confidential and inaccessible to unauthorized users. Experience enhanced security and peace of mind with `secure_dotenv` for your Flutter and Dart projects. 🛡️💼

Upgrade to `secure_dotenv` today and bid farewell to insecure and flawed dotenv packages. Our carefully crafted solution addresses vulnerabilitiesd. With `secure_dotenv`, your sensitive data remains under tight control, shielded from potential leaks and prying eyes. Embrace the gold standard of dotenv security by choosing `secure_dotenv` for your Flutter and Dart development. 🚀✨

#### Platform Support

| Android | iOS | MacOS | Web | Linux | Windows |
| :-----: | :-: | :---: | :-: | :---: | :-----: |
|   ✅   | ✅  |  ✅   | ✅  |  ✅   |  ✅  |

## Installing

To use the `secure_dotenv` package, you need to add it as a dependency in your Dart project's `pubspec.yaml` file along with the `build_runner` and `secure_dotenv_generator` packages as dev dependencies:

```yaml
dependencies:
  secure_dotenv: ^0.1.0

dev_dependencies:
  build_runner: ^2.4.5
  secure_dotenv_generator: ^0.1.0
```

Then, run the following command to fetch the packages:

```shell
$ dart pub get
```

## Usage

To generate Dart classes from a `.env` file using the `secure_dotenv` package, follow the steps below:

1. Create a Dart file in your project and import the necessary dependencies:

```dart
import 'package:secure_dotenv/secure_dotenv.dart';
import 'enum.dart' as e;

part 'example.g.dart';
```

2. Define the environment class and annotate it with `@DotEnvGen`:

```dart
@DotEnvGen(
  filename: '.env',
  fieldRename: FieldRename.screamingSnake,
)
abstract class Env {
  const factory Env(String encryptionKey) = _$Env;

  const Env._();

  // Declare your environment variables as abstract getters
  String get name;

  @FieldKey(defaultValue: 1)
  int get version;

  e.Test? get test;

  @FieldKey(name: 'TEST_2', defaultValue: e.Test.b)
  e.Test get test2;

  String get blah => '2';
}
```

3. Generate the Dart classes by running the following command in your project's root directory:

NOTE: Encryption keys must be 128, 192, or 256 bits long. If you want to encrypt sensitive values, you can run the following command:

```shell
$ dart run build_runner build --define secure_dotenv_generator:secure_dotenv=ENCRYPTION_KEY=encryption_key  --define secure_dotenv_generator:secure_dotenv=IV=your_iv
```

where `encryption_key` is the encryption key you want to use to encrypt sensitive values and `your_iv` is the initialization vector.

You can also ask secure_dotenv to generate these automatically and output them into a file:

```shell
$ dart run build_runner build --define secure_dotenv_generator:secure_dotenv=OUTPUT_FILE=encryption_key.json
```

If you don't want to encrypt sensitive values, you can run the following command instead:

```shell
$ dart run build_runner build
```

This command will generate the required Dart classes based on the `.env` file and the annotations in your code.

4. Use the generated class in your code:

```dart
void main() {
  final env = Env('encryption_key'); // Provide the encryption key
  print(env.name); // Access environment variables
  print(env.version);
  print(env.test);
  print(env.test2);
  print(env.blah);
}
```

## Annotations

### DotEnvGen

The `@DotEnvGen` annotation configures the behavior of the code generation process. It has the following parameters:

- `filename` (optional): Specifies the name of the `.env` file. Default value is `.env`.
- `fieldRename` (optional): Specifies the automatic field renaming behavior. Default value is `FieldRename.screamingSnake`.

### FieldKey

The `@FieldKey` annotation is used to specify additional information for individual environment variables. It has the following parameters:

- `name` (optional): Specifies the key name for the environment variable. If not provided, the default key name is derived from the field name based on the `fieldRename` behavior; see [FieldRename Enum](#fieldrename-enum) for more information.
- `defaultValue` (optional): Specifies a default value for the environment variable if it is not found in the `.env` file.

### FieldRename Enum

The `FieldRename` enum defines the automatic field renaming behavior. It has the following values:

- `none`: Uses the field name without changes.
- `kebab`: Encodes a field named `kebabCase` with a key `kebab-case`.
- `snake`: Encodes a field named `snakeCase` with a key `snake_case`.
- `pascal`: Encodes a field named `pascalCase` with a key `PascalCase`.
- `screamingSnake`: Encodes a field named `screamingSnakeCase` with a key `SCREAMING_SNAKE_CASE`.

## Generated Code

The `secure_dotenv` package generates the required code based on your annotations and the provided `.env` file. Below is an example of the generated code:

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'example.dart';

// **************************************************************************
// SecureDotEnvAnnotationGenerator
// **************************************************************************

class _$Env extends Env {
  const _$Env(this._encryptionKey) : super._();

  final String _encryptionKey;
  static final Uint8List _encryptedValues = Uint8List.fromList([81, 83,...]);
  @override
  String get name => _get('name');

  @override
  int get version => _get('version');

  @override
  e.Test? get test => _get(
        'test',
        fromString: e.Test.values.byName,
      );

  @override
  e.Test get test2 => _get(
        'TEST_2',
        fromString: e.Test.values.byName,
      );

  @override
  String get blah => _get('blah');

  // Code for decrypting the values and retrieving the environment variables
  T _get<T>(
    String key, {
    T Function(String)? fromString,
  }) {
    ...
  }
}
```

## Enum Support

The `secure_dotenv` package also supports decoding enum values from the encrypted `.env` file. Here is an example of an enum and how it can be decoded:

```dart
enum Test {
  a,
  b,
}
```

Make sure to import the enum file in your code:

```dart
import 'enum.dart' as e;
```

Then, you can define a getter in your environment class as follows:

```dart
e.Test get test2;
```

This setup will ensure that the encrypted value is correctly decrypted and converted to the enum type.

## Limitations

- The `secure_dotenv` package relies on the `build_runner` tool to generate the required code. Therefore, you need to run `dart run build_runner build` whenever changes are made to the environment class or the `.env` file.
- It is important to keep the encryption key secure and never commit it to version control or expose it in any way.
- The package currently supports encryption using the Advanced Encryption Standard (AES) algorithm in Cipher Block Chaining (CBC) mode. Other encryption algorithms and modes may be supported in the future.
- Because we started using pointycastle now we only support CBC for now, but we will add support for other modes in the future. If you need another mode, please open an issue.

## Conclusion

The `secure_dotenv` package simplifies the process of generating Dart classes from a `.env` file while encrypting sensitive values. By using this package, you can ensure that your environment variables are securely stored and accessed in your Dart application.

Rotate your secrets - make sure the old ones are not valid anymore. If you have any questions or feedback, please feel free to open an issue.

<br>

# Developed at [Sports Visio, Inc][sportsvisio_link]

![Sports Visio, Inc](https://github.com/tomassasovsky/secure_dotenv.dart/blob/master/logo.svg?raw=true "Sports Visio, Inc")

Maintainers
- [Tomás Sasovsky](https://github.com/tomassasovsky)
- [Nazareno Cavazzon](https://github.com/NazarenoCavazzon)
- [Tomás Tisocco](https://github.com/tomasatisocco)
- [Jorge Rincon](https://github.com/jorger5)

[sportsvisio_link]: https://sportsvisio.com/?utm_source=github&utm_medium=banner&utm_campaign=core
