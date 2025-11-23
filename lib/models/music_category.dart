import 'song.dart';

class MusicCategory {
  final String name;
  final String icon;
  final List<Song> songs;
  final int trackCount;

  MusicCategory({
    required this.name,
    required this.icon,
    required this.songs,
    required this.trackCount,
  });
}
