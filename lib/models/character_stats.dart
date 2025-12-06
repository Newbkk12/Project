class CharacterStats {
  int str;
  int intStat;
  int vit;
  int agi;
  int dex;

  String specialType;
  int specialValue;

  final int maxPoints;

  CharacterStats({
    this.str = 1,
    this.intStat = 1,
    this.vit = 1,
    this.agi = 1,
    this.dex = 1,
    this.specialType = '',
    this.specialValue = 1,
    this.maxPoints = 500,
  });

  int get totalUsed {
    int base = str + intStat + vit + agi + dex;
    int special = specialType.isEmpty ? 0 : specialValue;
    return base + special;
  }

  int get remainingPoints {
    int remain = maxPoints - totalUsed;
    if (remain < 0) return 0;
    return remain;
  }

  Map<String, dynamic> toJson() {
    return {
      'str': str,
      'intStat': intStat,
      'vit': vit,
      'agi': agi,
      'dex': dex,
      'specialType': specialType,
      'specialValue': specialValue,
      'maxPoints': maxPoints,
    };
  }

  factory CharacterStats.fromJson(Map<String, dynamic> json) {
    return CharacterStats(
      str: json['str'] ?? 1,
      intStat: json['intStat'] ?? 1,
      vit: json['vit'] ?? 1,
      agi: json['agi'] ?? 1,
      dex: json['dex'] ?? 1,
      specialType: json['specialType'] ?? '',
      specialValue: json['specialValue'] ?? 1,
      maxPoints: json['maxPoints'] ?? 500,
    );
  }
}
