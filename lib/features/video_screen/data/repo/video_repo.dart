import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:watchit_dash/features/video_screen/data/model/video_model.dart';

class VideoRepo {
  final SupabaseClient _client;

  VideoRepo({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Future<List<VideoModel>> fetchVideos() async {
    final response = await _client
        .from('videos')
        .select()
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((item) => VideoModel.fromSopabase(item as Map<String, dynamic>))
        .toList();
  }
}