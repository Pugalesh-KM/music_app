import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:music_app/features/music/presentation/cubit/music_cubit.dart';
import 'package:music_app/features/music/presentation/widgets/music_player.dart';


class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key,});
  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  @override
  Widget build(BuildContext context) {
    final musicCubit = context.read<MusicCubit>();
     final theme = Theme.of(context);
     final colorScheme = theme.colorScheme;
    return BlocBuilder<MusicCubit, MusicState>(
      builder: (context, state) {
        if (state is! MusicLoaded || state.duration == null) {
          return const SizedBox.shrink();
        }

        final currentSong = state.songs.data[state.currentIndex!];

        return GestureDetector(
          onTap: () {
            //context.push(RoutesName.musicPlayerPath);
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => BlocProvider.value(
                  value: musicCubit,
                  child: const MusicPlayer(),
                ),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0, 1); // start from bottom
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;

                  final slideTween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  final fadeTween = Tween(begin: 0.0, end: 1.0)
                      .chain(CurveTween(curve: curve));

                  return SlideTransition(
                    position: animation.drive(slideTween),
                    child: FadeTransition(
                      opacity: animation.drive(fadeTween),
                      child: child,
                    ),
                  );
                },
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          },

          child: Container(
            height: 80,
            width: double.maxFinite,
            decoration: BoxDecoration(
              color: colorScheme.primary,
            ),
            child: ListTile(
              leading: Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: theme.sliderTheme.inactiveTrackColor,
                  //border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Hero(
                  tag: 'my-hero-animation-tag',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      File(currentSong.coverImage),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.music_note_outlined, size: 32, color: colorScheme.onSurface);
                      },
                    ),
                  ),
                ),
              ),
              title: Text(
                currentSong.title,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
              ),
              subtitle: Text(
                currentSong.artist,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 0.7),
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: musicCubit.skipPrevious,
                    icon: Icon(Icons.skip_previous,color: colorScheme.onPrimary),
                  ),
                  IconButton(
                    onPressed: musicCubit.playPause,
                    icon: Icon(
                      state.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: musicCubit.skipNext,
                    icon: Icon(Icons.skip_next,color: colorScheme.onPrimary),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
