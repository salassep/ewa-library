import 'dart:io';
import 'dart:typed_data';
import 'aes.dart';
import 'utils/gzip_compression.dart';
import 'package:path/path.dart';
import 'utils/separator.dart';
import 'eas.dart';

/// Eas with Aes
class Ewa {

  /// Get audio cover capacity in number of bits.
  Future<int> getAudioCoverCapacity(File audioCover) async {
    final Uint8List audioCoverBytes = await audioCover.readAsBytes();

    return Eas().getAudioCapacity(audioCoverBytes);
  }

  /// Check data in audio cover, if there is data then return true,
  /// otherwise return false.
  Future<bool> checkDataInAudioCover(File audioCover) async {
    final Uint8List audioCoverBytes = await audioCover.readAsBytes();
    final List<int> extractedBytes = Eas().extract(audioCoverBytes);
    final int separatorIndex = Separator.getSeparatorIndex(extractedBytes);

    return separatorIndex >= 0;
  }

  /// Get estimate size of the data to be embedded, return number of bits
  Future<int> getDataToEmbedEstimateSize({
    required File secretFile,
    required String secretKey,
    required String iv
  }) async {
    final AesCbc aesCbc = AesCbc();
    final String secretFileExtension = basename(secretFile.path).split('.').last;
    final Uint8List secretFileBytes = await secretFile.readAsBytes();

    // change fileBytes from uint8list to list<int>, so it can be modified.
    final List<int> convertedSecretFileBytes = List<int>.from(secretFileBytes);

    final List<int> fileExtensionSeparatorBytes = Separator.getSeparatorWithFileExtensionInBytes(secretFileExtension);

    // Insert extension and separator to file bytes.
    convertedSecretFileBytes.insertAll(0, fileExtensionSeparatorBytes);

    // Compress data.
    final List<int> compressedData = GzipCompression.compress(convertedSecretFileBytes);
    
    // Encrypt data.
    final Uint8List encryptedData = aesCbc.encrypt(message: compressedData, secretKey: secretKey, iv: iv);

    final List<int> convertedEncryptedData = List<int>.from(encryptedData);

    // Insert bytes separator.
    convertedEncryptedData.addAll(Separator.getSeparatorInBytes());

    // To convert data into 8 bit binary.
    List<String> paddedData = <String>[];
    for (var i in convertedEncryptedData) {
      paddedData.add(i.toRadixString(2).padLeft(8, '0'));
    }

    // Change data 8 bit binary to one string.
    final String paddedDataString = paddedData.join('');

    return paddedDataString.length;
  }

  /// Encrypt the data and then embed it into the audio cover.
  Future<List<int>> encryptEmbed({
    required File secretFile,
    required File audioCover, 
    required String secretKey,
    required String iv,
    required String targetPath,
  }) async {
    final AesCbc aesCbc = AesCbc();
    final Eas eas = Eas();
    final String secretFileExtension = basename(secretFile.path).split('.').last;
    final Uint8List secretFileBytes = await secretFile.readAsBytes();

    // Audio cover must be WAV file, because WAV provides a larger storage capacity
    // compared to other formats.
    if (basename(audioCover.path).split('.').last != 'wav') throw Exception('Audio cover must be WAV file');

    final Uint8List audioCoverBytes = await audioCover.readAsBytes();

    // change fileBytes from uint8list to list<int>, so it can be modified.
    final List<int> convertedSecretFileBytes = List<int>.from(secretFileBytes);

    final List<int> fileExtensionSeparatorBytes = Separator.getSeparatorWithFileExtensionInBytes(secretFileExtension);

    // Insert extension and separator to file bytes.
    convertedSecretFileBytes.insertAll(0, fileExtensionSeparatorBytes);

    // Compress data.
    final List<int> compressedData = GzipCompression.compress(convertedSecretFileBytes);
    
    // Encrypt data.
    final Uint8List encryptedData = aesCbc.encrypt(message: compressedData, secretKey: secretKey, iv: iv);

    final List<int> convertedEncryptedData = List<int>.from(encryptedData);

    // Insert bytes separator.
    convertedEncryptedData.addAll(Separator.getSeparatorInBytes());

    // To convert data into 8 bit binary.
    List<String> paddedData = <String>[];
    for (var i in convertedEncryptedData) {
      paddedData.add(i.toRadixString(2).padLeft(8, '0'));
    }

    // Change data 8 bit binary to one string.
    final String paddedDataString = paddedData.join('');

    // Embed data to audio cover.
    final List<int> embeddedSong = eas.embed(audioCoverBytes: audioCoverBytes , dataToHide: paddedDataString);

    // Crete file with the specified path and the name formatted as WAV.
    await File('${targetPath}stego.wav').writeAsBytes(embeddedSong);

    return embeddedSong;
  }

  /// Extract data form audio cover, and decrypt it.
  Future<List<int>> extractDecrypt({
    required File audioCover, 
    required String secretKey,
    required String iv,
    required String targetPath,
  }) async {
    final Eas eas = Eas();
    final AesCbc aesCbc = AesCbc();

    // Audio cover must be WAV file, because WAV provides a larger storage capacity
    // compared to other formats.
    if (basename(audioCover.path).split('.').last != 'wav') throw Exception('Audio cover must be wav file');

    final Uint8List audioCoverBytes = await audioCover.readAsBytes();

    // Extract data from audio cover.
    final List<int> extractedData = eas.extract(audioCoverBytes);

    final int separatorIndex = Separator.getSeparatorIndex(extractedData);

    // If data not found in audio cover, throw an error.
    if (separatorIndex < 0) throw Exception('Data not found within the audio cover');

    // Separate data bytes from the byes that are not part of the data.
    final List<int> separatedExtractData = Separator.separateBytesData(extractedData, separatorIndex);

    // Decrypt.
    final List<int> decryptedData = aesCbc.decrypt(cipher: Uint8List.fromList(separatedExtractData), secretKey: secretKey, iv: iv);

    // If there is an error in the process below, the most likely cause is an incorrect initialization vector,
    // resulting in random data from the decryption process.
    try {
      // Decompress data.
      final List<int> decompressedData = GzipCompression.decompress(decryptedData);
  
      final String fileExtensionAfterProcess = Separator.getFileExtension(decompressedData);
      
      // Crete file with the specified path and the name formatted as WAV.
      await File('${targetPath}result.$fileExtensionAfterProcess').writeAsBytes(Separator.separateBytesDataFromExtension(decompressedData));
      
      return decompressedData;

    } on Exception {
      throw Exception('Failed to get data, check the initialization vector');
    }
  }
}
