import 'dart:io';
import 'package:ewa/src/utils/separator.dart';

class Eas {
  
  /// To obtain the audio capacity that will be used for the cover
  /// and return the amount of capacity in bits.
  Future<int> getAudioCapacity(File file) async {
    int i = 0;

    await for (var chunk in file.openRead()) {
      for (var byte in chunk) {
        if (byte >= 254) {
          i++;
        }
      }
    }

    return i;    
  }

  Future<bool> isDataExist(File audioStego) async {
    List<String> selectiveByte = <String>[];
    String separator = Separator.getSeparatorInEightBitBinary().join();

    await for (var chunk in audioStego.openRead()) {
      for (var byte in chunk) {
        if (selectiveByte.length == separator.length) {;
          if (selectiveByte.join('') == separator) {
            return true;
          } else {
            return false;
          }
        }
        if (byte >= 254) {
          selectiveByte.add(byte == 254 ? '0' : '1');
        }
      }
    }

    return false;
  }

  /// Embed data to audio cover
  Future<File> embed({required File audioCover, required String dataToHide}) async {

    if (await getAudioCapacity(audioCover) < dataToHide.length) {
      throw Exception('Audio doesn\'t have enough capacity');
    }

    // Replacing selective byte valkue, 
    // where if the data is 1, the selective bytes are changed to 255, 
    // and if the data is 0, the selective bytes are set to 254.
    int dataToHideIndex = 0;

    final outputFile = File('stego.wav');
    var outputSink = outputFile.openWrite();

    await for (var chunk in audioCover.openRead()) {
      for (var i=0; i < chunk.length; i++) {
        if (chunk[i] >= 254) {
          if (dataToHideIndex < dataToHide.length) {
            chunk[i] = dataToHide[dataToHideIndex] == '1' ? 255 : 254;
            dataToHideIndex++;
          }
        }
      }

      outputSink.add(chunk);
    }

    await outputSink.flush();
    await outputSink.close();

    return outputFile;
  }

  /// Extract data from an audio
  Future<List<int>> extract(File audioCover) async {

    if (!await isDataExist(audioCover)) {
      throw Exception('Data not found within the audio cover');
    }

    // Get selective bytes, and create an array from it, consisting of 8 characters per element
    List<String> selectiveBytes = <String>[];
    String separatorBytes = Separator.getSeparatorInEightBitBinary().join('');
    bool separatorBytesFound = false;

    await for (var chunk in audioCover.openRead()){

      if (separatorBytesFound){
        break;
      }

      for (var i = 0; i < chunk.length; i++) {

        if (chunk[i] < 254) {
          continue;
        }

        if (selectiveBytes.isNotEmpty && selectiveBytes[selectiveBytes.length - 1].length < 8) {
          if (chunk[i] == 254) {
            selectiveBytes[selectiveBytes.length - 1] += '0';
          } else {
            selectiveBytes[selectiveBytes.length - 1] += '1';
          }
        } else {
          if (selectiveBytes.join('').contains(separatorBytes)){
            if (selectiveBytes.join('').length != separatorBytes.length) {
              separatorBytesFound = true;
              break;
            }
            selectiveBytes.clear();
          }

          selectiveBytes.add(chunk[i] == 254 ? '0' : '1');
        }
      }
    }

    // Convert the selective bytes, which was previously an 8 bit binary string into decimal
    final List<int> convertedSelectiveBytes = <int>[];
    for (var bit in selectiveBytes) {
      convertedSelectiveBytes.add(int.parse(bit, radix: 2));
    }

    return convertedSelectiveBytes;  
  }
}
