
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/features/music/presentation/cubit/music_cubit.dart';
import 'package:music_app/features/music/presentation/widgets/mini_player.dart';
import 'package:music_app/features/music/presentation/widgets/song_list_with_alphabet.dart';
import 'package:music_app/shared/theme/app_colors.dart';
import 'package:music_app/shared/widgets/pdf_page.dart';
import 'package:music_app/shared/widgets/volume_button.dart';

class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  @override
  void initState() {
    super.initState();
    context.read<MusicCubit>().scanForSongs();
  }

  @override
  void dispose(){
    super.dispose();
    context.read<MusicCubit>().dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocConsumer<MusicCubit, MusicState>(
      listener: (context, state) {
        if (state is MusicError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        if (state is MusicLoading) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (state is MusicEmpty) {
          return Scaffold(
            body: Center(
              child: Text(
                "No songs found",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          );
        }
        if (state is MusicLoaded) {
          return Scaffold(
            appBar: AppBar(
              scrolledUnderElevation: 0,
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: Theme.of(context).colorScheme.primary,
              title: Text(
                "Music Player",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              actions: [
                VolumeButtonWidget(),
                PdfPage(songs: state.songs.data),
              ],
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [AppColors.dark.gradientStart, AppColors.dark.gradientEnd,]
                      : [AppColors.light.gradientStart, AppColors.light.gradientEnd,],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SongListWithAlphabet(
                songs: state.songs.data,
                currentIndex: state.currentIndex,
                onSongTap: (song) {
                  final index = state.songs.data.indexOf(song);
                  context.read<MusicCubit>().playSong(index);
                }, isPlaying: state.isPlaying,
              ),
              // child: ListView.builder(
              //   shrinkWrap: true,
              //   physics: BouncingScrollPhysics(),
              //   itemCount: state.songs.data.length,
              //   itemBuilder: (context, index) {
              //     return SongTile(
              //       song: state.songs.data[index],
              //       isPlaying: state.currentIndex == index && state.isPlaying,
              //       onTap: () {
              //         context.read<MusicCubit>().playSong(index);
              //       },
              //     );
              //   },
              // ),
            ),
            bottomNavigationBar: MiniPlayer(),
          );
        }
        return SizedBox.shrink();
      },
    );
  }
}
