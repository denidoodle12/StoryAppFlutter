import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../common/api_constants.dart';
import '../models/detail_response.dart';
import '../models/general_response.dart';
import '../models/login_response.dart';
import '../models/stories_response.dart';
import '../models/story.dart';
import '../models/user.dart';

class ApiService {
  final http.Client client;

  ApiService({http.Client? client}) : client = client ?? http.Client();

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.registerEndpoint}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    final result = GeneralResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );

    if (result.error) {
      throw Exception(result.message);
    }
  }

  Future<User> login({required String email, required String password}) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final result = LoginResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );

    if (result.error || result.loginResult == null) {
      throw Exception(result.message);
    }

    return result.loginResult!;
  }

  Future<List<Story>> getStories({
    required String token,
    int? page,
    int? size,
  }) async {
    final queryParams = <String, String>{};
    if (page != null) queryParams['page'] = page.toString();
    if (size != null) queryParams['size'] = size.toString();

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.storiesEndpoint}',
    ).replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    final response = await client.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    final result = StoriesResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );

    if (result.error) {
      throw Exception(result.message);
    }

    return result.listStory;
  }

  Future<Story> getStoryDetail({
    required String token,
    required String id,
  }) async {
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.storiesEndpoint}/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final result = DetailResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );

    if (result.error || result.story == null) {
      throw Exception(result.message);
    }

    return result.story!;
  }

  Future<void> uploadStory({
    required String token,
    required String description,
    required Uint8List photoBytes,
    required String fileName,
    double? lat,
    double? lon,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.storiesEndpoint}',
    );

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['description'] = description
      ..files.add(
        http.MultipartFile.fromBytes('photo', photoBytes, filename: fileName),
      );

    if (lat != null) request.fields['lat'] = lat.toString();
    if (lon != null) request.fields['lon'] = lon.toString();

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final result = GeneralResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );

    if (result.error) {
      throw Exception(result.message);
    }
  }
}
