import 'package:flutter/material.dart';
import 'package:tune/config/jamendo_config.dart';
import 'models/music_category.dart';
import 'models/song.dart';
import 'screens/google_login_screen.dart';
import 'services/jamendo_service.dart';

void main() {
  runApp(const TuneApp());
}

class TuneApp extends StatelessWidget {
  const TuneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tune',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const GoogleLoginScreen(),
    );
  }

  // Fetch categories with real streaming music from Jamendo API
  static Future<List<MusicCategory>> getMusicCategories() async {
    final jamendoService = JamendoService();

    try {
      // Fetch tracks for each genre from Jamendo
      final rockSongs = await jamendoService.getTracksByGenre(
        'rock',
        limit: 15,
      );
      final popSongs = await jamendoService.getTracksByGenre('pop', limit: 15);
      final jazzSongs = await jamendoService.getTracksByGenre(
        'jazz',
        limit: 15,
      );
      final classicalSongs = await jamendoService.getTracksByGenre(
        'classical',
        limit: 15,
      );
      final hiphopSongs = await jamendoService.getTracksByGenre(
        'hiphop',
        limit: 15,
      );
      final romanticSongs = await jamendoService.getTracksByGenre(
        'love',
        limit: 15,
      );

      return [
        MusicCategory(
          name: 'Rock',
          icon: '🎸',
          songs: rockSongs.isNotEmpty ? rockSongs : _getFallbackSongs('Rock'),
          trackCount: rockSongs.length,
        ),
        MusicCategory(
          name: 'Pop',
          icon: '🎤',
          songs: popSongs.isNotEmpty ? popSongs : _getFallbackSongs('Pop'),
          trackCount: popSongs.length,
        ),
        MusicCategory(
          name: 'Jazz',
          icon: '🎷',
          songs: jazzSongs.isNotEmpty ? jazzSongs : _getFallbackSongs('Jazz'),
          trackCount: jazzSongs.length,
        ),
        MusicCategory(
          name: 'Classical',
          icon: '🎻',
          songs: classicalSongs.isNotEmpty
              ? classicalSongs
              : _getFallbackSongs('Classical'),
          trackCount: classicalSongs.length,
        ),
        MusicCategory(
          name: 'Hip Hop',
          icon: '🎧',
          songs: hiphopSongs.isNotEmpty
              ? hiphopSongs
              : _getFallbackSongs('Hip Hop'),
          trackCount: hiphopSongs.length,
        ),
        MusicCategory(
          name: 'Romantic',
          icon: '💕',
          songs: romanticSongs.isNotEmpty
              ? romanticSongs
              : _getFallbackSongs('Romantic'),
          trackCount: romanticSongs.length,
        ),
      ];
    } catch (e) {
      print('Error loading categories from Jamendo: $e');
      // Return fallback data if API fails
      return _getFallbackCategories();
    }
  }

  // Fallback songs if API fails
  static List<Song> _getFallbackSongs(String genre) {
    return List.generate(
      JamendoConfig.fallbackUrls.length,
      (index) => Song(
        title: 'Sample $genre Song ${index + 1}',
        artist: 'Unknown Artist',
        assetPath: JamendoConfig.fallbackUrls[index],
        isStreamUrl: true,
        albumArt: '',
        genre: genre,
      ),
    );
  }

  static List<MusicCategory> _getFallbackCategories() {
    final fallbackSongCount = JamendoConfig.fallbackUrls.length;

    return [
      MusicCategory(
        name: 'Rock',
        icon: '🎸',
        songs: _getFallbackSongs('Rock'),
        trackCount: fallbackSongCount,
      ),
      MusicCategory(
        name: 'Pop',
        icon: '🎤',
        songs: _getFallbackSongs('Pop'),
        trackCount: fallbackSongCount,
      ),
      MusicCategory(
        name: 'Jazz',
        icon: '🎷',
        songs: _getFallbackSongs('Jazz'),
        trackCount: fallbackSongCount,
      ),
      MusicCategory(
        name: 'Classical',
        icon: '🎻',
        songs: _getFallbackSongs('Classical'),
        trackCount: fallbackSongCount,
      ),
      MusicCategory(
        name: 'Hip Hop',
        icon: '🎧',
        songs: _getFallbackSongs('Hip Hop'),
        trackCount: fallbackSongCount,
      ),
      MusicCategory(
        name: 'Romantic',
        icon: '💕',
        songs: _getFallbackSongs('Romantic'),
        trackCount: fallbackSongCount,
      ),
    ];
  }
}
