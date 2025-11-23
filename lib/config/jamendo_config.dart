class JamendoConfig {
  // Get your free API key from: https://devportal.jamendo.com/
  // Sign up at jamendo.com and create an application to get your client_id
  static const String clientId = 'afbe5708'; // Demo key - replace with your own

  // API Base URL
  static const String baseUrl = 'https://api.jamendo.com/v3.0';

  // Default limits
  static const int defaultLimit = 15;
  static const int maxLimit = 50;

  // Audio format
  static const String audioFormat = 'mp32'; // mp31, mp32, or mp33

  // Genre mappings for better results
  static const Map<String, String> genreTags = {
    'Rock': 'rock',
    'Pop': 'pop',
    'Jazz': 'jazz',
    'Classical': 'classical',
    'Hip Hop': 'hiphop',
    'Romantic': 'love',
    'Electronic': 'electronic',
    'Metal': 'metal',
    'Blues': 'blues',
    'Country': 'country',
  };

  // Fallback streaming URLs (SoundHelix)
  static const List<String> fallbackUrls = [
    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
  ];
}
