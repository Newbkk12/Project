class Weapon {
  final String id;
  final String name;
  final int baseAtk;
  int refine;
  int watk;
  Weapon({
    required this.id,
    required this.name,
    required this.baseAtk,
    this.refine = 0,
    int? watk,
  }) : watk = watk ?? baseAtk;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'baseAtk': baseAtk,
        'refine': refine,
        'watk': watk
      };
}
