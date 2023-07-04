import 'package:encrypt/encrypt.dart';

class AesCbc {

  String encrypt ({
    required String plainText,
    required String secretKey,
    required String iv
  }){
    final Key convertedSecretKey = Key.fromUtf8(secretKey);
    final IV convertedIv = IV.fromUtf8(iv);
    final Encrypter encrypter = Encrypter(AES(convertedSecretKey, mode: AESMode.cbc));
    final Encrypted encrypted = encrypter.encrypt(plainText, iv:convertedIv);

    return encrypted.base64;
  }

  String decrypt({
    required String cipherText,
    required String secretKey,
    required String iv
  }){
    final Key convertedSecretKey = Key.fromUtf8(secretKey);
    final IV convertedIv = IV.fromUtf8(iv);
    final Encrypted convertedCipherText = Encrypted.from64(cipherText);
    final Encrypter decrypter = Encrypter(AES(convertedSecretKey, mode: AESMode.cbc));

    try {
      final String decrypted = decrypter.decrypt(convertedCipherText, iv: convertedIv);
      return decrypted;
    } on ArgumentError {
      throw ArgumentError('Wrong secret key');
    }
  }
}
