import 'dart:io';
import 'package:ewa/ewa.dart';

void main() async {
  final Ewa ewa = Ewa();

  // Get audio cover capacity
  final int audioCoverCapacity = await ewa.getAudioCoverCapacity(File('test_data/test5.wav'));

  // Check if data exist
  final bool isExist = await ewa.isDataExist(File('test_data/test5.wav'));

  // Get estimate size of embed data
  final int embedDataEstimateSize = await ewa.getDataToEmbedEstimateSize(    
    secretFile: File('test_data/test.pdf'), 
    secretKey: 'supersecretpassword', 
    iv: 'testtesttesttest'
  );

  // Encrypt data and embed the data to audio
  final File embeddedAudio = await ewa.encryptEmbed(
    secretFile: File('test_data/test.pdf'), 
    audioCover: File('test_data/test5.wav'), 
    secretKey: 'supersecretpassword', 
    iv: 'testtesttesttest', 
    targetPath: 'test_data/result_enem/'
  );

  // Extract data and decrypt the data
  final File extractedData = await ewa.extractDecrypt(
    audioCover: File('test_data/result_enem/stego.wav'), 
    secretKey: 'supersecretpassword', 
    iv: 'testtesttesttest', 
    targetPath: 'test_data/result_exde/'
  );

}