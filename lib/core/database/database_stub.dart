import 'package:drift/drift.dart';

part 'database_stub.g.dart';

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
  TextColumn get userId => text()();
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
  TextColumn get userId => text()();
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
  TextColumn get userId => text()();
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
  @override
  Future<void> close() async {}
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    throw UnsupportedError('Database not supported on web');
  });
}


