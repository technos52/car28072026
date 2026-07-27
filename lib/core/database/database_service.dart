import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:drift/drift.dart' as drift;
import 'database.dart';

class DatabaseService extends GetxService {
  AppDatabase? _database;

  AppDatabase? get database => _database;
  bool get isInitialized => _database != null;

  @override
  Future<void> onInit() async {
    super.onInit();
    if (kIsWeb) {
      print('DatabaseService: Skipping initialization on web platform');
      return;
    }
    try {
      print('Initializing database...');
      _database = AppDatabase();
      print('Database initialized successfully');
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  @override
  void onClose() {
    _database?.close();
    super.onClose();
  }

  // User operations
  Future<void> saveUser({
    required String id,
    required String name,
    required String email,
    required String phone,
    required String gender,
    String? avatarUrl,
  }) async {
    if (_database == null) return;
    await _database!.insertUser(
      UsersCompanion(
        id: drift.Value(id),
        name: drift.Value(name),
        email: drift.Value(email),
        phone: drift.Value(phone),
        gender: drift.Value(gender),
        avatarUrl: drift.Value(avatarUrl),
        createdAt: drift.Value(DateTime.now()),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );
  }

  Future<void> saveShop({
    required String id,
    required String userId,
    required String shopName,
    required String ownerName,
    required String phone,
    required String email,
    required String address,
    required String city,
    required String state,
    required String pincode,
    String? logoUrl,
  }) async {
    if (_database == null) return;
    await _database!.insertShop(
      ShopsCompanion(
        id: drift.Value(id),
        userId: drift.Value(userId),
        shopName: drift.Value(shopName),
        ownerName: drift.Value(ownerName),
        phone: drift.Value(phone),
        email: drift.Value(email),
        address: drift.Value(address),
        city: drift.Value(city),
        state: drift.Value(state),
        pincode: drift.Value(pincode),
        logoUrl: drift.Value(logoUrl),
        createdAt: drift.Value(DateTime.now()),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );
  }

  Future<void> saveKycDocument({
    required String id,
    required String userId,
    String? panPath,
    String? aadhaarPath,
    String? addressProofPath,
    bool isVerified = false,
  }) async {
    if (_database == null) return;
    await _database!.insertKycDocument(
      KycDocumentsCompanion(
        id: drift.Value(id),
        userId: drift.Value(userId),
        panPath: drift.Value(panPath),
        aadhaarPath: drift.Value(aadhaarPath),
        addressProofPath: drift.Value(addressProofPath),
        isVerified: drift.Value(isVerified),
        createdAt: drift.Value(DateTime.now()),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );
  }

  Future<void> saveCar({
    required String id,
    required String userId,
    required String make,
    required String model,
    required String year,
    required String price,
    String? imageUrl,
    String? description,
    bool isAvailable = true,
  }) async {
    if (_database == null) return;
    await _database!.insertCar(
      CarsCompanion(
        id: drift.Value(id),
        userId: drift.Value(userId),
        make: drift.Value(make),
        model: drift.Value(model),
        year: drift.Value(year),
        price: drift.Value(price),
        imageUrl: drift.Value(imageUrl),
        description: drift.Value(description),
        isAvailable: drift.Value(isAvailable),
        createdAt: drift.Value(DateTime.now()),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );
  }

  // Get data
  Future<dynamic> getUser(String userId) async {
    if (_database == null) return null;
    return await _database!.getUser(userId);
  }

  Future<dynamic> getShop(String userId) async {
    if (_database == null) return null;
    return await _database!.getShop(userId);
  }

  Future<dynamic> getKycDocument(String userId) async {
    if (_database == null) return null;
    return await _database!.getKycDocument(userId);
  }

  Future<List<dynamic>> getUserCars(String userId) async {
    if (_database == null) return [];
    return await _database!.getUserCars(userId);
  }

  Future<List<dynamic>> getAllCars() async {
    if (_database == null) return [];
    return await _database!.getAllCars();
  }

  // Clear all data (logout)
  Future<void> clearAllData() async {
    if (_database == null) return;
    await _database!.clearAllData();
  }

  Future<void> deleteCar(String carId) async {
    if (_database == null) return;
    await _database!.deleteCar(carId);
  }
}
