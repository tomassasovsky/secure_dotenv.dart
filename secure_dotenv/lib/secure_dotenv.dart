library secure_dotenv;

export 'package:crypto_x/crypto_x.dart'
    show AESMode, CipherKey, CipherIV, AES, CryptoBytes, PaddingEncoding;
export 'dart:convert' show json, base64;

import 'package:crypto_x/crypto_x.dart';

part 'field_key.dart';
part 'rename.dart';

class DotEnvGen {
  const DotEnvGen({
    this.filename = '.env',
    this.encryptionType = AESMode.cbc,
    this.padding = PaddingEncoding.pkcs7,
    this.fieldRename = FieldRename.screamingSnake,
  });

  final String filename;
  final AESMode encryptionType;
  final PaddingEncoding padding;
  final FieldRename fieldRename;
}
