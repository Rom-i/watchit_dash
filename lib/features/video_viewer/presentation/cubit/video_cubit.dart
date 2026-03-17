import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watchit_dash/features/video_viewer/data/repo/video_repo.dart';
import 'video_state.dart';

class VideoCubit extends Cubit<VideoState> {
  final VideoRepo _repo;

  VideoCubit(this._repo) : super(VideoInitial());

  Future<void> loadVideos() async {
    emit(VideoLoading());
    try {
      final videos = await _repo.fetchVideos();
      emit(VideoLoaded(videos));
    } catch (e) {
      emit(VideoError('Failed to load videos: $e'));
    }
  }
}