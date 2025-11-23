import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/music_category.dart';
import '../services/auth_service.dart';
import 'profile_screen.dart';

class MusicPlayerScreen extends StatefulWidget {
  final MusicCategory category;

  const MusicPlayerScreen({super.key, required this.category});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  final AuthService _authService = AuthService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _currentSongIndex = 0;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _position = position;
      });
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      });
      // Auto play next song
      if (_currentSongIndex < widget.category.songs.length - 1) {
        _playNextSong();
      }
    });
  }

  Future<void> _playSong(int index) async {
    final song = widget.category.songs[index];
    await _audioPlayer.stop();

    // Check if it's a streaming URL or local asset
    if (song.isStreamUrl) {
      await _audioPlayer.play(UrlSource(song.assetPath));
    } else {
      await _audioPlayer.play(
        AssetSource(song.assetPath.replaceFirst('assets/', '')),
      );
    }

    setState(() {
      _currentSongIndex = index;
      _isPlaying = true;
    });
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      if (_position == Duration.zero) {
        await _playSong(_currentSongIndex);
      } else {
        await _audioPlayer.resume();
        setState(() {
          _isPlaying = true;
        });
      }
    }
  }

  void _playNextSong() {
    if (_currentSongIndex < widget.category.songs.length - 1) {
      _playSong(_currentSongIndex + 1);
    }
  }

  void _playPreviousSong() {
    if (_currentSongIndex > 0) {
      _playSong(_currentSongIndex - 1);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Color _getCategoryColor() {
    final colorMap = {
      'Rock': const Color(0xFFe74c3c),
      'Pop': const Color(0xFFe91e63),
      'Jazz': const Color(0xFF9b59b6),
      'Classical': const Color(0xFF3498db),
      'Hip Hop': const Color(0xFFf39c12),
      'Romantic': const Color(0xFFff6b9d),
    };
    return colorMap[widget.category.name] ?? const Color(0xFF34495e);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = widget.category.songs[_currentSongIndex];
    final categoryColor = _getCategoryColor();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              categoryColor.withOpacity(0.8),
              const Color(0xFF1a1a2e),
              const Color(0xFF0f0f1e),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.category.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${widget.category.songs.length} tracks',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Profile Picture
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                      },
                      child: _authService.currentUser?.photoUrl != null
                          ? Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: CircleAvatar(
                                radius: 18,
                                backgroundImage: NetworkImage(
                                  _authService.currentUser!.photoUrl!,
                                ),
                                backgroundColor: Colors.white.withOpacity(0.1),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.white.withOpacity(0.1),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                    ),
                    Image.asset(
                      widget.category.icon,
                      width: 36,
                      height: 36,
                      color: Colors.white,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.music_note,
                          size: 36,
                          color: Colors.white,
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Album Art / Player Display
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              categoryColor.withOpacity(0.6),
                              categoryColor.withOpacity(0.3),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: categoryColor.withOpacity(0.4),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              widget.category.icon,
                              width: 120,
                              height: 120,
                              color: Colors.white.withOpacity(0.9),
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  _isPlaying
                                      ? Icons.music_note
                                      : Icons.music_note_outlined,
                                  size: 120,
                                  color: Colors.white.withOpacity(0.9),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          children: [
                            Text(
                              currentSong.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentSong.artist,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Player Controls
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1a1a2e).withOpacity(0.8),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    // Progress Bar
                    Column(
                      children: [
                        SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 8,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 16,
                            ),
                            activeTrackColor: categoryColor,
                            inactiveTrackColor: Colors.white.withOpacity(0.2),
                            thumbColor: categoryColor,
                            overlayColor: categoryColor.withOpacity(0.3),
                          ),
                          child: Slider(
                            min: 0,
                            max: _duration.inSeconds.toDouble(),
                            value: _position.inSeconds.toDouble().clamp(
                              0,
                              _duration.inSeconds.toDouble(),
                            ),
                            onChanged: (value) async {
                              await _audioPlayer.seek(
                                Duration(seconds: value.toInt()),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(_position),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                _formatDuration(_duration),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Control Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.skip_previous),
                            iconSize: 36,
                            color: Colors.white,
                            onPressed: _currentSongIndex > 0
                                ? _playPreviousSong
                                : null,
                          ),
                        ),
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                categoryColor,
                                categoryColor.withOpacity(0.7),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: categoryColor.withOpacity(0.5),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                            ),
                            iconSize: 40,
                            color: Colors.white,
                            onPressed: _togglePlayPause,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.skip_next),
                            iconSize: 36,
                            color: Colors.white,
                            onPressed:
                                _currentSongIndex <
                                    widget.category.songs.length - 1
                                ? _playNextSong
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Queue / Playlist
                    Container(
                      constraints: const BoxConstraints(maxHeight: 150),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: widget.category.songs.length,
                        itemBuilder: (context, index) {
                          final song = widget.category.songs[index];
                          final isCurrentSong = index == _currentSongIndex;

                          return ListTile(
                            dense: true,
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isCurrentSong
                                    ? categoryColor.withOpacity(0.3)
                                    : Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isCurrentSong && _isPlaying
                                    ? Icons.equalizer
                                    : Icons.music_note,
                                color: isCurrentSong
                                    ? categoryColor
                                    : Colors.white.withOpacity(0.5),
                                size: 20,
                              ),
                            ),
                            title: Text(
                              song.title,
                              style: TextStyle(
                                fontWeight: isCurrentSong
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isCurrentSong
                                    ? categoryColor
                                    : Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              song.artist,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 12,
                              ),
                            ),
                            onTap: () => _playSong(index),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
