// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'example_2.dart';

// **************************************************************************
// SecureDotEnvAnnotationGenerator
// **************************************************************************

class _$Env2 extends Env2 {
  const _$Env2(this._encryptionKey, this._iv) : super._();

  final String _encryptionKey;
  final String _iv;
  static final Uint8List _encryptedValues = Uint8List.fromList([
    175,
    25,
    15,
    255,
    235,
    184,
    18,
    32,
    89,
    153,
    147,
    123,
    41,
    150,
    132,
    25,
    244,
    248,
    143,
    76,
    36,
    107,
    191,
    15,
    35,
    254,
    130,
    188,
    216,
    10,
    244,
    102,
    236,
    5,
    107,
    160,
    67,
    239,
    197,
    186,
    126,
    58,
    136,
    55,
    204,
    80,
    183,
    173,
    253,
    187,
    81,
    188,
    36,
    59,
    212,
    86,
    6,
    221,
    101,
    150,
    18,
    21,
    49,
    27,
    133,
    165,
    37,
    115,
    51,
    141,
    140,
    142,
    32,
    58,
    97,
    199,
    70,
    30,
    122,
    200,
    218,
    227,
    33,
    217,
    68,
    214,
    50,
    9,
    96,
    117,
    165,
    48,
    105,
    183,
    184,
    165,
    73,
    146,
    107,
    97,
    81,
    41,
    103,
    0,
    233,
    79,
    14,
    66,
    245,
    214,
    69,
    149,
    227,
    108,
    24,
    249,
    1,
    161,
    247,
    171,
    12,
    187,
    72,
    67,
    160,
    157,
    158,
    188,
    163,
    168,
    228,
    3,
    82,
    191,
    170,
    22,
    53,
    42,
    44,
    146,
    217,
    243,
    234,
    163,
    70,
    13,
    224,
    23,
    59,
    146,
    190,
    76,
    221,
    234,
    29,
    49,
    102,
    224,
    10,
    249,
    186,
    113,
    250,
    36,
    15,
    162,
    157,
    238,
    27,
    184,
    42,
    172,
    213,
    40,
    210,
    161,
    27,
    159,
    236,
    123,
    131,
    91,
    62,
    191,
    41,
    120,
    209,
    214,
    245,
    110,
    211,
    74
  ]);
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

    final encryptionKey = base64.decode(_encryptionKey.trim());
    final iv = base64.decode(_iv.trim());
    final decrypted =
        AESCBCEncryper.aesCbcDecrypt(encryptionKey, iv, _encryptedValues);
    final jsonMap = json.decode(decrypted) as Map<String, dynamic>;
    if (!jsonMap.containsKey(key)) {
      throw Exception('Key $key not found in .env file');
    }

    final encryptedValue = jsonMap[key] as String;
    final decryptedValue = AESCBCEncryper.aesCbcDecrypt(
      encryptionKey,
      iv,
      base64.decode(encryptedValue),
    );
    return _parseValue(decryptedValue);
  }
}
