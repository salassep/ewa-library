import 'dart:io';

class GzipCompression {
  static List<int> compress(List<int> file) => gzip.encode(file);
  static List<int> decompress(List<int> compressedData) => gzip.decode(compressedData);
}
