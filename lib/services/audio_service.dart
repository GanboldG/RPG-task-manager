import 'package:just_audio/just_audio.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  static AudioService get instance => _instance;

  // Single player for background music
  final AudioPlayer _bgPlayer = AudioPlayer();
  
  // Separate player for sound effects (can overlap)
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _isMuted = false;
  double _volume = 0.5;

  // Initialize with settings
  Future<void> init() async {
    await _bgPlayer.setVolume(_volume);
    await _sfxPlayer.setVolume(_volume);
  }

  // Play background music (loops)
  Future<void> playBackgroundMusic(String assetPath) async {
    if (_isMuted) return;
    await _bgPlayer.setAsset(assetPath);
    await _bgPlayer.setLoopMode(LoopMode.all);
    await _bgPlayer.play();
  }

  // Play sound effect (one-shot)
  Future<void> playSfx(String assetPath) async {
    if (_isMuted) return;
    await _sfxPlayer.setAsset(assetPath);
    await _sfxPlayer.play();
  }

  // Stop background music
  Future<void> stopBackgroundMusic() async {
    await _bgPlayer.stop();
  }

  // Pause background music
  Future<void> pauseBackgroundMusic() async {
    await _bgPlayer.pause();
  }

  // Resume background music
  Future<void> resumeBackgroundMusic() async {
    if (_isMuted) return;
    await _bgPlayer.play();
  }

  // Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _bgPlayer.setVolume(_volume);
    await _sfxPlayer.setVolume(_volume);
  }

  // Mute/unmute
  Future<void> setMuted(bool muted) async {
    _isMuted = muted;
    await setVolume(muted ? 0.0 : _volume);
  }

  // Check if background music is playing
  bool get isPlaying => _bgPlayer.playing;

  // Dispose when app closes
  Future<void> dispose() async {
    await _bgPlayer.dispose();
    await _sfxPlayer.dispose();
  }
}