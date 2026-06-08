import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  LatLng? _selectedLocation;
  LatLng? get selectedLocation => _selectedLocation;

  String? _selectedAddress;
  String? get selectedAddress => _selectedAddress;

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

  void setLocation(LatLng location, String address) {
    _selectedLocation = location;
    _selectedAddress = address;
    notifyListeners();
  }

  void clearLocation() {
    _selectedLocation = null;
    _selectedAddress = null;
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
        lat: _selectedLocation?.latitude,
        lon: _selectedLocation?.longitude,
      );
      _isUploading = false;
      _imageFile = null;
      _imageBytes = null;
      _selectedLocation = null;
      _selectedAddress = null;
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
