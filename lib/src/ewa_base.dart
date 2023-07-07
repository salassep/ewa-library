import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'aes.dart';
import 'utils/gzip_compression.dart';
import 'package:path/path.dart';
import 'utils/separator.dart';
import 'eas.dart';

void encryptEmbed() async {
  final file = File('test_data/test.png');
  final fileExtension = basename(file.path).split('.')[1];
  final fileBytes = await file.readAsBytes();

  // change fileBytes from uint8list to list<int>, so it can be modified like insert extension in it.
  final List<int> fileBytesInt = List<int>.from(fileBytes);

  final fileExtensionSeparator = Separator.getSeparatorWithFileExtensionInBytes(fileExtension);

  final AesCbc aesCbc = AesCbc();

  // Insert extension and separator to file bytes
  fileBytesInt.insertAll(0, fileExtensionSeparator);

  // Compress data
  final compressedData = GzipCompression.compress(fileBytesInt);
  // Encrypt data
  final encryptedData = aesCbc.encrypt(message: compressedData, secretKey: 'sukasukasukasuka', iv: 'kamukamukamukamu');

  final List<int> convertedEncryptedData = List<int>.from(encryptedData);
  
  convertedEncryptedData.addAll(Separator.getSeparatorInBytes());

  List<String> paddedData = <String>[];
  for (var i in convertedEncryptedData) {
    paddedData.add(i.toRadixString(2).padLeft(8, '0'));
  }

  final paddedDataString = paddedData.join('');

  final Eas eas = Eas();
  final embeddedSong = await eas.embed(paddedDataString);

  File('test_data/result/stego3.wav').writeAsBytes(embeddedSong);
}

void extractDecrypt() async {
  final Eas eas = Eas();
  final AesCbc aesCbc = AesCbc();
  final extractedData = await eas.extract();

  final separatorIndex = getSeparatorIndex(extractedData, Separator.getSeparatorInBytes());

  final encryptedDataAfterExtract = Uint8List.fromList(extractedData.sublist(0, separatorIndex));

  final decryptedData = aesCbc.decrypt(cipher: encryptedDataAfterExtract, secretKey: 'sukasukasukasuka', iv: 'kamukamukamukamu');
  final decompressedData = GzipCompression.decompress(decryptedData);

  final decodedData = utf8.decode(decompressedData, allowMalformed: true);
  final fileExtensionAfterProcess = Separator.getFileExtension(decodedData);

  File('test_data/result/result3.$fileExtensionAfterProcess')
    .writeAsBytes(decompressedData.sublist(Separator.getSeparatorIndex(decodedData) + Separator.separatorWord.length));
}

int getSeparatorIndex() {
 // Return -1 if the separatorList is not found in data.
}



void main() async {
  // encryptEmbed();
  extractDecrypt();
}