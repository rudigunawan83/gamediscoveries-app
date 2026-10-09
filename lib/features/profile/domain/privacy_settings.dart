enum PrivacyOption {
  showFavorites('showFavorites'),
  showHistory('showHistory'),
  showAchievements('showAchievements'),
  showActivity('showActivity'),
  showOnLeaderboards('showOnLeaderboards');

  const PrivacyOption(this.jsonKey);

  final String jsonKey;
}

class PrivacySettings {
  const PrivacySettings(this.values);

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(<PrivacyOption, bool>{
      for (final option in PrivacyOption.values)
        option: json[option.jsonKey] as bool? ?? true,
    });
  }

  final Map<PrivacyOption, bool> values;

  bool operator [](PrivacyOption option) => values[option] ?? true;

  PrivacySettings copyWith(PrivacyOption option, bool value) {
    return PrivacySettings(<PrivacyOption, bool>{...values, option: value});
  }
}
