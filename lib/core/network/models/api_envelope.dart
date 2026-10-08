class ApiEnvelope<T> {
  const ApiEnvelope({required this.success, this.data, this.error, this.meta});

  factory ApiEnvelope.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) parser,
  ) {
    return ApiEnvelope<T>(
      success: json['success'] as bool? ?? false,
      data: json.containsKey('data') ? parser(json['data']) : null,
      error: json['error'] == null
          ? null
          : ApiErrorPayload.fromJson(json['error'] as Map<String, dynamic>),
      meta: json['meta'] == null
          ? null
          : PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  final bool success;
  final T? data;
  final ApiErrorPayload? error;
  final PaginationMeta? meta;
}

class ApiErrorPayload {
  const ApiErrorPayload({
    required this.type,
    required this.title,
    required this.status,
    this.detail,
    this.traceId,
  });

  factory ApiErrorPayload.fromJson(Map<String, dynamic> json) {
    return ApiErrorPayload(
      type: json['type'] as String? ?? 'unknown_error',
      title: json['title'] as String? ?? 'Unknown Error',
      status: json['status'] as int? ?? 500,
      detail: json['detail'] as String?,
      traceId: json['traceId'] as String?,
    );
  }

  final String type;
  final String title;
  final int status;
  final String? detail;
  final String? traceId;
}

class PaginationMeta {
  const PaginationMeta({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 20,
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
    );
  }

  final int page;
  final int pageSize;
  final int total;
  final int totalPages;
}
