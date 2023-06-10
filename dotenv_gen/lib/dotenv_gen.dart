library dotenv_gen;

export 'package:encrypt/encrypt.dart' show AESMode, Key, Encrypter, IV, AES;
export 'dart:convert' show json, base64;

import 'package:encrypt/encrypt.dart';

part 'field_key.dart';
part 'rename.dart';

class DotEnvGen {
  const DotEnvGen({
    this.filename = '.env',
    this.encryptionType = AESMode.cbc,
    this.fieldRename = FieldRename.screamingSnake,
  });

  final String filename;
  final AESMode encryptionType;
  final FieldRename fieldRename;
}
