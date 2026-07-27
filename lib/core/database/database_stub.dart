import 'package:drift/drift.dart' as drift;

part 'database_stub.g.dart';

class Users extends drift.Table {
  drift.TextColumn get id => text()();
  drift.TextColumn get name => text()();
  drift.TextColumn get email => text()();
  drift.TextColumn get phone => text()();
  drift.TextColumn get gender => text()();
  drift.TextColumn get avatarUrl => text().nullable()();
  drift.DateTimeColumn get createdAt => dateTime()();
  drift.DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<drift.Column> get primaryKey => {id};
}

class Shops extends drift.Table {
  drift.TextColumn get id => text()();
  drift.TextColumn get userId => text()();
  drift.TextColumn get shopName => text()();
  drift.TextColumn get ownerName => text()();
  drift.TextColumn get phone => text()();
  drift.TextColumn get email => text()();
  drift.TextColumn get address => text()();
  drift.TextColumn get city => text()();
  drift.TextColumn get state => text()();
  drift.TextColumn get pincode => text()();
  drift.DateTimeColumn get createdAt => dateTime()();
  drift.DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<drift.Column> get primaryKey => {id};
}

class KycDocuments extends drift.Table {
  drift.TextColumn get id => text()();
  drift.TextColumn get userId => text()();
  drift.TextColumn get panPath => text().nullable()();
  drift.TextColumn get aadhaarPath => text().nullable()();
  drift.TextColumn get addressProofPath => text().nullable()();
  drift.BoolColumn get isVerified => boolean().withDefault(const drift.Constant(false))();
  drift.DateTimeColumn get createdAt => dateTime()();
  drift.DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<drift.Column> get primaryKey => {id};
}

class Cars extends drift.Table {
  drift.TextColumn get id => text()();
  drift.TextColumn get userId => text()();
  drift.TextColumn get make => text()();
  drift.TextColumn get model => text()();
  drift.TextColumn get year => text()();
  drift.TextColumn get price => text()();
  drift.TextColumn get imageUrl => text().nullable()();
  drift.TextColumn get description => text().nullable()();
  drift.BoolColumn get isAvailable => boolean().withDefault(const drift.Constant(true))();
  drift.DateTimeColumn get createdAt => dateTime()();
  drift.DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<drift.Column> get primaryKey => {id};
}

@drift.DriftDatabase(tables: [Users, Shops, KycDocuments, Cars])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<void> insertUser(UsersCompanion user) async {}
  Future<User?> getUser(String userId) async => null;
  Future<List<User>> getAllUsers() async => [];
  Future<void> insertShop(ShopsCompanion shop) async {}
  Future<Shop?> getShop(String userId) async => null;
  Future<void> insertKycDocument(KycDocumentsCompanion kyc) async {}
  Future<KycDocument?> getKycDocument(String userId) async => null;
  Future<void> insertCar(CarsCompanion car) async {}
  Future<List<Car>> getUserCars(String userId) async => [];
  Future<List<Car>> getAllCars() async => [];
  Future<void> clearAllData() async {}
  Future<void> deleteCar(String carId) async {}
  void close() {}
}

drift.LazyDatabase _openConnection() {
  return drift.LazyDatabase(() async {
    throw UnsupportedError('Database not supported on web');
  });
}

