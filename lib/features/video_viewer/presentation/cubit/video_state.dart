import 'package:watchit_dash/features/video_viewer/data/model/video_model.dart';


abstract class VideoState {}

class VideoInitial extends VideoState {}

class VideoLoading extends VideoState {}

class VideoLoaded extends VideoState {
  final List<VideoModel> videos;
  VideoLoaded(this.videos);
}

class VideoError extends VideoState {
  final String message;
  VideoError(this.message);
}