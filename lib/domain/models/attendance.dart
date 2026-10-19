enum AttendancePresetType {
  full, // Đi đủ
  fromStage, // Đến từ chặng...
  untilStage, // Về sau chặng...
  absent, // Nghỉ toàn bộ
}

class AttendancePreset {
  final AttendancePresetType type;
  final String? targetStageId;

  const AttendancePreset({
    required this.type,
    this.targetStageId,
  });

  String get displayName {
    switch (type) {
      case AttendancePresetType.full:
        return 'Đi đủ tất cả các chặng';
      case AttendancePresetType.fromStage:
        return 'Đến từ chặng chỉ định';
      case AttendancePresetType.untilStage:
        return 'Về sau chặng chỉ định';
      case AttendancePresetType.absent:
        return 'Nghỉ hoàn toàn';
    }
  }
}
