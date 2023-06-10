import 'package:example/enum.dart';
import 'package:example/example.dart';
import 'package:test/test.dart';

void main() {
  test('example decrypts correctly', () {
    // const encryptionKey = "GAcdM3sCXTA3In9SSXzQ1XpyyQnZnejM";
    const encryptionKey = String.fromEnvironment('ENCRYPTION_KEY');
    const env = Env(encryptionKey);

    expect(env.test2, Test.b);
    expect(env.test, Test.a);
    expect(env.blah, '2');
    expect(env.name, 'test');
    expect(env.version, 3);
  });
}
