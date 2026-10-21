import '../../../core/network/models/api_error.dart';
import '../../../core/network/models/api_response.dart';

enum FamilyRole { owner, admin, member }

class Family {
  const Family({required this.id, required this.name, required this.role});
  final String id;
  final String name;
  final FamilyRole role;
  bool get canEdit => role != FamilyRole.member;

  factory Family.fromJson(Object? value) {
    final Map<String, Object?> json = responseObject(value);
    return Family(
      id: responseValue<String>(json, 'id'),
      name: responseValue<String>(json, 'name'),
      role: switch (json['myRole']) {
        'OWNER' => FamilyRole.owner,
        'ADMIN' => FamilyRole.admin,
        'MEMBER' => FamilyRole.member,
        _ => throw const ApiError(kind: ApiFailure.invalidResponse),
      },
    );
  }
}

class ResultPage<T> {
  const ResultPage({
    required this.items,
    required this.page,
    required this.hasNext,
  });
  final List<T> items;
  final int page;
  final bool hasNext;

  factory ResultPage.fromJson(Object? value, T Function(Object?) decode) {
    final Map<String, Object?> json = responseObject(value);
    return ResultPage(
      items: List<T>.unmodifiable(
        responseValue<List<Object?>>(json, 'items').map(decode),
      ),
      page: responseValue<int>(json, 'page'),
      hasNext: responseValue<bool>(json, 'hasNext'),
    );
  }
}
