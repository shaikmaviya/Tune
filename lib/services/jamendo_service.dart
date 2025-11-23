import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/song.dart';
import '../config/jamendo_config.dart';

class JamendoService {
  // Fetch tracks by genre
  Future<List<Song>> getTracksByGenre(String genre, {int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${JamendoConfig.baseUrl}/tracks?client_id=${JamendoConfig.clientId}&format=json&limit=$limit&tags=$genre&include=musicinfo&audioformat=${JamendoConfig.audioFormat}',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tracks = data['results'] as List;

        return tracks.map((track) {
          return Song(
            title: track['name'] ?? 'Unknown Title',
            artist: track['artist_name'] ?? 'Unknown Artist',
            assetPath: track['audio'] ?? '', // Direct streaming URL
            isStreamUrl: true,
            albumArt: track['album_image'] ?? track['image'] ?? '',
            genre: genre,
          );
        }).toList();
      } else {
        throw Exception('Failed to load tracks: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching Jamendo tracks: $e');
      return [];
    }
  }

  // Search tracks
  Future<List<Song>> searchTracks(String query, {int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${JamendoConfig.baseUrl}/tracks?client_id=${JamendoConfig.clientId}&format=json&limit=$limit&search=$query&audioformat=${JamendoConfig.audioFormat}',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tracks = data['results'] as List;

        return tracks.map((track) {
          return Song(
            title: track['name'] ?? 'Unknown Title',
            artist: track['artist_name'] ?? 'Unknown Artist',
            assetPath: track['audio'] ?? '',
            isStreamUrl: true,
            albumArt: track['album_image'] ?? '',
            genre: track['musicinfo']?['tags']?['genres']?.first ?? 'Unknown',
          );
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error searching tracks: $e');
      return [];
    }
  }

  // Get popular tracks
  Future<List<Song>> getPopularTracks({int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${JamendoConfig.baseUrl}/tracks?client_id=${JamendoConfig.clientId}&format=json&limit=$limit&order=popularity_total&audioformat=${JamendoConfig.audioFormat}',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tracks = data['results'] as List;

        return tracks.map((track) {
          return Song(
            title: track['name'] ?? 'Unknown Title',
            artist: track['artist_name'] ?? 'Unknown Artist',
            assetPath: track['audio'] ?? '',
            isStreamUrl: true,
            albumArt: track['album_image'] ?? '',
            genre: 'Popular',
          );
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching popular tracks: $e');
      return [];
    }
  }
}
