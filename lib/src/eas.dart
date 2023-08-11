import 'dart:io';
import 'package:ewa/src/utils/separator.dart';

class Eas {
  
  /// To obtain the audio capacity that will be used for the cover
  /// and return the amount of capacity in bits.
  Future<int> getAudioCapacity(File file) async {
    int i = 0;

    await for (var chunk in file.openRead()) {
      for (var byte in chunk) {
        if (byte >= 0) {
          i++;
        }
      }
    }

    return i;    
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

    // Get selective bytes, and create an array from it, consisting of 8 characters per element
    List<String> selectiveBytes = <String>[];
    List<int> separatorBytes = Separator.getSeparatorInBytes();
    List<int> separatorBytesFind = [];

    await for (var chunk in audioCover.openRead()){
      if (separatorBytesFind.length == separatorBytes.length) {
        break;
      }
      for (var i = 0; i < chunk.length; i++) {

        if (separatorBytes.contains(chunk[i])) {
          separatorBytesFind.add(chunk[i]);
        } else {
          separatorBytesFind.clear();
        }

        if (separatorBytesFind.length == separatorBytes.length) {
          break;
        }

        if (selectiveBytes.isNotEmpty && selectiveBytes[selectiveBytes.length - 1].length < 8) {
          if (chunk[i] == 254) {
            selectiveBytes[selectiveBytes.length - 1] += '0';
          } else if (chunk[i] == 255) {
            selectiveBytes[selectiveBytes.length - 1] += '1';
          }
        } else {
          if (chunk[i] == 254) {
            selectiveBytes.add('0');
          } else if (chunk[i] == 255) {
            selectiveBytes.add('1');
          }
        }
      }
    }

    print(selectiveBytes);

    // Convert the selective bytes, which was previously an 8 bit binary string into decimal
    final List<int> convertedSelectiveBytes = <int>[];
    for (var bit in selectiveBytes) {
      convertedSelectiveBytes.add(int.parse(bit, radix: 2));
    }

    return convertedSelectiveBytes;  
  }
}
