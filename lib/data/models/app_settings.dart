class AppSettings {
  final bool soundEnabled, vibrationEnabled;
  final String themeMode;
  const AppSettings({
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.themeMode = 'system',
  });
  AppSettings copyWith({
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? themeMode,
  }) => AppSettings(
    soundEnabled: soundEnabled ?? this.soundEnabled,
    vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    themeMode: themeMode ?? this.themeMode,
  );
  Map<String, dynamic> toJson() => {
    'soundEnabled': soundEnabled,
    'vibrationEnabled': vibrationEnabled,
    'themeMode': themeMode,
  };
  factory AppSettings.fromJson(Map<String, dynamic> j) => AppSettings(
    soundEnabled: j['soundEnabled'] ?? true,
    vibrationEnabled: j['vibrationEnabled'] ?? true,
    themeMode: j['themeMode'] ?? 'system',
  );
}
