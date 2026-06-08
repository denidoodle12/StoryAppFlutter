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

  static const int _pageSize = 10;

  ResultState<List<Story>> _state = const ResultLoading();
  ResultState<List<Story>> get state => _state;

  final List<Story> _stories = [];
  List<Story> get stories => List.unmodifiable(_stories);

  int _page = 1;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  Future<void> fetchStories() async {
    _state = const ResultLoading();
    _stories.clear();
    _page = 1;
    _hasMore = true;
    _isLoadingMore = false;
    notifyListeners();

    try {
      final stories = await repository.getStories(
        token: token,
        page: _page,
        size: _pageSize,
      );

      if (stories.isEmpty) {
        _state = const ResultEmpty();
      } else {
        _stories.addAll(stories);
        _hasMore = stories.length >= _pageSize;
        _state = ResultSuccess(_stories);
      }
    } catch (e) {
      _state = ResultError(e.toString().replaceFirst('Exception: ', ''));
    }

    notifyListeners();
  }

  Future<void> fetchNextPage() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      _page++;
      final stories = await repository.getStories(
        token: token,
        page: _page,
        size: _pageSize,
      );

      if (stories.isEmpty) {
        _hasMore = false;
      } else {
        _stories.addAll(stories);
        _hasMore = stories.length >= _pageSize;
        _state = ResultSuccess(_stories);
      }
    } catch (e) {
      _page--;
    }

    _isLoadingMore = false;
    notifyListeners();
  }
}
