import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helpride/features/rides/domain/vehicle_type_model.dart';

final vehicleTypeRepositoryProvider = Provider((ref) => VehicleTypeRepository(FirebaseFirestore.instance));

final vehicleTypesProvider = StreamProvider<List<VehicleTypeModel>>((ref) {
  return ref.watch(vehicleTypeRepositoryProvider).streamVehicleTypes();
});

class VehicleTypeRepository {
  final FirebaseFirestore _firestore;

  VehicleTypeRepository(this._firestore);

  Stream<List<VehicleTypeModel>> streamVehicleTypes() {
    return _firestore
        .collection('vehicle_types')
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => VehicleTypeModel.fromFirestore(doc)).toList());
  }
  
  // Helper to seed data if needed (can be called manually)
  Future<void> seedDefaultTypes() async {
    final types = [
      {
        'id': 'bicycle',
        'nameEn': 'Bicycle',
        'nameZh': '單車',
        'descriptionEn': 'Cargo only',
        'descriptionZh': '只運貨物',
        'iconCode': 'pedal_bike',
        'sortOrder': 1,
        'isActive': true,
        'isDefault': false,
      },
      {
        'id': 'motorcycle',
        'nameEn': 'Motorcycle',
        'nameZh': '電單車',
        'descriptionEn': 'Cargo only / 1 Passenger',
        'descriptionZh': '只運貨物 / 1位乘客',
        'iconCode': 'two_wheeler',
        'sortOrder': 2,
        'isActive': true,
        'isDefault': false,
      },
      {
        'id': 'private_car_small',
        'nameEn': 'Private Car (Small)',
        'nameZh': '私家車（小）',
        'descriptionEn': 'Includes: 4-5 seater, regular taxi, small/medium SUV',
        'descriptionZh': '包括：4-5人車，普通的士，中小型SUV',
        'iconCode': 'local_taxi',
        'sortOrder': 3,
        'isActive': true,
        'isDefault': true,
      },
      {
        'id': 'private_car_large',
        'nameEn': 'Private Car (Large)',
        'nameZh': '私家車（大）',
        'descriptionEn': 'Includes: 6-7 seater, hybrid/large trunk taxi, large SUV',
        'descriptionZh': '包括：6-7人車，混電／大尾箱的士，大型SUV',
        'iconCode': 'airport_shuttle',
        'sortOrder': 4,
        'isActive': true,
        'isDefault': false,
      },
      {
        'id': 'van',
        'nameEn': 'Light Goods Vehicle (Van)',
        'nameZh': '客貨van',
        'descriptionEn': '~800kg Cargo',
        'descriptionZh': '~800kg 貨物',
        'iconCode': 'local_shipping',
        'sortOrder': 5,
        'isActive': true,
        'isDefault': false,
      },
      {
        'id': 'truck_5_5',
        'nameEn': '5.5 Tonne Truck',
        'nameZh': '5.5頓貨車',
        'descriptionEn': '~1200kg Cargo',
        'descriptionZh': '~1200kg 貨物',
        'iconCode': 'local_shipping',
        'sortOrder': 6,
        'isActive': true,
        'isDefault': false,
      },
      {
        'id': 'truck_9',
        'nameEn': '9 Tonne Truck',
        'nameZh': '9頓貨車',
        'descriptionEn': '~3500kg Cargo',
        'descriptionZh': '~3500kg 貨物',
        'iconCode': 'local_shipping',
        'sortOrder': 7,
        'isActive': true,
        'isDefault': false,
      },
    ];

    final batch = _firestore.batch();
    for (var type in types) {
      final docRef = _firestore.collection('vehicle_types').doc(type['id'] as String);
      batch.set(docRef, type);
    }
    await batch.commit();
  }
}
