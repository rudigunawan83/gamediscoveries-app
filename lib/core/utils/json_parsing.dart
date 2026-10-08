List<T> parseJsonList<T>(
  Object? json,
  T Function(Map<String, dynamic> json) itemParser,
) {
  if (json is! List) {
    return <T>[];
  }

  return json
      .whereType<Map<String, dynamic>>()
      .map(itemParser)
      .toList(growable: false);
}
