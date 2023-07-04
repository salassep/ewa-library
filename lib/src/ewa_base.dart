import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'aes.dart';
import 'gzip_compression.dart';
import 'package:path/path.dart';

void main() async {

  final file = File('test_data/test.png');
  final fileExtension = basename(file.path).split('.')[1];
  final fileBytes = await file.readAsBytes();
  final List<int> fileBytesInt = List<int>.from(fileBytes);
  final fileExtensionSeparator = getSeparator(fileExtension);
  final AesCbc aesCbc = AesCbc();

  fileBytesInt.insertAll(0, fileExtensionSeparator);
  
  final compressedData = GzipCompression.compress(fileBytesInt);
  final encryptedData = aesCbc.encrypt(message: compressedData, secretKey: 'sukasukasukasuka', iv: 'kamukamukamukamu');

  final decryptedData = aesCbc.decrypt(cipher: encryptedData, secretKey: 'sukasukasukasuka', iv: 'kamukamukamukamu');
  final decompressedData = GzipCompression.decompress(decryptedData);

  final withSeparator = utf8.decode(decompressedData, allowMalformed: true);
  // final withoutSeparator = withSeparator.substring(withSeparator.indexOf('sep') + 3);
  final fileExtensionAfterProcess = withSeparator.substring(0, withSeparator.indexOf('sep'));

  File('test_data/result/result.$fileExtensionAfterProcess').writeAsBytes(decompressedData.sublist(withSeparator.indexOf('sep') + 3));
}

List<int> getSeparator(String fileExtension) => utf8.encode('${fileExtension}sep');

// void main() async {
//   final separator = utf8.encode('sep');

//   List<int> test = [1, 2, 3, 4, 5, 3, 6, 7, 3, 8, 9, 10];

//   test.insertAll(0, separator);

//   final withSeparator = utf8.decode(test);
//   final withoutSeparator = withSeparator.substring(withSeparator.indexOf('sep') + 3);
  
//   print(utf8.encode(withoutSeparator));
// }