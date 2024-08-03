import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

class AudioGenerator {
  static Future<Uint8List> generateMorseAudio(
      String morseCode, double frequency, double wpm) async {
    const sampleRate = 44100;
    final dotDuration = 1.2 / wpm;
    List<double> audio = [];

    for (int i = 0; i < morseCode.length; i++) {
      switch (morseCode[i]) {
        case '.':
          audio.addAll(_generateTone(dotDuration, frequency, sampleRate));
          break;
        case '-':
          audio.addAll(_generateTone(3 * dotDuration, frequency, sampleRate));
          break;
        case ' ':
          if (i < morseCode.length - 1 && morseCode[i + 1] == ' ') {
            audio.addAll(_generateSilence(3 * dotDuration, sampleRate));
            i++;
          } else {
            audio.addAll(_generateSilence(dotDuration, sampleRate));
          }
          break;
      }
      audio.addAll(_generateSilence(dotDuration, sampleRate));
    }

    return _convertToWav(audio, sampleRate);
  }

  static List<double> _generateTone(
      double duration, double frequency, int sampleRate) {
    int numSamples = (duration * sampleRate).round();
    return List.generate(numSamples, (i) {
      return sin(2 * pi * frequency * i / sampleRate);
    });
  }

  static List<double> _generateSilence(double duration, int sampleRate) {
    int numSamples = (duration * sampleRate).round();
    return List.filled(numSamples, 0.0);
  }

  static Uint8List _convertToWav(List<double> audio, int sampleRate) {
    final bytesBuilder = BytesBuilder();

    bytesBuilder.add(Uint8List.fromList('RIFF'.codeUnits));
    bytesBuilder.add(Uint8List(4));
    bytesBuilder.add(Uint8List.fromList('WAVE'.codeUnits));
    bytesBuilder.add(Uint8List.fromList('fmt '.codeUnits));
    bytesBuilder.add(Uint8List.fromList([16, 0, 0, 0]));
    bytesBuilder.add(Uint8List.fromList([1, 0]));
    bytesBuilder.add(Uint8List.fromList([1, 0]));
    bytesBuilder.add(Uint32List.fromList([sampleRate]).buffer.asUint8List());
    bytesBuilder
        .add(Uint32List.fromList([sampleRate * 2]).buffer.asUint8List());
    bytesBuilder.add(Uint8List.fromList([2, 0]));
    bytesBuilder.add(Uint8List.fromList([16, 0]));
    bytesBuilder.add(Uint8List.fromList('data'.codeUnits));
    bytesBuilder
        .add(Uint32List.fromList([audio.length * 2]).buffer.asUint8List());

    for (var sample in audio) {
      int intSample = (sample * 32767).round().clamp(-32768, 32767);
      bytesBuilder.add(Uint16List.fromList([intSample]).buffer.asUint8List());
    }

    final bytes = bytesBuilder.takeBytes();
    final fileSize = bytes.length - 8;
    bytes.buffer.asByteData().setUint32(4, fileSize, Endian.little);

    return bytes;
  }

  static Future<void> saveAsWav(
      {required String path, required Uint8List data}) async {
    final file = File(path);
    await file.writeAsBytes(data);
  }
}
