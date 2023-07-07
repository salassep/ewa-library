import 'dart:convert';

/// Separate the bytes that are not part of the data to be secured
class Separator {

  /// The string separator
  static final String separatorWord = 'ewaseparator';

  /// To obtain the separator index from the secured data
  static int getSeparatorIndex(List<int> bytesData) {

    final List<int> separatorList = getSeparatorInBytes();

    // Check if both lists are same
    bool areListsEqual(List list1, List list2) {

      // Check if both lists have the same length
      if(list1.length!=list2.length) {
          return false;
      }
      
      // Check if elements are equal
      for(int i=0;i<list1.length;i++) {
          if(list1[i]!=list2[i]) {
              return false;
          }
      }
      
      return true;
    }
    
    // Check if there is a separator in the list, if there is return the index
    for (var i = 0; i < bytesData.length; i++) {
      bool isEqual = areListsEqual(bytesData.sublist(i, i + separatorList.length) , separatorList);
      if (isEqual) return i;
    }

    // If both lists not same, return -1
    return -1;
  }

  /// Get the combination of the separator and the file extension in bytes
  static List<int> getSeparatorWithFileExtensionInBytes(String fileExtension) => utf8.encode('$fileExtension$separatorWord');

  /// Get the file extension by separating the separator from the byte data
  static String getFileExtension(List<int> bytesData) {
    final List<int> bytesFileExtension = bytesData.sublist(0, getSeparatorIndex(bytesData));
    final String decodedFileExtension = utf8.decode(bytesFileExtension);

    return decodedFileExtension;
  }

  /// Get separator in bytes
  static List<int> getSeparatorInBytes() => utf8.encode(separatorWord);

  /// Get the data bytes by separating them from the bytes that are not part of the data
  static List<int> separateBytesData(List<int> bytesData) => bytesData.sublist(getSeparatorIndex(bytesData) + separatorWord.length);
}
