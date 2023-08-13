EwA (EAS with AES) is a library for securing data by embedding it in an audio using a combination of EAS (Enhanced Audio Steganography) method and AES (Advanced Encryption Standard) algorithm in the Dart programming language.

## Features

- Encrypt data
- Embed data to audio
- Extract data from audio
- Decrypt data

## Getting started

To using this package, add this to pubspec.yaml

```yaml
# inside pubspec.yaml
dependencies:
  ewa:
    git:
      url: https://github.com/salassep/ewa-library.git
      ref: main
```

## Usage

```dart
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
```

## Additional information

This package uses an external package for encryption and decryption with AES-CBC.
- encrypt: https://pub.dev/packages/encrypt
