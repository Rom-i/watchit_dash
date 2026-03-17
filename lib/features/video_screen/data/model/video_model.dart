class VideoModel {
  final String id;
  final String title;
  final String desc;
  final String videoUrl;
  VideoModel({
    required this.id,
    required this.title,
    required this.desc,
    required this.videoUrl,
  });

  factory VideoModel.fromSopabase(Map<String, dynamic> data) {
    return VideoModel(
      id: data['id'],
      title: data['title'],
      desc: data['desc'],
      videoUrl: data['video_url'],
    );
  }
}