import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';

/// 声音服务：生成并播放提示音
class SoundService {
  final AudioPlayer _player = AudioPlayer();
  Uint8List? _beepBytes;

  /// 生成一个简单的正弦波 beep WAV 字节数据
  Uint8List _generateBeepWav({
    int sampleRate = 44100,
    int frequency = 800,
    double durationSeconds = 0.3,
  }) {
    final numSamples = (sampleRate * durationSeconds).toInt();
    final dataSize = numSamples * 2;
    final fileSize = 36 + dataSize;
    final data = Uint8List(44 + dataSize);
    final bd = ByteData.view(data.buffer);

    // RIFF header
    data[0] = 0x52; data[1] = 0x49; data[2] = 0x46; data[3] = 0x46;
    bd.setUint32(4, fileSize, Endian.little);
    // WAVE
    data[8] = 0x57; data[9] = 0x41; data[10] = 0x56; data[11] = 0x45;
    // fmt chunk
    data[12] = 0x66; data[13] = 0x6D; data[14] = 0x74; data[15] = 0x20;
    bd.setUint32(16, 16, Endian.little);
    bd.setUint16(20, 1, Endian.little);        // PCM
    bd.setUint16(22, 1, Endian.little);        // mono
    bd.setUint32(24, sampleRate, Endian.little);
    bd.setUint32(28, sampleRate * 2, Endian.little);
    bd.setUint16(32, 2, Endian.little);        // block align
    bd.setUint16(34, 16, Endian.little);       // bits per sample
    // data chunk
    data[36] = 0x64; data[37] = 0x61; data[38] = 0x74; data[39] = 0x61;
    bd.setUint32(40, dataSize, Endian.little);

    // 正弦波采样
    for (int i = 0; i < numSamples; i++) {
      // 加入淡入淡出避免爆音
      double envelope = 1.0;
      final fadeLen = (sampleRate * 0.02).toInt();
      if (i < fadeLen) {
        envelope = i / fadeLen;
      } else if (i > numSamples - fadeLen) {
        envelope = (numSamples - i) / fadeLen;
      }
      final sample = (sin(2 * pi * frequency * i / sampleRate) * 14000 * envelope).toInt();
      bd.setInt16(44 + i * 2, sample.clamp(-32768, 32767), Endian.little);
    }

    return data;
  }

  /// 播放提示音
  Future<void> playBeep() async {
    _beepBytes ??= _generateBeepWav();
    await _player.play(BytesSource(_beepBytes!));
  }

  void dispose() {
    _player.dispose();
  }
}
