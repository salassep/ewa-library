import 'dart:convert';

class FileExtensionSeparator {

  static final String separator = 'ewa';

  static List<int> getSeparatorWithFileExtensionInBytes(String fileExtension) => utf8.encode('$fileExtension$separator');
  static String getFileExtension(String decodedData) => decodedData.substring(0, getSeparatorIndex(decodedData));
  static int getSeparatorIndex(String decodedData) => decodedData.indexOf(separator);
}
