class CharacterStats {
  int str = 1;
  int intStat = 1;
  int vit = 1;
  int agi = 1;
  int dex = 1;
  bool enabled = true;

  Map<String, dynamic> toJson() => {
        'STR': str,
        'INT': intStat,
        'VIT': vit,
        'AGI': agi,
        'DEX': dex,
        'enabled': enabled,
      };
}
