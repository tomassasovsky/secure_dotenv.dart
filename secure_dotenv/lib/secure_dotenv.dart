library secure_dotenv;

export 'dart:convert' show json, base64;
export 'package:secure_dotenv/encrypter.dart';
export 'dart:typed_data' show Uint8List;

part 'field_key.dart';
part 'rename.dart';

class DotEnvGen {
  const DotEnvGen({
    this.filename = '.env',
    this.fieldRename = FieldRename.screamingSnake,
  });

  final String filename;
  final FieldRename fieldRename;
}
