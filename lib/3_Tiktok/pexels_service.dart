import 'dart:convert';

import 'package:http/http.dart' as http;

import 'video.dart';

class PexelsService {
  static const String _baseUrl = 'https://api.pexels.com/videos';
  final String _apiKey;

  PexelsService(this._apiKey);

  Future<List<Video>> getPopularVideos({int perPage = 10}) async {
    final response = await http.get(
      Uri.parse(
          '$_baseUrl/search?query=nature&orientation=portrait&per_page=$perPage'),
      headers: {'Authorization': _apiKey},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final videos = data['videos'] as List;

      return videos.map((video) {
        final videoFiles = video['video_files'] as List;
        final hdVideo = videoFiles.firstWhere(
          (file) => file['quality'] == 'hd',
          orElse: () => videoFiles.first,
        );

        return Video(
          path: hdVideo['link'],
          thumbnailUrl: video['image'],
          username: 'user_${video['id']}',
          description: video['user']['name'],
          likes: video['likes'] ?? 0,
          comments: 0,
        );
      }).toList();
    } else {
      throw Exception('Failed to load videos');
    }
  }
}
