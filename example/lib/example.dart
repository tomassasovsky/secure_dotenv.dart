import 'package:secure_dotenv/secure_dotenv.dart';
import 'enum.dart' as e;

part 'example.g.dart';

@DotEnvGen(fieldRename: FieldRename.none)
abstract class Env {
  const factory Env(String encryptionKey, String iv) = _$Env;

  const Env._();

  String get name;

  @FieldKey(defaultValue: 1)
  int get version;

  e.Test? get test;

  @FieldKey(name: 'TEST_2', defaultValue: e.Test.b)
  e.Test get test2;

  String get blah => '2';
}
