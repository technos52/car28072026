import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database_io.g.dart';

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  TextColumn get phone => text()();
  TextColumn get gender => text()();
  TextColumn get avatarUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Shops extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get shopName => text()();
  TextColumn get ownerName => text()();
  TextColumn get phone => text()();
  TextColumn get email => text()();
  TextColumn get address => text()();
  TextColumn get city => text()();
  TextColumn get state => text()();
  TextColumn get pincode => text()();
  TextColumn get logoUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class KycDocuments extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get panPath => text().nullable()();
  TextColumn get aadhaarPath => text().nullable()();
  TextColumn get addressProofPath => text().nullable()();
  BoolColumn get isVerified => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Cars extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get make => text()();
  TextColumn get model => text()();
  TextColumn get year => text()();
  TextColumn get price => text()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get description => text().nullable()();
  BoolColumn get isAvailable => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Users, Shops, KycDocuments, Cars])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<void> insertUser(UsersCompanion user) async {
    await into(users).insert(user, mode: InsertMode.insertOrReplace);
  }

  Future<User?> getUser(String userId) async {
    return await (select(
      users,
    )..where((tbl) => tbl.id.equals(userId))).getSingleOrNull();
  }

  Future<List<User>> getAllUsers() async {
    return await select(users).get();
  }

  Future<void> insertShop(ShopsCompanion shop) async {
    await into(shops).insert(shop, mode: InsertMode.insertOrReplace);
  }

  Future<Shop?> getShop(String userId) async {
    return await (select(
      shops,
    )..where((tbl) => tbl.userId.equals(userId))).getSingleOrNull();
  }

  Future<void> insertKycDocument(KycDocumentsCompanion kyc) async {
    await into(kycDocuments).insert(kyc, mode: InsertMode.insertOrReplace);
  }

  Future<KycDocument?> getKycDocument(String userId) async {
    return await (select(
      kycDocuments,
    )..where((tbl) => tbl.userId.equals(userId))).getSingleOrNull();
  }

  Future<void> insertCar(CarsCompanion car) async {
    await into(cars).insert(car, mode: InsertMode.insertOrReplace);
  }

  Future<List<Car>> getUserCars(String userId) async {
    return await (select(
      cars,
    )..where((tbl) => tbl.userId.equals(userId))).get();
  }

  Future<List<Car>> getAllCars() async {
    return await select(cars).get();
  }

  Future<void> clearAllData() async {
    await delete(cars).go();
    await delete(kycDocuments).go();
    await delete(shops).go();
    await delete(users).go();
  }

  Future<void> deleteCar(String carId) async {
    await (delete(cars)..where((tbl) => tbl.id.equals(carId))).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app_database.db'));
    return NativeDatabase(file);
  });
}
