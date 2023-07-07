import 'dart:io';

/// Compression using Gzip Compression so that no data is lost
class GzipCompression {
  /// Compress data
  static List<int> compress(List<int> data) => gzip.encode(data);

  /// Decompress data
  static List<int> decompress(List<int> compressedData) => gzip.decode(compressedData);
}
