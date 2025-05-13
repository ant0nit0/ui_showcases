class Video {
  final String path;
  final String thumbnailUrl;
  final String username;
  final String description;
  final int likes;
  final int comments;

  Video({
    required this.path,
    required this.thumbnailUrl,
    required this.username,
    required this.description,
    this.likes = 0,
    this.comments = 0,
  });
}
