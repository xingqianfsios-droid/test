import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';

/// 声音服务：生成并播放各种音效
class SoundService {
  final AudioPlayer _player = AudioPlayer();
  Uint8List? _beepBytes;
  Uint8List? _moveBytes;
  Uint8List? _captureBytes;
  Uint8List? _startBytes;

  /// 生成一个简单的正弦波 WAV 字节数据
  Uint8List _generateWav({
    int sampleRate = 44100,
    int frequency = 800,
    double durationSeconds = 0.3,
    double volume = 0.4,
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

    final amplitude = (32767 * volume).toInt();
    for (int i = 0; i < numSamples; i++) {
      double envelope = 1.0;
      final fadeLen = (sampleRate * 0.02).toInt();
      if (i < fadeLen) {
        envelope = i / fadeLen;
      } else if (i > numSamples - fadeLen) {
        envelope = (numSamples - i) / fadeLen;
      }
      final sample = (sin(2 * pi * frequency * i / sampleRate) * amplitude * envelope).toInt();
      bd.setInt16(44 + i * 2, sample.clamp(-32768, 32767), Endian.little);
    }

    return data;
  }

  /// 生成多音调合成 WAV（用于开始音效等）
  Uint8List _generateMultiToneWav({
    int sampleRate = 44100,
    required List<({int frequency, double duration})> tones,
    double volume = 0.4,
  }) {
    int totalSamples = 0;
    for (final t in tones) {
      totalSamples += (sampleRate * t.duration).toInt();
    }

    final dataSize = totalSamples * 2;
    final fileSize = 36 + dataSize;
    final data = Uint8List(44 + dataSize);
    final bd = ByteData.view(data.buffer);

    // RIFF header
    data[0] = 0x52; data[1] = 0x49; data[2] = 0x46; data[3] = 0x46;
    bd.setUint32(4, fileSize, Endian.little);
    data[8] = 0x57; data[9] = 0x41; data[10] = 0x56; data[11] = 0x45;
    data[12] = 0x66; data[13] = 0x6D; data[14] = 0x74; data[15] = 0x20;
    bd.setUint32(16, 16, Endian.little);
    bd.setUint16(20, 1, Endian.little);
    bd.setUint16(22, 1, Endian.little);
    bd.setUint32(24, sampleRate, Endian.little);
    bd.setUint32(28, sampleRate * 2, Endian.little);
    bd.setUint16(32, 2, Endian.little);
    bd.setUint16(34, 16, Endian.little);
    data[36] = 0x64; data[37] = 0x61; data[38] = 0x74; data[39] = 0x61;
    bd.setUint32(40, dataSize, Endian.little);

    final amplitude = (32767 * volume).toInt();
    int offset = 0;
    for (final t in tones) {
      final numSamples = (sampleRate * t.duration).toInt();
      final fadeLen = (sampleRate * 0.01).toInt();
      for (int i = 0; i < numSamples; i++) {
        double envelope = 1.0;
        if (i < fadeLen) {
          envelope = i / fadeLen;
        } else if (i > numSamples - fadeLen) {
          envelope = (numSamples - i) / fadeLen;
        }
        final sample = (sin(2 * pi * t.frequency * i / sampleRate) * amplitude * envelope).toInt();
        bd.setInt16(44 + (offset + i) * 2, sample.clamp(-32768, 32767), Endian.little);
      }
      offset += numSamples;
    }

    return data;
  }

  /// 播放倒计时提示音
  Future<void> playBeep() async {
    _beepBytes ??= _generateWav(frequency: 800, durationSeconds: 0.3, volume: 0.4);
    await _player.play(BytesSource(_beepBytes!));
  }

  /// 播放走子音效（短促低音）
  Future<void> playMove() async {
    _moveBytes ??= _generateWav(frequency: 600, durationSeconds: 0.12, volume: 0.3);
    await _player.play(BytesSource(_moveBytes!));
  }

  /// 播放吃子音效（较重的音）
  Future<void> playCapture() async {
    _captureBytes ??= _generateWav(frequency: 400, durationSeconds: 0.2, volume: 0.5);
    await _player.play(BytesSource(_captureBytes!));
  }

  /// 播放游戏开始音效（升调三音）
  Future<void> playStart() async {
    _startBytes ??= _generateMultiToneWav(
      tones: [
        (frequency: 523, duration: 0.15), // C5
        (frequency: 659, duration: 0.15), // E5
        (frequency: 784, duration: 0.25), // G5
      ],
      volume: 0.4,
    );
    await _player.play(BytesSource(_startBytes!));
  }

  void dispose() {
    _player.dispose();
  }
}
