class Song {
  final String title;
  final String assetPath; // Can be local asset or streaming URL
  final String artist;
  final bool isStreamUrl; // true if streaming from URL, false if local asset
  final String? albumArt; // Optional album art URL
  final String? genre; // Optional genre info

  Song({
    required this.title,
    required this.assetPath,
    required this.artist,
    this.isStreamUrl = false,
    this.albumArt,
    this.genre,
  });
}
