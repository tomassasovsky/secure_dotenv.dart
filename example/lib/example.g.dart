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
      '49qGqrfRB5DsyT7jA5lobtH4DP5ZFYGs6RSPIt83tmslaFIQRG3qEQHaoyarrNzjpiVSbwY04zG+BH8FzwroZjisVPsWHFMrxpbeKlpekuz10/VeCmBkNHBoq2TJp+CMfouyd/B3PzaVhM4p5cMV9Uq2sEUgnMMtwsnFqaN8M+2IjfUJ1mMwhb99vFl1IxrmahackvCgfAQvHAMpjjBxbIZybjPtTrk9ifhhZQ2+GTr8Jc7dvS5LuQcRrfuEvtb3';
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

    final encryptionKey = CipherKey.fromBase64(_encryptionKey);
    final iv = CipherIV.fromBase64(_iv);
    final encrypter = AES(
      key: encryptionKey,
      mode: AESMode.cbc,
      padding: PaddingEncoding.pkcs7,
    );
    final decrypted = encrypter.decrypt(
      CryptoBytes.fromBase64(_encryptedValues),
      iv: iv,
    );
    final decryptedString = decrypted.toString();
    final jsonMap = json.decode(decryptedString) as Map<String, dynamic>;
    if (!jsonMap.containsKey(key)) {
      throw Exception('Key $key not found in .env file');
    }

    final encryptedValue = jsonMap[key] as String;
    final decryptedValue = encrypter.decrypt(
      CryptoBytes.fromBase64(encryptedValue),
      iv: iv,
    );
    return _parseValue(decryptedValue.toString());
  }
}
