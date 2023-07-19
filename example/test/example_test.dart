import 'dart:convert';
import 'dart:io';

import 'package:example/enum.dart';
import 'package:example/example.dart';
import 'package:example/example_2.dart';
import 'package:test/test.dart';

void main() {
  test('example decrypts correctly', () {
    final jsonFile = File('encryption_key.json');
    final json = jsonFile.readAsStringSync();
    final secretsMap = jsonDecode(json) as Map<String, dynamic>;
    final encryptionKey = secretsMap['ENCRYPTION_KEY'] as String;
    final iv = secretsMap['IV'] as String;
    final env = Env(encryptionKey, iv);
    final env2 = Env2(encryptionKey, iv);

    expect(env.test2, Test.b);
    expect(env.test, Test.a);
    expect(env.blah, '2');
    expect(env.name, 'test');
    expect(env.version, 3);

    expect(env2.test, Test.b);
    expect(env2.test2, Test.a);
    expect(env2.blah, '5');
    expect(env2.name, 'Actual Name');
    expect(env2.version, 15);
  });
}
