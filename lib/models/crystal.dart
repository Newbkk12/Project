class Crystal {
  final String id;
  final String name;
  final String type;
  final Map<String, num> stats;

  Crystal({
    required this.id,
    required this.name,
    required this.type,
    required this.stats,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'stats': stats,
      };

  static final List<Crystal> sampleList = [
    Crystal(id: 'c001', name: 'Cake Potum', type: 'blue', stats: {'HP%': 30}),
    Crystal(
        id: 'c002',
        name: 'Pomie Chan III',
        type: 'red',
        stats: {'AGI%': 10, 'ATK%': 12}),
    Crystal(
        id: 'c003', name: 'Lava Crystal', type: 'weapon', stats: {'CRIT%': 30}),
    Crystal(
        id: 'c004',
        name: 'Iconos',
        type: 'armor',
        stats: {'HP%': 20, 'DEF': 10}),
  ];
}
