import 'dart:convert';

class Separator {

  static final String separatorWord = 'ewaseparator';

  static List<int> getSeparatorWithFileExtensionInBytes(String fileExtension) => utf8.encode('$fileExtension$separatorWord');

  static String getFileExtension(String decodedData) => decodedData.substring(0, getSeparatorIndex(decodedData));

  static int getSeparatorIndex(String decodedData) => decodedData.indexOf(separatorWord);
  
  static List<int> getSeparatorInBytes() => utf8.encode(separatorWord);
}
