import 'package:json_annotation/json_annotation.dart';

import 'story.dart';

part 'detail_response.g.dart';

@JsonSerializable()
class DetailResponse {
  final bool error;
  final String message;
  final Story? story;

  DetailResponse({required this.error, required this.message, this.story});

  factory DetailResponse.fromJson(Map<String, dynamic> json) =>
      _$DetailResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DetailResponseToJson(this);
}
