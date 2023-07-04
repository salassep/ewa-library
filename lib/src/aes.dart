import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';

class AesCbc {

  Uint8List encrypt ({
    required List<int> message,
    required String secretKey,
    required String iv
  }){
    final Key convertedSecretKey = Key.fromUtf8(secretKey);
    final IV convertedIv = IV.fromUtf8(iv);
    final Encrypter encrypter = Encrypter(AES(convertedSecretKey, mode: AESMode.cbc));
    final Encrypted encrypted = encrypter.encryptBytes(message, iv:convertedIv);

    return encrypted.bytes;
  }

  List<int> decrypt({
    required Uint8List cipher,
    required String secretKey,
    required String iv
  }){
    final Key convertedSecretKey = Key.fromUtf8(secretKey);
    final IV convertedIv = IV.fromUtf8(iv);
    final Encrypted convertedCipher = Encrypted(cipher);
    final Encrypter decrypter = Encrypter(AES(convertedSecretKey, mode: AESMode.cbc));

    try {
      final List<int> decrypted = decrypter.decryptBytes(convertedCipher, iv: convertedIv);
      return decrypted;
    } on ArgumentError {
      throw ArgumentError('Wrong secret key');
    }
  }
}
