import 'dart:io';
import 'dart:typed_data';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'morse_code_utils.dart';
import 'audio_generator.dart';

//import 'package:flutter_share/flutter_share.dart';
import 'package:share_plus/share_plus.dart';

class MorseCodeConverter extends StatefulWidget {
  const MorseCodeConverter({super.key});

  @override
  _MorseCodeConverterState createState() => _MorseCodeConverterState();
}

class _MorseCodeConverterState extends State<MorseCodeConverter> {
  final TextEditingController _textController = TextEditingController();
  double _frequency = 650;
  double _wpm = 25;
  final audioExt = '.wav';

  // Phase 2 additions jul26th
  List<String> _audioFiles = [];
  String _selectedAudioFile = '';

  @override
  void initState() {
    super.initState();
    _updateAudioFilesList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Morse Ringtone Genno'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(labelText: 'Enter text'),
            ),
            const SizedBox(height: 20),
            Text('Frequency: ${_frequency.round()} Hz'),
            Slider(
              value: _frequency,
              min: 400,
              max: 900,
              onChanged: (value) {
                setState(() {
                  _frequency = value;
                });
              },
            ),
            const SizedBox(height: 20),
            Text('Speed: ${_wpm.round()} WPM'),
            Slider(
              value: _wpm,
              min: 10,
              max: 40,
              onChanged: (value) {
                setState(() {
                  _wpm = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _convertToMorse();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Morse code audio generated')),
                );
              },
              child: const Text('Convert'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _selectedAudioFile.isNotEmpty ? _playAudio : null,
                  child: const Text('Play'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _selectedAudioFile.isNotEmpty ? _shareAudio : null,
                  child: const Text('Share'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 180, // Height for 3 items (adjust as needed)
              decoration: BoxDecoration(
                color: Colors.grey[200], // Light gray background
                borderRadius: BorderRadius.circular(8),
              ),
              child: Scrollbar(
                child: ListView.builder(
                  itemCount: _audioFiles.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onLongPress: () => _showContextMenu(context, index),
                      onSecondaryTap: () => _showContextMenu(context, index),
                      child: SizedBox(
                        height: 60,
                        child: ListTile(
                          title: Text(
                              File(_audioFiles[index]).uri.pathSegments.last),
                          onTap: () {
                            setState(() {
                              _selectedAudioFile = _audioFiles[index];
                            });
                          },
                          selected: _audioFiles[index] == _selectedAudioFile,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _convertToMorse() async {
    String morseCode = MorseCodeUtils.textToMorse(_textController.text);
    Uint8List audio =
        await AudioGenerator.generateMorseAudio(morseCode, _frequency, _wpm);

    final directory = await getApplicationDocumentsDirectory();
    final fileName =
        '${_textController.text.replaceAll(RegExp(r'\s+'), '').substring(0, _textController.text.replaceAll(RegExp(r'\s+'), '').length.clamp(0, 15))}_${DateTime.now().millisecondsSinceEpoch % 1000000}$audioExt';
    final path = '${directory.path}/$fileName';

    if (audioExt == '.wav') {
        await AudioGenerator.saveAsWav(path: path, data: audio);
    }
    else if (audioExt == '.mp3') {
      await saveAsMp3(path: path, data: audio);
    }
    else {
      //throw exception accordingly
      throw Exception('Unsupported audio format: $audioExt');
    }

    await _updateAudioFilesList();
  }

static Future<void> saveAsMp3({required String path, required Uint8List data}) async {
  final tempWavPath = path.replaceAll('.mp3', '_temp.wav');
  await File(tempWavPath).writeAsBytes(data);

  final command = "-i $tempWavPath -acodec libmp3lame -b:a 128k $path";
  await FFmpegKit.execute(command);

  await File(tempWavPath).delete();
}


 Future<void> _convertToMp3([String? tempWavPath]) async {
  tempWavPath = tempWavPath ?? _selectedAudioFile;
  final path = tempWavPath.replaceAll('.wav', '.mp3');
  final command = "-i $tempWavPath -acodec libmp3lame -b:a 128k $path";
  await FFmpegKit.execute(command);

  await File(tempWavPath).delete();
}



  Future<void> _updateAudioFilesList() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = Directory(directory.path)
        .listSync()
        .where((file) => file.path.endsWith(audioExt))
        .map((file) => file.path)
        .toList();
    files.sort((a, b) =>
        File(b).lastModifiedSync().compareTo(File(a).lastModifiedSync()));
    setState(() {
      _audioFiles = files;
    });
  }

  Future<void> _playAudio([String? filePath]) async {
    final pathToPlay = filePath ?? _selectedAudioFile;
    if (pathToPlay.isNotEmpty) {
      final player = AudioPlayer();
      await player.setFilePath(pathToPlay);
      await player.play();
    }
  }

  Future<void> _shareAudio([String? filePath]) async {
    filePath = filePath ?? _selectedAudioFile;

    if (filePath.isNotEmpty) {
      final xFile = XFile(filePath);
      await Share.shareXFiles([xFile],
          text: 'Check out this Morse code audio!',
          subject: 'Morse Code Audio');
    }
  }

  Future<void> _deleteAudio(String? filePath) async {
    filePath = filePath ?? _selectedAudioFile;
    final file = File(filePath);
    await file.delete();
    await _updateAudioFilesList();
  }

  void _showContextMenu(BuildContext context, int index) {

    // final RenderBox overlay =
    //     Overlay.of(context).context.findRenderObject() as RenderBox;
    // final RenderBox button = context.findRenderObject() as RenderBox;

    //       RelativeRect.fromRect(
    // Rect.fromPoints(
    //   button.localToGlobal(Offset.zero, ancestor: overlay),
    //   button.localToGlobal(button.size.bottomRight(Offset.zero),
    //       ancestor: overlay),
    // ),
    //   Offset.zero & overlay.size,
    // );

    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final size = overlay.size;
    RelativeRect position = RelativeRect.fromLTRB(
      size.width * 0.7, // 70% from the left
      size.height * 0.8, // 80% from the top
      size.width * 0.05, // 5% from the right
      size.height * 0.05, // 5% from the bottom
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected position: $position'),
        duration: const Duration(seconds: 2),
      ),
    );

    showMenu(
      context: context,
      position: position,
      items: [
        const PopupMenuItem(value: 'play', child: Text('Play')),
        const PopupMenuItem(value: 'share', child: Text('Share')),
        const PopupMenuItem(value: 'conv_mp3', child: Text('To MP3')),
        const PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    ).then((value) {
      if (value == 'play') {
        _playAudio(_audioFiles[index]);
      } else if (value == 'share') {
        _shareAudio(_audioFiles[index]);
      } else if (value == 'conv_mp3') {
        _convertToMp3(_audioFiles[index]);
      } else if (value == 'delete') {
        _deleteAudio(_audioFiles[index]);
      }
    });
  }
}
