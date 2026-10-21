import 'dart:convert';
import 'dart:math';
import '../../../core/network/models/api_error.dart';
import '../../../core/network/models/api_response.dart';

class DrawingPoint {
  const DrawingPoint(this.x, this.y, {this.pressure});
  final double x;
  final double y;
  final double? pressure;
  Map<String, Object?> toJson() => {
    'x': x,
    'y': y,
    if (pressure != null) 'pressure': pressure,
  };
  factory DrawingPoint.fromJson(Object? value) {
    final Map<String, Object?> json = responseObject(value);
    final double x = responseValue<num>(json, 'x').toDouble();
    final double y = responseValue<num>(json, 'y').toDouble();
    final double? pressure = (json['pressure'] as num?)?.toDouble();
    if (!x.isFinite ||
        !y.isFinite ||
        x < 0 ||
        x > 1 ||
        y < 0 ||
        y > 1 ||
        (pressure != null &&
            (!pressure.isFinite || pressure < 0 || pressure > 1))) {
      throw const ApiError(kind: ApiFailure.invalidResponse);
    }
    return DrawingPoint(x, y, pressure: pressure);
  }
}

class DrawingStroke {
  DrawingStroke({
    required this.id,
    required this.color,
    required this.width,
    required List<DrawingPoint> points,
  }) : points = List.unmodifiable(points);
  final String id;
  final String color;
  final double width;
  final List<DrawingPoint> points;
  Map<String, Object?> toJson() => {
    'id': id,
    'color': color,
    'width': width,
    'points': points.map((DrawingPoint point) => point.toJson()).toList(),
  };
  factory DrawingStroke.fromJson(Object? value) {
    final Map<String, Object?> json = responseObject(value);
    final DrawingStroke stroke = DrawingStroke(
      id: responseValue<String>(json, 'id'),
      color: responseValue<String>(json, 'color'),
      width: responseValue<num>(json, 'width').toDouble(),
      points: responseValue<List<Object?>>(
        json,
        'points',
      ).map(DrawingPoint.fromJson).toList(),
    );
    if (!RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(stroke.color) ||
        !RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        ).hasMatch(stroke.id) ||
        !stroke.width.isFinite ||
        stroke.width <= 0 ||
        stroke.width > 100 ||
        stroke.points.isEmpty ||
        stroke.points.length > 10000) {
      throw const ApiError(kind: ApiFailure.invalidResponse);
    }
    return stroke;
  }
}

class DrawingDocument {
  DrawingDocument({
    required this.revision,
    this.title,
    required List<DrawingStroke> strokes,
  }) : strokes = List.unmodifiable(strokes);
  final int revision;
  final String? title;
  final List<DrawingStroke> strokes;
  Map<String, Object?> toJson() => {
    'formatVersion': 1,
    'revision': revision,
    if (title != null) 'title': title,
    'strokes': strokes.map((DrawingStroke stroke) => stroke.toJson()).toList(),
  };
  String get content => jsonEncode({
    if (title != null) 'title': title,
    'strokes': strokes.map((DrawingStroke stroke) => stroke.toJson()).toList(),
  });
  bool get withinLimits =>
      strokes.length <= 5000 &&
      strokes.every((DrawingStroke stroke) => stroke.points.length <= 10000) &&
      utf8.encode(jsonEncode(toJson())).length <= 5242880;
  factory DrawingDocument.fromJson(Object? value) {
    final Map<String, Object?> json = responseObject(value);
    if (json['formatVersion'] != 1) {
      throw const ApiError(kind: ApiFailure.invalidResponse);
    }
    final DrawingDocument result = DrawingDocument(
      revision: responseValue<int>(json, 'revision'),
      title: json['title'] as String?,
      strokes: responseValue<List<Object?>>(
        json,
        'strokes',
      ).map(DrawingStroke.fromJson).toList(),
    );
    if (result.revision < 0 ||
        !result.withinLimits ||
        result.strokes
                .map((DrawingStroke stroke) => stroke.id)
                .toSet()
                .length !=
            result.strokes.length) {
      throw const ApiError(kind: ApiFailure.invalidResponse);
    }
    return result;
  }
}

String newStrokeId() {
  final Random random = Random.secure();
  final List<int> bytes = List.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 15) | 64;
  bytes[8] = (bytes[8] & 63) | 128;
  final String hex = bytes
      .map((int value) => value.toRadixString(16).padLeft(2, '0'))
      .join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}
