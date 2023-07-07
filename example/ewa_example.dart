import 'dart:io';
import 'package:ewa/ewa.dart';

void main() async {
  final Ewa ewa = Ewa();

  // Encrypt data and embed the data to audio
  final List<int> embeddedAudio = await ewa.encryptEmbed(
    secretFile: File('test_data/test.txt'), 
    audioCover: File('test_data/sample4.wav'), 
    secretKey: 'supersecretpassword', 
    iv: 'testtesttesttest', 
    targetPath: 'test_data/result_enem/'
  );

  // Extract data and decrypt the data
  final List<int> extractedData = await ewa.extractDecrypt(
    audioCover: File('test_data/result_enem/stego.wav'), 
    secretKey: 'supersecretpassword', 
    iv: 'testtesttesttest', 
    targetPath: 'test_data/result_exde/'
  );
}