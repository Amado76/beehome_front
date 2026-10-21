import '../../../core/network/models/api_response.dart';
import '../../../core/network/models/api_error.dart';

enum MemberType { adult, child }

class FamilyProfile {
  const FamilyProfile({
    required this.id,
    required this.familyId,
    required this.name,
    required this.type,
    required this.active,
    this.color,
    this.birthDate,
    this.completedTaskColor,
  });
  final String id;
  final String familyId;
  final String name;
  final MemberType type;
  final bool active;
  final String? color;
  final String? birthDate;
  final String? completedTaskColor;
  bool get isAdult => type == MemberType.adult;
  factory FamilyProfile.fromJson(Object? value) {
    final Map<String, Object?> json = responseObject(value);
    final Map<String, Object?> preferences = responseObject(
      json['preferences'],
    );
    return FamilyProfile(
      id: responseValue<String>(json, 'id'),
      familyId: responseValue<String>(json, 'familyId'),
      name: responseValue<String>(json, 'name'),
      type: switch (json['memberType']) {
        'ADULT' => MemberType.adult,
        'CHILD' => MemberType.child,
        _ => throw const ApiError(kind: ApiFailure.invalidResponse),
      },
      active: responseValue<bool>(json, 'active'),
      color: json['color'] as String?,
      birthDate: json['birthDate'] as String?,
      completedTaskColor: preferences['completedTaskColor'] as String?,
    );
  }
}
