import 'package:dotenv_gen/dotenv_gen.dart';

import 'enum.dart' as e;

part 'example.g.dart';

@DotEnvGen()
abstract class Env {
  const factory Env() = _$Env;

  const Env._();

  String get name;
  final int version = 1;
  e.Test? get test => e.Test.b;
  e.Test? get test2;

  String get blah => '1';

  Function get a => () => {};

  void b() {}
}
