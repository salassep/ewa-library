import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'aes.dart';
import 'gzip_compression.dart';
import 'package:path/path.dart';
import 'separator.dart';

void main() async {

  final file = File('test_data/test.mp3');
  final fileExtension = basename(file.path).split('.')[1];
  final fileBytes = await file.readAsBytes();

  // change fileBytes from uint8list to list<int>, so it can be modified like insert extension in it.
  final List<int> fileBytesInt = List<int>.from(fileBytes);

  final fileExtensionSeparator = FileExtensionSeparator.getSeparatorWithFileExtensionInBytes(fileExtension);

  final AesCbc aesCbc = AesCbc();

  // Insert extension and separator to file bytes
  fileBytesInt.insertAll(0, fileExtensionSeparator);
  
  final compressedData = GzipCompression.compress(fileBytesInt);
  final encryptedData = aesCbc.encrypt(message: compressedData, secretKey: 'sukasukasukasuka', iv: 'kamukamukamukamu');

  final decryptedData = aesCbc.decrypt(cipher: encryptedData, secretKey: 'sukasukasukasuka', iv: 'kamukamukamukamu');
  final decompressedData = GzipCompression.decompress(decryptedData);

  final decodedData = utf8.decode(decompressedData, allowMalformed: true);
  // final fileExtensionAfterProcess = decodedData.substring(0, decodedData.indexOf('ewa'));
  final fileExtensionAfterProcess = FileExtensionSeparator.getFileExtension(decodedData);

  File('test_data/result/result.$fileExtensionAfterProcess')
    .writeAsBytes(decompressedData.sublist(FileExtensionSeparator.getSeparatorIndex(decodedData) + FileExtensionSeparator.separator.length));
}

// void main() async {
//   final file = await File('test_data/test2.mp3').readAsBytes();

//   File('test_data/result/result2.wav').writeAsBytes(file);
// }