import 'package:example/enum.dart';
import 'package:example/example.dart';
import 'package:test/test.dart';

void main() {
  test('example decrypts correctly', () {
    const encryptionKey = "BctgCj9jmYmWWvPl+tzUiZ8PtakGw3yqDWX+e0SU/kI=";
    const iv = "MWDijx4YC9SM4HGGkV4jvw==";
    const env = Env(encryptionKey, iv);

    expect(env.test2, Test.b);
    expect(env.test, Test.a);
    expect(env.blah, '2');
    expect(env.name, 'test');
    expect(env.version, 3);
  });
}
