import 'package:dotenv_gen/dotenv_gen.dart';

import 'enum.dart' as e;

part 'example.g.dart';

@DotEnvGen()
abstract class Env {
  const factory Env() = _$Env;

  const Env._();

  String get name;
  final int version = 1;
  final e.Test? test = e.Test.b;
  final e.Test test2 = e.Test.b;

  String get blah => '1';

  Function get a => () => {};

  void b() {}
}
