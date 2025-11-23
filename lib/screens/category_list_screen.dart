import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/music_category.dart';
import '../services/auth_service.dart';
import 'music_player_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';

class CategoryListScreen extends StatefulWidget {
  final List<MusicCategory> categories;

  const CategoryListScreen({super.key, required this.categories});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  final AuthService _authService = AuthService();
  String? _selectedCategoryName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSelectedCategory();
  }

  Future<void> _loadSelectedCategory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedCategoryName = prefs.getString('selected_category');
      _isLoading = false;
    });

    // Show instruction dialog if no category is selected
    if (_selectedCategoryName == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSelectionDialog();
      });
    }
  }

  void _showSelectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.music_note, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Choose Your Music Category',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please select ONE music category that you want to listen to.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Once selected, you can only access this category. You can change it later.',
                      style: TextStyle(
                        color: Colors.orange.shade200,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetCategory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selected_category');
    setState(() {
      _selectedCategoryName = null;
    });
  }

  List<MusicCategory> get _displayCategories {
    if (_selectedCategoryName == null) {
      return widget.categories;
    }
    return widget.categories
        .where((cat) => cat.name == _selectedCategoryName)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1a1a2e),
              const Color(0xFF16213e),
              const Color(0xFF0f3460),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.music_note,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Tune',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        // Search Button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.search,
                              color: Colors.white,
                              size: 24,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SearchScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
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
                                  padding: const EdgeInsets.only(right: 12),
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundImage: NetworkImage(
                                      _authService.currentUser!.photoUrl!,
                                    ),
                                    backgroundColor: Colors.white.withOpacity(
                                      0.1,
                                    ),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.white.withOpacity(
                                      0.1,
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                        ),
                        // Show change category button if a category is selected
                        if (_selectedCategoryName != null)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 24,
                              ),
                              onPressed: () async {
                                final shouldReset = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: const Color(0xFF1a1a2e),
                                    title: const Text(
                                      'Change Category',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    content: const Text(
                                      'Do you want to choose a different music category?',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Change'),
                                      ),
                                    ],
                                  ),
                                );
                                if (shouldReset == true) {
                                  await _resetCategory();
                                }
                              },
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedCategoryName == null
                          ? 'Select ONE category to continue'
                          : 'Your selected category: $_selectedCategoryName',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: _selectedCategoryName == null
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: _selectedCategoryName == null
                            ? Colors.orangeAccent
                            : Colors.white.withOpacity(0.7),
                      ),
                    ),
                    if (_selectedCategoryName == null)
                      const SizedBox(height: 4),
                    if (_selectedCategoryName == null)
                      Text(
                        'Tap any category below',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _displayCategories.isNotEmpty
                        ? _displayCategories[0].songs.length
                        : 0,
                    itemBuilder: (context, index) {
                      if (_displayCategories.isEmpty) return const SizedBox();

                      final song = _displayCategories[0].songs[index];
                      final category = _displayCategories[0];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: Colors.white.withOpacity(0.05),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          leading: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.deepPurple.withOpacity(0.6),
                                  Colors.deepPurple.withOpacity(0.3),
                                ],
                              ),
                              image:
                                  song.albumArt != null &&
                                      song.albumArt!.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(song.albumArt!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child:
                                song.albumArt == null || song.albumArt!.isEmpty
                                ? const Icon(
                                    Icons.music_note,
                                    color: Colors.white,
                                    size: 30,
                                  )
                                : null,
                          ),
                          title: Text(
                            song.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                song.artist,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (song.genre != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      song.genre!,
                                      style: TextStyle(
                                        color: Colors.deepPurple.shade200,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.play_circle_filled,
                              color: Colors.deepPurple,
                              size: 40,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MusicPlayerScreen(category: category),
                                ),
                              );
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MusicPlayerScreen(category: category),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
