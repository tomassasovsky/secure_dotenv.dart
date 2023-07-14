import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import "package:pointycastle/export.dart";

class AESCBCEncryper {
  static Uint8List aesCbcEncrypt(
    Uint8List key,
    Uint8List iv,
    String text,
  ) {
    final paddedPlaintext = pad(utf8.encode(text) as Uint8List, 16);
    if (![128, 192, 256].contains(key.length * 8)) {
      throw ArgumentError.value(key, 'key', 'invalid key length for AES');
    }
    if (iv.length * 8 != 128) {
      throw ArgumentError.value(iv, 'iv', 'invalid IV length for AES');
    }
    if (paddedPlaintext.length * 8 % 128 != 0) {
      throw ArgumentError.value(
          paddedPlaintext, 'paddedPlaintext', 'invalid length for AES');
    }

    // Create a CBC block cipher with AES, and initialize with key and IV

    final cbc = BlockCipher('AES/CBC')
      ..init(true, ParametersWithIV(KeyParameter(key), iv)); // true=encrypt

    // Encrypt the plaintext block-by-block

    final cipherText = Uint8List(paddedPlaintext.length); // allocate space

    var offset = 0;
    while (offset < paddedPlaintext.length) {
      offset += cbc.processBlock(paddedPlaintext, offset, cipherText, offset);
    }
    assert(offset == paddedPlaintext.length);

    return cipherText;
  }

  static Uint8List pad(Uint8List bytes, int blockSizeBytes) {
    final padLength = blockSizeBytes - (bytes.length % blockSizeBytes);
    final padded = Uint8List(bytes.length + padLength)..setAll(0, bytes);
    Padding('PKCS7').addPadding(padded, bytes.length);
    return padded;
  }

  static Uint8List unpad(Uint8List padded) =>
      padded.sublist(0, padded.length - Padding('PKCS7').padCount(padded));

  static String aesCbcDecrypt(
    Uint8List key,
    Uint8List iv,
    Uint8List cipherText,
  ) {
    if (![128, 192, 256].contains(key.length * 8)) {
      throw ArgumentError.value(key, 'key', 'invalid key length for AES');
    }
    if (iv.length * 8 != 128) {
      throw ArgumentError.value(iv, 'iv', 'invalid IV length for AES');
    }
    if (cipherText.length * 8 % 128 != 0) {
      throw ArgumentError.value(
          cipherText, 'cipherText', 'invalid length for AES');
    }

    // Create a CBC block cipher with AES, and initialize with key and IV

    final cbc = BlockCipher('AES/CBC')
      ..init(false, ParametersWithIV(KeyParameter(key), iv)); // false=decrypt

    // Decrypt the cipherText block-by-block

    final paddedPlainText = Uint8List(cipherText.length); // allocate space

    var offset = 0;
    while (offset < cipherText.length) {
      offset += cbc.processBlock(cipherText, offset, paddedPlainText, offset);
    }
    assert(offset == cipherText.length);

    return utf8.decode(unpad(paddedPlainText));
  }

  static Uint8List generateRandomBytes(int numBytes) {
    final secureRandom = FortunaRandom();

    final seedSource = Random.secure();
    final seeds = <int>[];
    for (int i = 0; i < 32; i++) {
      seeds.add(seedSource.nextInt(256));
    }
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));

    return secureRandom.nextBytes(numBytes);
  }
}
