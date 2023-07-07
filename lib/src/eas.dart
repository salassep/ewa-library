import 'dart:typed_data';

class Eas {

  /// To obtain the index of selective bytes only (254 and 255) 
  List<int> _getSelectiveBytesIndex(List bytes) {
    final List<int> selectiveByteIndex = <int>[];
    // Selective bytes are 254 and 255
    for (var i = 0; i < bytes.length; i++) {
      if (bytes[i] >= 254) {
        selectiveByteIndex.add(i);
      }
    }

    return selectiveByteIndex;
  }
  
  /// To obtain the audio capacity that will be used for the cover
  /// and return the amount of capacity in bits.
  int getAudioCapacity(Uint8List audioCoverBytes) {
    final List<int> selectiveBytesIndex = _getSelectiveBytesIndex(audioCoverBytes);

    return selectiveBytesIndex.length;    
  }

  /// Embed data to audio cover
  List<int> embed({required Uint8List audioCoverBytes, required String dataToHide}) {

    // change fileBytes from uint8list to list<int>, so it can be modified
    final List<int> convertedAudioCoverBytes = List<int>.from(audioCoverBytes);

    List<int> selectiveBytesIndex = _getSelectiveBytesIndex(convertedAudioCoverBytes);

    if (selectiveBytesIndex.length < dataToHide.length) throw Exception('Audio doesn\'t have enough capacity');

    // Replacing selective byte valkue, 
    // where if the data is 1, the selective bytes are changed to 255, 
    // and if the data is 0, the selective bytes are set to 254.
    for (var i = 0; i < dataToHide.length; i++) {
      convertedAudioCoverBytes[selectiveBytesIndex[i]] = dataToHide[i] == '1' ? 255 : 254;
    }

    return convertedAudioCoverBytes;
  }

  /// Extract data from an audio
  List<int> extract(Uint8List audioCoverBytes) {

    // Change fileBytes from uint8list to list<int>, so it can be modified~
    final List<int> convertedAudioCoverBytes = List<int>.from(audioCoverBytes);

    // Get selective bytes, and create an array from it, consisting of 8 characters per element
    List<String> selectiveBytes = <String>[];
    for (var i = 0; i < convertedAudioCoverBytes.length; i++) {
      if (selectiveBytes.isNotEmpty && selectiveBytes[selectiveBytes.length - 1].length < 8) {
        if (convertedAudioCoverBytes[i] == 254) {
          selectiveBytes[selectiveBytes.length - 1] += '0';
        } else if (convertedAudioCoverBytes[i] == 255) {
          selectiveBytes[selectiveBytes.length - 1] += '1';
        }
      } else {
        if (convertedAudioCoverBytes[i] == 254) {
          selectiveBytes.add('0');
        } else if (convertedAudioCoverBytes[i] == 255) {
          selectiveBytes.add('1');
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
