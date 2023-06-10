// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'example.dart';

// **************************************************************************
// SecureDotEnvAnnotationGenerator
// **************************************************************************

class _$Env extends Env {
  const _$Env(this._encryptionKey) : super._();

  final String _encryptionKey;
  // map entrypoint & value -> map entrypoint encrypted value -> base64
  static const String _encryptedValues =
      '2M+2zini7cxKJjb+KJ6N9s0iiLvCx3D2RRq2ZRC1nb3n+7TcfXsG0AAFKVzpVzKtAJa45Mwgcsb2gZqwd5GLklyKLz3Cljh/idTGnbSPyOFhcu8LiJVqTVwbVRWXbifuBLxtiRRZyD9F8aMS69R0OvWIr1Ja9ofPXpEKGPs+RTRLm6qjsL2T1U6Brbj2vxF/RPNa9mfblOF0BuZlTwKURiFCYOEauL42x4VXECyQ7AU=';

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

  T _get<T>(
    String key, {
    T Function(String)? fromString,
  }) {
    T _parseValue(String strValue) {
      if (T == String) {
        return (strValue) as T;
      } else if (T == int) {
        return int.parse(strValue) as T;
      } else if (T == double) {
        return double.parse(strValue) as T;
      } else if (T == bool) {
        return (strValue.toLowerCase() == 'true') as T;
      } else if (T == Enum || fromString != null) {
        if (fromString == null) {
          throw Exception('fromString is required for Enum');
        }

        return fromString(strValue.split('.').last);
      }

      throw Exception('Type ${T.toString()} not supported');
    }

    final encryptionKey = Key.fromBase64(_encryptionKey.trim());
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(
      AES(encryptionKey, mode: AESMode.cbc),
    );
    final decrypted = encrypter.decrypt64(_encryptedValues, iv: iv);
    final jsonMap = json.decode(decrypted) as Map<String, dynamic>;
    if (!jsonMap.containsKey(key)) {
      throw Exception('Key $key not found in .env file');
    }

    final encryptedValue = jsonMap[key] as String;
    final decryptedValue = encrypter.decrypt64(encryptedValue, iv: iv);
    return _parseValue(decryptedValue);
  }
}
