import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';

class AesCbc {

  /// Encrypt data using AES CBC
  Uint8List encrypt ({
    required List<int> message,
    required String secretKey,
    required String iv
  }){
    final Key convertedSecretKey = Key.fromUtf8(_validateSecretKey(secretKey));
    final IV convertedIv = IV.fromUtf8(_validateIv(iv));
    final Encrypter encrypter = Encrypter(AES(convertedSecretKey, mode: AESMode.cbc));
    final Encrypted encrypted = encrypter.encryptBytes(message, iv:convertedIv);

    return encrypted.bytes;
  }

  /// Decrypt data using AES CBC
  List<int> decrypt({
    required Uint8List cipher,
    required String secretKey,
    required String iv
  }){
    final Key convertedSecretKey = Key.fromUtf8(_validateSecretKey(secretKey));
    final IV convertedIv = IV.fromUtf8(_validateIv(iv));
    final Encrypted convertedCipher = Encrypted(cipher);
    final Encrypter decrypter = Encrypter(AES(convertedSecretKey, mode: AESMode.cbc));

    // Throwing error when secret key wrong
    try {
      final List<int> decrypted = decrypter.decryptBytes(convertedCipher, iv: convertedIv);
      return decrypted;
    } on ArgumentError {
      throw ArgumentError('Wrong secret key');
    }
  }

  /// Validate the secret key, if it does not meet the specified character count (16, 24, or 32),
  /// padding will be added (using pkcs7).
  String _validateSecretKey(String secretKey) {

    if (secretKey.length == 16 || secretKey.length == 24 || secretKey.length == 32) return secretKey;

    int padCount;

    final int secretKeyLength = secretKey.length;

    if (secretKeyLength < 16) {
      padCount = 16;
    } else if (secretKeyLength < 24) {
      padCount = 24;
    } else {
      padCount = 32;
    }

    return secretKey.padRight(padCount, '${padCount - secretKeyLength}');
  }

  /// Validate the initialization vector, if the character count is less than 16,
  /// padding will be added (using pkcs7).
  String _validateIv(String iv) => iv.length == 16 ? iv : iv.padRight(16, '${16 - iv.length}');
}
