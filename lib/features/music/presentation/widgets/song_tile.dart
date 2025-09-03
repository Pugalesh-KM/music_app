import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:music_app/shared/models/song_model.dart';

class SongTile extends StatelessWidget {
  final SongModel song;
  final bool isPlaying;
  final VoidCallback onTap;

  const SongTile({
    super.key,
    required this.song,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return Container(
      margin:EdgeInsets.symmetric(horizontal: 8) ,
      decoration: BoxDecoration(
        //color: colorScheme.surface,
        border: Border.all(color: Colors.transparent),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 8),
        onTap: onTap,
        leading: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: theme.sliderTheme.inactiveTrackColor,
            border: Border.all(color: colorScheme.onSurface),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(
                    File(song.coverImage),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.music_note_outlined,
                        size: 32,
                        color: colorScheme.onSurface,
                      );
                    },
                  ),
                ),
              ),
              if (isPlaying)  Center(
                child: Lottie.asset(
                  "assets/lottie/music_play.json",
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
        title: Text(
          song.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodyLarge?.copyWith(color: isPlaying ? colorScheme.primary : colorScheme.onSurface),
        ),
        subtitle: Text(
          song.artist,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodyMedium?.copyWith(
              color: isPlaying ? colorScheme.primary.withOpacity(0.7) : colorScheme.onSurface.withOpacity(0.5)
          ),
        ),
        trailing: isPlaying
            ? Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary.withOpacity(0.2),
                ),
                child: Icon(Icons.pause, color: colorScheme.primary, size: 24),
              )
            : Icon(Icons.play_arrow, color: colorScheme.onSurface),
      ),
    );
  }
}
