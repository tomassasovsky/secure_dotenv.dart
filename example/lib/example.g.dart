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
  static final Uint8List _encryptedValues = Uint8List.fromList([
    81,
    83,
    122,
    129,
    153,
    8,
    185,
    154,
    190,
    125,
    43,
    23,
    8,
    238,
    86,
    52,
    103,
    243,
    23,
    80,
    229,
    160,
    192,
    202,
    97,
    81,
    62,
    69,
    82,
    171,
    198,
    202,
    153,
    152,
    254,
    157,
    49,
    42,
    56,
    141,
    178,
    81,
    67,
    67,
    123,
    24,
    209,
    61,
    73,
    142,
    243,
    146,
    10,
    34,
    76,
    113,
    151,
    89,
    196,
    6,
    49,
    138,
    243,
    229,
    146,
    56,
    38,
    46,
    182,
    189,
    15,
    182,
    178,
    91,
    12,
    92,
    228,
    66,
    247,
    88,
    152,
    114,
    241,
    142,
    121,
    31,
    102,
    233,
    25,
    186,
    242,
    162,
    191,
    172,
    238,
    120,
    181,
    227,
    27,
    225,
    173,
    146,
    20,
    216,
    251,
    118,
    65,
    167,
    177,
    214,
    120,
    178,
    69,
    98,
    64,
    160,
    60,
    152,
    174,
    8,
    191,
    33,
    50,
    112,
    44,
    214,
    136,
    72,
    58,
    214,
    203,
    101,
    181,
    221,
    150,
    201,
    137,
    113,
    92,
    53,
    174,
    217,
    47,
    80,
    122,
    132,
    176,
    214,
    116,
    150,
    160,
    131,
    43,
    24,
    124,
    26,
    255,
    218,
    106,
    59,
    79,
    122,
    174,
    150,
    99,
    135,
    92,
    10,
    184,
    149,
    111,
    142,
    92,
    58,
    201,
    169,
    28,
    218,
    127,
    165,
    150,
    164,
    253,
    160,
    45,
    134,
    216,
    14,
    234,
    222,
    226,
    30
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
