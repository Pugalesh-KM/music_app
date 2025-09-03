import 'package:flutter/material.dart';
import 'package:music_app/features/music/presentation/widgets/song_tile.dart';
import 'package:music_app/shared/models/song_model.dart';


class SongListWithAlphabet extends StatefulWidget {
  final List<SongModel> songs;
  final int? currentIndex;
  final Function(SongModel) onSongTap;
  final bool isPlaying;

  const SongListWithAlphabet({
    super.key,
    required this.songs,
    this.currentIndex,
    required this.onSongTap,
    required this.isPlaying,
  });

  @override
  State<SongListWithAlphabet> createState() => _SongListWithAlphabetState();
}

class _SongListWithAlphabetState extends State<SongListWithAlphabet> {
  final ScrollController _scrollController = ScrollController();
  late Map<String, int> _letterIndexMap;

  @override
  void initState() {
    super.initState();
    _generateIndexMap();
  }

  void _generateIndexMap() {
    _letterIndexMap = {};
    for (int i = 0; i < widget.songs.length; i++) {
      if (widget.songs[i].title.isNotEmpty) {
        final firstLetter = widget.songs[i].title[0].toUpperCase();
        _letterIndexMap.putIfAbsent(firstLetter, () => i);
      }
    }
  }

  void _scrollToLetter(String letter) {
    if (_letterIndexMap.containsKey(letter)) {
      final index = _letterIndexMap[letter]!;
      _scrollController.animateTo(
        index * 80.0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final alphabet = List.generate(26, (i) => String.fromCharCode(65 + i));

    return Row(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: widget.songs.length,
            itemBuilder: (context, index) {
              final song = widget.songs[index];
              final isPlaying = widget.currentIndex == index && widget.isPlaying;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: SongTile(
                  song: song,
                  isPlaying: isPlaying,
                  onTap: () => widget.onSongTap(song),
                ),
              );
            },
          ),
        ),

        Container(
          width: 28,
          margin: const EdgeInsets.only(right: 4,top: 4,bottom: 4),
          decoration: BoxDecoration(
          color: colorScheme.surface.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
        ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: alphabet.map((letter) {
              return GestureDetector(
                onTap: () => _scrollToLetter(letter),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    letter,
                    style: TextStyle(
                      fontSize: 12,
                      color: _letterIndexMap.containsKey(letter)
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
