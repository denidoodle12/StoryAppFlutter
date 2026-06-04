import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/repositories/story_repository.dart';

class StoryUploadProvider extends ChangeNotifier {
  final StoryRepository repository;
  final String token;

  StoryUploadProvider({required this.repository, required this.token});

  XFile? _imageFile;
  XFile? get imageFile => _imageFile;

  Uint8List? _imageBytes;
  Uint8List? get imageBytes => _imageBytes;

  bool _isUploading = false;
  bool get isUploading => _isUploading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> setImage(XFile file) async {
    _imageFile = file;
    _imageBytes = await file.readAsBytes();
    _errorMessage = null;
    notifyListeners();
  }

  void clearImage() {
    _imageFile = null;
    _imageBytes = null;
    notifyListeners();
  }

  Future<bool> upload({required String description}) async {
    if (_imageFile == null || _imageBytes == null) {
      _errorMessage = 'Please select an image';
      notifyListeners();
      return false;
    }

    _isUploading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.uploadStory(
        token: token,
        description: description,
        photoBytes: _imageBytes!,
        fileName: _imageFile!.name,
      );
      _isUploading = false;
      _imageFile = null;
      _imageBytes = null;
      notifyListeners();
      return true;
    } catch (e) {
      _isUploading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
