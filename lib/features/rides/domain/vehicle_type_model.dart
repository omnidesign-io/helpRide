import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleTypeModel {
  final String id;
  final String nameEn;
  final String nameZh;
  final String descriptionEn;
  final String descriptionZh;
  final String iconCode; // e.g., "directions_car"
  final int sortOrder;
  final bool isActive;
  final bool isDefault;

  const VehicleTypeModel({
    required this.id,
    required this.nameEn,
    required this.nameZh,
    required this.descriptionEn,
    required this.descriptionZh,
    required this.iconCode,
    required this.sortOrder,
    required this.isActive,
    required this.isDefault,
  });

  factory VehicleTypeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VehicleTypeModel(
      id: doc.id,
      nameEn: data['nameEn'] ?? '',
      nameZh: data['nameZh'] ?? '',
      descriptionEn: data['descriptionEn'] ?? '',
      descriptionZh: data['descriptionZh'] ?? '',
      iconCode: data['iconCode'] ?? 'directions_car',
      sortOrder: data['sortOrder'] ?? 0,
      isActive: data['isActive'] ?? true,
      isDefault: data['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nameEn': nameEn,
      'nameZh': nameZh,
      'descriptionEn': descriptionEn,
      'descriptionZh': descriptionZh,
      'iconCode': iconCode,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'isDefault': isDefault,
    };
  }
}
