// Model representing a car entity captured in the Add Car flow

class Car {
  final String name;
  final String variant;
  final String yearOfManufacture;
  final String owner;
  final String color;
  final String model;
  final String fuelType;
  final String insurance;
  final String transmission;
  final String demandPrice; // keep as string to match text field formatting
  final String kmsDriven;
  final String mileage;
  final String tankCapacity;
  final List<String> imagePaths;
  final String seatType; // New field for seat type (2, 5, 7)
  final String licenseType; // New field for license type (Commercial, Non Commercial)
  final String state;
  final String city;
  final String pincode;
  final String dealerName; // New field for dealer/shop name
  final DateTime? createdAt;

  const Car({
    required this.name,
    required this.variant,
    required this.yearOfManufacture,
    required this.owner,
    required this.color,
    required this.model,
    required this.fuelType,
    required this.insurance,
    required this.transmission,
    required this.demandPrice,
    required this.kmsDriven,
    required this.mileage,
    required this.tankCapacity,
    required this.imagePaths,
    required this.seatType,
    required this.licenseType,
    this.state = '',
    this.city = '',
    this.pincode = '',
    this.dealerName = '',
    this.createdAt,
  });

  Car copyWith({
    String? name,
    String? variant,
    String? yearOfManufacture,
    String? owner,
    String? color,
    String? model,
    String? fuelType,
    String? insurance,
    String? transmission,
    String? demandPrice,
    String? kmsDriven,
    String? mileage,
    String? tankCapacity,
    List<String>? imagePaths,
    String? seatType,
    String? licenseType,
    String? state,
    String? city,
    String? pincode,
    String? dealerName,
    DateTime? createdAt,
  }) {
    return Car(
      name: name ?? this.name,
      variant: variant ?? this.variant,
      yearOfManufacture: yearOfManufacture ?? this.yearOfManufacture,
      owner: owner ?? this.owner,
      color: color ?? this.color,
      model: model ?? this.model,
      fuelType: fuelType ?? this.fuelType,
      insurance: insurance ?? this.insurance,
      transmission: transmission ?? this.transmission,
      demandPrice: demandPrice ?? this.demandPrice,
      kmsDriven: kmsDriven ?? this.kmsDriven,
      mileage: mileage ?? this.mileage,
      tankCapacity: tankCapacity ?? this.tankCapacity,
      imagePaths: imagePaths ?? this.imagePaths,
      seatType: seatType ?? this.seatType,
      licenseType: licenseType ?? this.licenseType,
      state: state ?? this.state,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      dealerName: dealerName ?? this.dealerName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'variant': variant,
      'yearOfManufacture': yearOfManufacture,
      'owner': owner,
      'color': color,
      'model': model,
      'fuelType': fuelType,
      'insurance': insurance,
      'transmission': transmission,
      'demandPrice': demandPrice,
      'kmsDriven': kmsDriven,
      'mileage': mileage,
      'tankCapacity': tankCapacity,
      'imagePaths': imagePaths,
      'seatType': seatType,
      'licenseType': licenseType,
      'state': state,
      'city': city,
      'pincode': pincode,
      'dealerName': dealerName,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'Car(name: $name, variant: $variant, dealerName: $dealerName, seatType: $seatType, licenseType: $licenseType, state: $state, city: $city, pincode: $pincode)';
}
