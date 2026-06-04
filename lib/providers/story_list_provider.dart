import 'package:flutter/material.dart';

import '../data/models/story.dart';
import '../data/repositories/story_repository.dart';
import '../utils/result_state.dart';

class StoryListProvider extends ChangeNotifier {
  final StoryRepository repository;
  final String token;

  StoryListProvider({required this.repository, required this.token}) {
    fetchStories();
  }

  ResultState<List<Story>> _state = const ResultLoading();
  ResultState<List<Story>> get state => _state;

  Future<void> fetchStories() async {
    _state = const ResultLoading();
    notifyListeners();

    try {
      final stories = await repository.getStories(token: token);

      if (stories.isEmpty) {
        _state = const ResultEmpty();
      } else {
        _state = ResultSuccess(stories);
      }
    } catch (e) {
      _state = ResultError(e.toString().replaceFirst('Exception: ', ''));
    }

    notifyListeners();
  }
}
