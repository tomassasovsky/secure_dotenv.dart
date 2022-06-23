A code generation library to make enviroment variables available at compile time.

## Features

Generates a dart file with values from a `.env` file allowing you to use those enviroment
variables in your project without commiting them.
Supports and parses not just `String` but also `int`, `double`, `bool` and `enum`.

## Getting started

Add the following to your projects `pubspec.yaml`
```yaml
dependencies:
  dotenv_gen: any

dev_dependencies:
  dotenv_gen_runner: any
  build_runner: any
```

## Usage

Add a .env file at the root of the project. Syntax and rules for the file can be viewed at dotenv rules.
```
name=EnvGenTest
```

Create a dart file with your `.env` keys.
Supported variable types are:
  * String
  * int
  * double
  * bool
  * enum

```dart
import 'package:dotenv_gen/dotenv_gen.dart';

part 'example.g.dart';

@DotEnvGen()
abstract class Env {
  // factory to init the generated class
  const factory Env() = _$Env;

  // an empty constructor is required
  const Env._();

  // value is required
  String get name;

  // use default value if no value provided
  final int version = 1;

  // null if no value provided
  String? get description;

  // any functions etc will be inherited
  void func() {}
}
```

Then run the generator:
```
# dart
pub run build_runner build
# flutter
flutter pub run build_runner build
```

## Issues

Changing values in the `.env` file and re-running build_runner may not update file due to a caching