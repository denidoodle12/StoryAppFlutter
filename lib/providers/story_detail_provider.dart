import 'package:flutter/material.dart';

import '../data/models/story.dart';
import '../data/repositories/story_repository.dart';
import '../utils/result_state.dart';

class StoryDetailProvider extends ChangeNotifier {
  final StoryRepository repository;
  final String token;

  StoryDetailProvider({required this.repository, required this.token});

  ResultState<Story> _state = const ResultLoading();
  ResultState<Story> get state => _state;

  Future<void> fetchDetail(String id) async {
    _state = const ResultLoading();
    notifyListeners();

    try {
      final story = await repository.getStoryDetail(token: token, id: id);
      _state = ResultSuccess(story);
    } catch (e) {
      _state = ResultError(e.toString().replaceFirst('Exception: ', ''));
    }

    notifyListeners();
  }
}
