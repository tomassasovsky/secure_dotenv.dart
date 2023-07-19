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
    228,
    16,
    91,
    227,
    96,
    24,
    99,
    44,
    51,
    144,
    172,
    135,
    33,
    212,
    198,
    168,
    220,
    179,
    246,
    133,
    220,
    209,
    44,
    64,
    35,
    145,
    200,
    12,
    126,
    166,
    208,
    172,
    66,
    22,
    45,
    150,
    232,
    43,
    20,
    62,
    35,
    146,
    148,
    220,
    199,
    140,
    109,
    174,
    120,
    30,
    46,
    10,
    3,
    181,
    76,
    69,
    237,
    100,
    176,
    4,
    44,
    69,
    16,
    214,
    8,
    158,
    246,
    82,
    61,
    56,
    57,
    112,
    15,
    108,
    190,
    185,
    15,
    252,
    134,
    91,
    241,
    90,
    188,
    99,
    241,
    207,
    40,
    162,
    215,
    96,
    12,
    244,
    140,
    194,
    76,
    131,
    87,
    253,
    75,
    46,
    136,
    3,
    88,
    152,
    114,
    18,
    166,
    66,
    47,
    88,
    154,
    16,
    173,
    215,
    88,
    250,
    226,
    19,
    26,
    213,
    2,
    89,
    115,
    101,
    78,
    93,
    176,
    104,
    94,
    86,
    253,
    15,
    119,
    252,
    151,
    66,
    184,
    147,
    34,
    137,
    133,
    67,
    199,
    9,
    29,
    99,
    243,
    100,
    232,
    121,
    132,
    53,
    243,
    153,
    179,
    158,
    213,
    172,
    81,
    101,
    251,
    157,
    107,
    159,
    32,
    173,
    164,
    209,
    103,
    16,
    140,
    98,
    223,
    253,
    229,
    189,
    88,
    111,
    156,
    138,
    156,
    220,
    36,
    77,
    90,
    8,
    39,
    112,
    133,
    143,
    250,
    250
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
