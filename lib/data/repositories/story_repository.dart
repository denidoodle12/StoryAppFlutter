import 'dart:typed_data';

import '../api/api_service.dart';
import '../models/story.dart';

class StoryRepository {
  final ApiService apiService;

  StoryRepository({required this.apiService});

  Future<List<Story>> getStories({
    required String token,
    int? page,
    int? size,
  }) async {
    return apiService.getStories(token: token, page: page, size: size);
  }

  Future<Story> getStoryDetail({
    required String token,
    required String id,
  }) async {
    return apiService.getStoryDetail(token: token, id: id);
  }

  Future<void> uploadStory({
    required String token,
    required String description,
    required Uint8List photoBytes,
    required String fileName,
    double? lat,
    double? lon,
  }) async {
    await apiService.uploadStory(
      token: token,
      description: description,
      photoBytes: photoBytes,
      fileName: fileName,
      lat: lat,
      lon: lon,
    );
  }
}
