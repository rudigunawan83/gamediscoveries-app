enum GameSort {
  newest('newest'),
  popular('popular'),
  trending('trending'),
  title('title');

  const GameSort(this.value);

  final String value;
}

class GameListQuery {
  const GameListQuery({
    this.page = 1,
    this.pageSize = 20,
    this.search,
    this.category,
    this.platform,
    this.mobileReady,
    this.sort,
    this.tag,
  });

  final int page;
  final int pageSize;
  final String? search;
  final String? category;
  final String? platform;
  final bool? mobileReady;
  final GameSort? sort;
  final String? tag;

  Map<String, dynamic> toQueryParameters() {
    return <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      if (_hasText(search)) 'search': search,
      if (_hasText(category)) 'category': category,
      if (_hasText(platform)) 'platform': platform,
      if (mobileReady != null) 'mobileReady': mobileReady,
      if (sort != null) 'sort': sort!.value,
      if (_hasText(tag)) 'tag': tag,
    };
  }

  static bool _hasText(String? value) => value != null && value.isNotEmpty;

  @override
  bool operator ==(Object other) {
    return other is GameListQuery &&
        other.page == page &&
        other.pageSize == pageSize &&
        other.search == search &&
        other.category == category &&
        other.platform == platform &&
        other.mobileReady == mobileReady &&
        other.sort == sort &&
        other.tag == tag;
  }

  @override
  int get hashCode => Object.hash(
    page,
    pageSize,
    search,
    category,
    platform,
    mobileReady,
    sort,
    tag,
  );
}
