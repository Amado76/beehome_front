import '../../../core/network/models/api_response.dart';
import '../../../core/network/models/api_error.dart';

enum ExecutionItemStatus { pending, completed, cancelled }

class ExecutionItem {
  const ExecutionItem({
    required this.id,
    required this.title,
    required this.status,
    this.time,
    this.description,
  });
  final String id;
  final String title;
  final ExecutionItemStatus status;
  final String? time;
  final String? description;
  bool get completed => status == ExecutionItemStatus.completed;
  factory ExecutionItem.fromJson(Object? value) {
    final Map<String, Object?> json = responseObject(value);
    return ExecutionItem(
      id: responseValue<String>(json, 'id'),
      title: responseValue<String>(json, 'title'),
      status: switch (json['status']) {
        'PENDING' => ExecutionItemStatus.pending,
        'COMPLETED' => ExecutionItemStatus.completed,
        'CANCELLED' => ExecutionItemStatus.cancelled,
        _ => throw const ApiError(kind: ApiFailure.invalidResponse),
      },
      time: json['scheduledTime'] as String?,
      description: json['description'] as String?,
    );
  }
}

class DailyExecution {
  const DailyExecution({
    required this.date,
    required this.memberId,
    required this.finalized,
    required this.items,
  });
  final String date;
  final String memberId;
  final bool finalized;
  final List<ExecutionItem> items;
  List<ExecutionItem> get visibleItems => items
      .where(
        (ExecutionItem item) => item.status != ExecutionItemStatus.cancelled,
      )
      .toList(growable: false);
  int get completed =>
      visibleItems.where((ExecutionItem item) => item.completed).length;
  factory DailyExecution.fromJson(Object? value) {
    final Map<String, Object?> json = responseObject(value);
    if (json['status'] != 'OPEN' && json['status'] != 'FINALIZED') {
      throw const ApiError(kind: ApiFailure.invalidResponse);
    }
    return DailyExecution(
      date: responseValue<String>(json, 'date'),
      memberId: responseValue<String>(responseObject(json['member']), 'id'),
      finalized: json['status'] == 'FINALIZED',
      items: List.unmodifiable(
        responseValue<List<Object?>>(json, 'items').map(ExecutionItem.fromJson),
      ),
    );
  }
}
