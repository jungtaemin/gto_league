import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

/// Generates WAV sound effect files for the game.
/// Run with: dart run tools/generate_sounds.dart

void main() {
  final soundsDir = 'assets/sounds';
  
  // Generate each sound with unique characteristics
  generateWav('$soundsDir/correct.wav', _correctSound());
  generateWav('$soundsDir/wrong.wav', _wrongSound());
  generateWav('$soundsDir/snap.wav', _snapSound());
  generateWav('$soundsDir/gameOver.wav', _gameOverSound());
  generateWav('$soundsDir/timerTick.wav', _timerTickSound());
  generateWav('$soundsDir/timerWarning.wav', _timerWarningSound());
  generateWav('$soundsDir/heartbeat.wav', _heartbeatSound());
  generateWav('$soundsDir/chipStack.wav', _chipStackSound());
  generateWav('$soundsDir/slotMachine.wav', _slotMachineSound());
  generateWav('$soundsDir/levelUp.wav', _levelUpSound());
  
  print('✅ All 10 sound effects generated successfully!');
}

const int sampleRate = 44100;

/// Correct answer: ascending two-tone chime (C5 → E5)
List<int> _correctSound() {
  final samples = <int>[];
  // First tone: C5 (523 Hz) for 0.1s
  samples.addAll(_tone(523, 0.1, 0.8));
  // Second tone: E5 (659 Hz) for 0.15s
  samples.addAll(_tone(659, 0.15, 0.9));
  return samples;
}

/// Wrong answer: descending buzz (E4 → C4)
List<int> _wrongSound() {
  final samples = <int>[];
  // Buzzy descending tone
  samples.addAll(_tone(330, 0.12, 0.7, harmonics: 3));
  samples.addAll(_tone(262, 0.18, 0.6, harmonics: 3));
  return samples;
}

/// Snap bonus: bright triple ping
List<int> _snapSound() {
  final samples = <int>[];
  samples.addAll(_tone(880, 0.05, 0.9));
  samples.addAll(_tone(1100, 0.05, 0.9));
  samples.addAll(_tone(1320, 0.1, 1.0));
  return samples;
}

/// Game over: low descending tone
List<int> _gameOverSound() {
  final samples = <int>[];
  for (var i = 0; i < 3; i++) {
    samples.addAll(_tone(220 - i * 40, 0.25, 0.7 - i * 0.15, harmonics: 2));
  }
  return samples;
}

/// Timer tick: short click
List<int> _timerTickSound() {
  return _tone(1000, 0.03, 0.5);
}

/// Timer warning: urgent beep
List<int> _timerWarningSound() {
  final samples = <int>[];
  for (var i = 0; i < 3; i++) {
    samples.addAll(_tone(800, 0.08, 0.8));
    samples.addAll(_silence(0.04));
  }
  return samples;
}

/// Heartbeat: low thump
List<int> _heartbeatSound() {
  final samples = <int>[];
  samples.addAll(_tone(60, 0.1, 1.0, harmonics: 2));
  samples.addAll(_silence(0.15));
  samples.addAll(_tone(55, 0.08, 0.7, harmonics: 2));
  return samples;
}

/// Chip stack: rattling chips
List<int> _chipStackSound() {
  final rng = Random(42);
  final samples = <int>[];
  for (var i = 0; i < 5; i++) {
    final freq = 2000 + rng.nextInt(1500);
    samples.addAll(_tone(freq.toDouble(), 0.02, 0.6));
    samples.addAll(_silence(0.015));
  }
  return samples;
}

/// Slot machine: spinning reel
List<int> _slotMachineSound() {
  final samples = <int>[];
  for (var i = 0; i < 8; i++) {
    samples.addAll(_tone(600 + i * 50, 0.04, 0.5));
  }
  // Final ding
  samples.addAll(_tone(1200, 0.15, 0.9));
  return samples;
}

/// Level up: triumphant ascending arpeggio (C5 → E5 → G5 → C6)
List<int> _levelUpSound() {
  final samples = <int>[];
  samples.addAll(_tone(523, 0.1, 0.7));
  samples.addAll(_tone(659, 0.1, 0.8));
  samples.addAll(_tone(784, 0.1, 0.9));
  samples.addAll(_tone(1047, 0.2, 1.0));
  return samples;
}

/// Generate a sine wave tone with optional harmonics and fade-out envelope
List<int> _tone(double freq, double duration, double volume, {int harmonics = 1}) {
  final numSamples = (sampleRate * duration).toInt();
  final samples = <int>[];
  for (var i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final envelope = 1.0 - (i / numSamples); // Linear fade-out
    var sample = 0.0;
    for (var h = 1; h <= harmonics; h++) {
      sample += sin(2 * pi * freq * h * t) / h;
    }
    samples.add((sample * volume * envelope * 32767 * 0.5).clamp(-32767, 32767).toInt());
  }
  return samples;
}

/// Generate silence
List<int> _silence(double duration) {
  return List.filled((sampleRate * duration).toInt(), 0);
}

/// Write samples as a WAV file
void generateWav(String path, List<int> samples) {
  final file = File(path);
  final numSamples = samples.length;
  final dataSize = numSamples * 2; // 16-bit = 2 bytes per sample
  final fileSize = 36 + dataSize;
  
  final buffer = ByteData(44 + dataSize);
  var offset = 0;
  
  // RIFF header
  buffer.setUint8(offset++, 0x52); // R
  buffer.setUint8(offset++, 0x49); // I
  buffer.setUint8(offset++, 0x46); // F
  buffer.setUint8(offset++, 0x46); // F
  buffer.setUint32(offset, fileSize, Endian.little); offset += 4;
  buffer.setUint8(offset++, 0x57); // W
  buffer.setUint8(offset++, 0x41); // A
  buffer.setUint8(offset++, 0x56); // V
  buffer.setUint8(offset++, 0x45); // E
  
  // fmt subchunk
  buffer.setUint8(offset++, 0x66); // f
  buffer.setUint8(offset++, 0x6D); // m
  buffer.setUint8(offset++, 0x74); // t
  buffer.setUint8(offset++, 0x20); // (space)
  buffer.setUint32(offset, 16, Endian.little); offset += 4; // Subchunk1Size
  buffer.setUint16(offset, 1, Endian.little); offset += 2;  // PCM format
  buffer.setUint16(offset, 1, Endian.little); offset += 2;  // Mono
  buffer.setUint32(offset, sampleRate, Endian.little); offset += 4; // Sample rate
  buffer.setUint32(offset, sampleRate * 2, Endian.little); offset += 4; // Byte rate
  buffer.setUint16(offset, 2, Endian.little); offset += 2;  // Block align
  buffer.setUint16(offset, 16, Endian.little); offset += 2; // Bits per sample
  
  // data subchunk
  buffer.setUint8(offset++, 0x64); // d
  buffer.setUint8(offset++, 0x61); // a
  buffer.setUint8(offset++, 0x74); // t
  buffer.setUint8(offset++, 0x61); // a
  buffer.setUint32(offset, dataSize, Endian.little); offset += 4;
  
  // Sample data
  for (final sample in samples) {
    buffer.setInt16(offset, sample, Endian.little);
    offset += 2;
  }
  
  file.writeAsBytesSync(buffer.buffer.asUint8List());
  print('  ✓ Generated ${file.path} (${file.lengthSync()} bytes, ${(numSamples / sampleRate * 1000).toInt()}ms)');
}
