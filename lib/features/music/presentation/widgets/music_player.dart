import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/features/music/presentation/cubit/music_cubit.dart';
import 'package:music_app/shared/theme/app_colors.dart';
import 'package:music_app/shared/widgets/volume_button.dart';

class MusicPlayer extends StatelessWidget {
  const MusicPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final musicCubit = context.read<MusicCubit>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<MusicCubit, MusicState>(
      builder: (context, state) {
        if (state is! MusicLoaded || state.currentIndex == null) {
          return Scaffold(
            body: Center(
              child: Text(
                "No song is playing",
                style: theme.textTheme.bodyLarge,
              ),
            ),
          );
        }

        final currentSong = state.songs.data[state.currentIndex!];
        final position = state.position;
        final duration = state.duration ?? Duration.zero;
        return GestureDetector(
          onVerticalDragUpdate: (details) {
            if (details.primaryDelta != null && details.primaryDelta! > 20) {
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            body: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [AppColors.dark.gradientStart, AppColors.dark.gradientEnd]
                      : [AppColors.light.gradientStart, AppColors.light.gradientEnd,],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {Navigator.of(context).pop(); },
                        icon: Icon(Icons.arrow_back_ios),
                      ),
                      VolumeButtonWidget(),
                    ],
                  ),
                  SizedBox(height: 16),
                  Hero(
                    tag: 'my-hero-animation-tag',
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeInOut,
                      width: state.isPlaying ? 300 : 180,
                      height: state.isPlaying ? 300 : 180,
                      decoration: BoxDecoration(
                        color: colorScheme.onPrimary.withOpacity(0.7),

                        border: Border.all(
                          color: colorScheme.onSurface.withOpacity(0.3),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.file(
                          File(currentSong.coverImage),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.music_note_outlined,
                              size: 64,
                              color: colorScheme.onSurface,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  Text(
                    currentSong.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onBackground,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    currentSong.artist,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    currentSong.album,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                  Spacer(),

                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Slider(
                        value: position.inMilliseconds.toDouble().clamp(
                          0,
                          duration.inMilliseconds.toDouble(),
                        ),
                        max: duration.inMilliseconds.toDouble(),
                        onChanged: (value) {
                          musicCubit.seekTo(
                            Duration(milliseconds: value.toInt()),
                          );
                        },
                        activeColor: colorScheme.primary,
                        inactiveColor: colorScheme.onSurface.withOpacity(0.3),
                        thumbColor: colorScheme.primary,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              musicCubit.formatDuration(position),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onBackground,
                              ),
                            ),
                            Text(
                              musicCubit.formatDuration(duration),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onBackground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () => musicCubit.toggleShuffle(),
                        icon: Icon(Icons.shuffle),
                        iconSize: 30,
                        color: state.shuffleEnabled
                            ? colorScheme.primary
                            : colorScheme.onBackground,
                      ),
                      IconButton(
                        onPressed: () => musicCubit.skipPrevious(),
                        icon: Icon(
                          Icons.skip_previous,
                          color: colorScheme.onBackground,
                        ),
                        iconSize: 40,
                      ),
                      IconButton(
                        onPressed: () => musicCubit.playPause(),
                        icon: Icon(
                          state.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: colorScheme.onBackground,
                        ),
                        iconSize: 40,
                      ),
                      IconButton(
                        onPressed: () => musicCubit.skipNext(),
                        icon: Icon(
                          Icons.skip_next,
                          color: colorScheme.onBackground,
                        ),
                        iconSize: 40,
                      ),
                      IconButton(
                        onPressed: () {
                          final cubit = context.read<MusicCubit>();
                          final newMode = switch (state.loopMode) {
                            LoopMode.off => LoopMode.all,
                            LoopMode.all => LoopMode.one,
                            LoopMode.one => LoopMode.off,
                          };
                          cubit.setLoopMode(newMode);
                        },
                        icon: Icon(switch (state.loopMode) {
                          LoopMode.off => Icons.text_rotation_none,
                          LoopMode.all => Icons.repeat,
                          LoopMode.one => Icons.repeat_one,
                        }),
                        color: colorScheme.onBackground,
                        iconSize: 30,
                      ),
                    ],
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
