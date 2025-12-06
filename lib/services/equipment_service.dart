import '../models/weapon.dart';
import '../models/crystal.dart';

class EquipmentService {
  static List<Weapon> sampleWeapons() {
    return [
      Weapon(id: 'w001', name: 'Mace Sword', baseAtk: 600),
      Weapon(id: 'w002', name: 'Steel Katana', baseAtk: 720),
      Weapon(id: 'w003', name: 'Oak Bow', baseAtk: 480),
      Weapon(id: 'w004', name: 'Mystic Staff', baseAtk: 200),
    ];
  }

  static List<Crystal> sampleCrystals() => Crystal.sampleList;
}
