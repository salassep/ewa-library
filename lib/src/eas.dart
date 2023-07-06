import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'separator.dart';

class Eas {
  Future<List<int>> embed(String data) async {
    final file = await File('test_data/sample5.wav').readAsBytes();

    // change fileBytes from uint8list to list<int>, so it can be modified
    final List<int> fileBytesInt = List<int>.from(file);

    List<int> embeddableBitIndex = <int>[];

    for (var i = 0; i < fileBytesInt.length; i++) {
      if (fileBytesInt[i] >= 254) {
        embeddableBitIndex.add(i);
      }
    }

    if (embeddableBitIndex.length < data.length) throw Exception('song isnt have enough room');

    // final countBit = embeddableBitIndex.length;
    // final countByte = countBit/8;
    // final countKiloByte = countByte / 1024;

    // print('kapasitas: $countBit');
    // print('kapasitas per bytes: $countByte');
    // print('kapasitar per kb: $countKiloByte');

    for (var i = 0; i < data.length; i++) {
      fileBytesInt[embeddableBitIndex[i]] = data[i] == '1' ? 255 : 254;
    }

    return fileBytesInt;
  }

  Future<List<int>> extract() async {
    final file = await File('test_data/result/stego3.wav').readAsBytes();

    // change fileBytes from uint8list to list<int>, so it can be modified~
    final List<int> fileBytesInt = List<int>.from(file);

    // Create an array consisting of 8 characters per element
    List<String> embeddableBits = <String>[];
    for (var i = 0; i < fileBytesInt.length; i++) {
      if (embeddableBits.isNotEmpty && embeddableBits[embeddableBits.length - 1].length < 8) {
        if (fileBytesInt[i] == 254) {
          embeddableBits[embeddableBits.length - 1] += '0';
        } else if (fileBytesInt[i] == 255) {
          embeddableBits[embeddableBits.length - 1] += '1';
        }
      } else {
        if (fileBytesInt[i] == 254) {
          embeddableBits.add('0');
        } else if (fileBytesInt[i] == 255) {
          embeddableBits.add('1');
        }
      }
    }

    final List<int> convertedEmbeddableBits = <int>[];
    for (var bit in embeddableBits) {
      convertedEmbeddableBits.add(int.parse(bit, radix: 2));
    }

    return convertedEmbeddableBits;  
  }
}