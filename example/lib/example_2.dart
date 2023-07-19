import 'package:secure_dotenv/secure_dotenv.dart';
import 'enum.dart' as e;

part 'example_2.g.dart';

@DotEnvGen(fieldRename: FieldRename.none, filename: '.env.other')
abstract class Env2 {
  const factory Env2(String encryptionKey, String iv) = _$Env2;

  const Env2._();

  String get name;

  @FieldKey(defaultValue: 1)
  int get version;

  e.Test? get test;

  @FieldKey(name: 'TEST_2', defaultValue: e.Test.a)
  e.Test get test2;

  String get blah => '2';
}
