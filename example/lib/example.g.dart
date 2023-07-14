// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'example.dart';

// **************************************************************************
// SecureDotEnvAnnotationGenerator
// **************************************************************************

class _$Env extends Env {
  const _$Env(this._encryptionKey, this._iv) : super._();

  final String _encryptionKey;
  final String _iv;
  static const String _encryptedValues =
      '0om2vfezPjXNpZQdG9WAf/4enlnm+ksn6bYe0lHZbtZLnrEOrK9EcBcTcGQvheCDR4oLzFkpKysbdJNRsPkayeahqXa8rkvn1jYhbFvIrMCEXhqglNUaZyDmbgSeqPvtJHmkvO4/Ayc6gvWaM/EmfcBwqTBGWOSGMA4PWGivyS/FB8KufCah9ldAamSlmRaa2zDu/Q2jI1G/WH4n5qqvE1WWWI7xCZWdoR/KPv0JtwGnzL5N1OcXzdvhsboY960z';
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

    final encryptionKey = Key.fromBase64(_encryptionKey);
    final iv = IV.fromBase64(_iv);
    final encrypter = Encrypter(AES(encryptionKey, mode: AESMode.cbc));
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
