// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_stub.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with drift.TableInfo<$UsersTable, User> {
  @override
  final drift.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const drift.VerificationMeta _idMeta = const drift.VerificationMeta(
    'id',
  );
  @override
  late final drift.GeneratedColumn<String> id = drift.GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const drift.VerificationMeta _nameMeta = const drift.VerificationMeta(
    'name',
  );
  @override
  late final drift.GeneratedColumn<String> name = drift.GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const drift.VerificationMeta _emailMeta = const drift.VerificationMeta(
    'email',
  );
  @override
  late final drift.GeneratedColumn<String> email =
      drift.GeneratedColumn<String>(
        'email',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const drift.VerificationMeta _phoneMeta = const drift.VerificationMeta(
    'phone',
  );
  @override
  late final drift.GeneratedColumn<String> phone =
      drift.GeneratedColumn<String>(
        'phone',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const drift.VerificationMeta _genderMeta =
      const drift.VerificationMeta('gender');
  @override
  late final drift.GeneratedColumn<String> gender =
      drift.GeneratedColumn<String>(
        'gender',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const drift.VerificationMeta _avatarUrlMeta =
      const drift.VerificationMeta('avatarUrl');
  @override
  late final drift.GeneratedColumn<String> avatarUrl =
      drift.GeneratedColumn<String>(
        'avatar_url',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const drift.VerificationMeta _createdAtMeta =
      const drift.VerificationMeta('createdAt');
  @override
  late final drift.GeneratedColumn<DateTime> createdAt =
      drift.GeneratedColumn<DateTime>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const drift.VerificationMeta _updatedAtMeta =
      const drift.VerificationMeta('updatedAt');
  @override
  late final drift.GeneratedColumn<DateTime> updatedAt =
      drift.GeneratedColumn<DateTime>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<drift.GeneratedColumn> get $columns => [
    id,
    name,
    email,
    phone,
    gender,
    avatarUrl,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  drift.VerificationContext validateIntegrity(
    drift.Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = drift.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    } else if (isInserting) {
      context.missing(_genderMeta);
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<drift.GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      )!,
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends drift.DataClass implements drift.Insertable<User> {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String gender;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.gender,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    map['id'] = drift.Variable<String>(id);
    map['name'] = drift.Variable<String>(name);
    map['email'] = drift.Variable<String>(email);
    map['phone'] = drift.Variable<String>(phone);
    map['gender'] = drift.Variable<String>(gender);
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = drift.Variable<String>(avatarUrl);
    }
    map['created_at'] = drift.Variable<DateTime>(createdAt);
    map['updated_at'] = drift.Variable<DateTime>(updatedAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: drift.Value(id),
      name: drift.Value(name),
      email: drift.Value(email),
      phone: drift.Value(phone),
      gender: drift.Value(gender),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const drift.Value.absent()
          : drift.Value(avatarUrl),
      createdAt: drift.Value(createdAt),
      updatedAt: drift.Value(updatedAt),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String>(json['email']),
      phone: serializer.fromJson<String>(json['phone']),
      gender: serializer.fromJson<String>(json['gender']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String>(email),
      'phone': serializer.toJson<String>(phone),
      'gender': serializer.toJson<String>(gender),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? gender,
    drift.Value<String?> avatarUrl = const drift.Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => User(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    gender: gender ?? this.gender,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      gender: data.gender.present ? data.gender.value : this.gender,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('gender: $gender, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    email,
    phone,
    gender,
    avatarUrl,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.gender == this.gender &&
          other.avatarUrl == this.avatarUrl &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UsersCompanion extends drift.UpdateCompanion<User> {
  final drift.Value<String> id;
  final drift.Value<String> name;
  final drift.Value<String> email;
  final drift.Value<String> phone;
  final drift.Value<String> gender;
  final drift.Value<String?> avatarUrl;
  final drift.Value<DateTime> createdAt;
  final drift.Value<DateTime> updatedAt;
  final drift.Value<int> rowid;
  const UsersCompanion({
    this.id = const drift.Value.absent(),
    this.name = const drift.Value.absent(),
    this.email = const drift.Value.absent(),
    this.phone = const drift.Value.absent(),
    this.gender = const drift.Value.absent(),
    this.avatarUrl = const drift.Value.absent(),
    this.createdAt = const drift.Value.absent(),
    this.updatedAt = const drift.Value.absent(),
    this.rowid = const drift.Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String name,
    required String email,
    required String phone,
    required String gender,
    this.avatarUrl = const drift.Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const drift.Value.absent(),
  }) : id = drift.Value(id),
       name = drift.Value(name),
       email = drift.Value(email),
       phone = drift.Value(phone),
       gender = drift.Value(gender),
       createdAt = drift.Value(createdAt),
       updatedAt = drift.Value(updatedAt);
  static drift.Insertable<User> custom({
    drift.Expression<String>? id,
    drift.Expression<String>? name,
    drift.Expression<String>? email,
    drift.Expression<String>? phone,
    drift.Expression<String>? gender,
    drift.Expression<String>? avatarUrl,
    drift.Expression<DateTime>? createdAt,
    drift.Expression<DateTime>? updatedAt,
    drift.Expression<int>? rowid,
  }) {
    return drift.RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (gender != null) 'gender': gender,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    drift.Value<String>? id,
    drift.Value<String>? name,
    drift.Value<String>? email,
    drift.Value<String>? phone,
    drift.Value<String>? gender,
    drift.Value<String?>? avatarUrl,
    drift.Value<DateTime>? createdAt,
    drift.Value<DateTime>? updatedAt,
    drift.Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    if (id.present) {
      map['id'] = drift.Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = drift.Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = drift.Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = drift.Variable<String>(phone.value);
    }
    if (gender.present) {
      map['gender'] = drift.Variable<String>(gender.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = drift.Variable<String>(avatarUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = drift.Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = drift.Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = drift.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('gender: $gender, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShopsTable extends Shops with drift.TableInfo<$ShopsTable, Shop> {
  @override
  final drift.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShopsTable(this.attachedDatabase, [this._alias]);
  static const drift.VerificationMeta _idMeta = const drift.VerificationMeta(
    'id',
  );
  @override
  late final drift.GeneratedColumn<String> id = drift.GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const drift.VerificationMeta _userIdMeta =
      const drift.VerificationMeta('userId');
  @override
  late final drift.GeneratedColumn<String> userId =
      drift.GeneratedColumn<String>(
        'user_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const drift.VerificationMeta _shopNameMeta =
      const drift.VerificationMeta('shopName');
  @override
  late final drift.GeneratedColumn<String> shopName =
      drift.GeneratedColumn<String>(
        'shop_name',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const drift.VerificationMeta _ownerNameMeta =
      const drift.VerificationMeta('ownerName');
  @override
  late final drift.GeneratedColumn<String> ownerName =
      drift.GeneratedColumn<String>(
        'owner_name',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const drift.VerificationMeta _phoneMeta = const drift.VerificationMeta(
    'phone',
  );
  @override
  late final drift.GeneratedColumn<String> phone =
      drift.GeneratedColumn<String>(
        'phone',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const drift.VerificationMeta _emailMeta = const drift.VerificationMeta(
    'email',
  );
  @override
  late final drift.GeneratedColumn<String> email =
      drift.GeneratedColumn<String>(
        'email',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const drift.VerificationMeta _addressMeta =
      const drift.VerificationMeta('address');
  @override
  late final drift.GeneratedColumn<String> address =
      drift.GeneratedColumn<String>(
        'address',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const drift.VerificationMeta _cityMeta = const drift.VerificationMeta(
    'city',
  );
  @override
  late final drift.GeneratedColumn<String> city = drift.GeneratedColumn<String>(
    'city',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const drift.VerificationMeta _stateMeta = const drift.VerificationMeta(
    'state',
  );
  @override
  late final drift.GeneratedColumn<String> state =
      drift.GeneratedColumn<String>(
        'state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const drift.VerificationMeta _pincodeMeta =
      const drift.VerificationMeta('pincode');
  @override
  late final drift.GeneratedColumn<String> pincode =
      drift.GeneratedColumn<String>(
        'pincode',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const drift.VerificationMeta _logoUrlMeta =
      const drift.VerificationMeta('logoUrl');
  @override
  late final drift.GeneratedColumn<String> logoUrl =
      drift.GeneratedColumn<String>(
        'logo_url',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const drift.VerificationMeta _createdAtMeta =
      const drift.VerificationMeta('createdAt');
  @override
  late final drift.GeneratedColumn<DateTime> createdAt =
      drift.GeneratedColumn<DateTime>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const drift.VerificationMeta _updatedAtMeta =
      const drift.VerificationMeta('updatedAt');
  @override
  late final drift.GeneratedColumn<DateTime> updatedAt =
      drift.GeneratedColumn<DateTime>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<drift.GeneratedColumn> get $columns => [
    id,
    userId,
    shopName,
    ownerName,
    phone,
    email,
    address,
    city,
    state,
    pincode,
    logoUrl,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shops';
  @override
  drift.VerificationContext validateIntegrity(
    drift.Insertable<Shop> instance, {
    bool isInserting = false,
  }) {
    final context = drift.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('shop_name')) {
      context.handle(
        _shopNameMeta,
        shopName.isAcceptableOrUnknown(data['shop_name']!, _shopNameMeta),
      );
    } else if (isInserting) {
      context.missing(_shopNameMeta);
    }
    if (data.containsKey('owner_name')) {
      context.handle(
        _ownerNameMeta,
        ownerName.isAcceptableOrUnknown(data['owner_name']!, _ownerNameMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerNameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
      );
    } else if (isInserting) {
      context.missing(_cityMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('pincode')) {
      context.handle(
        _pincodeMeta,
        pincode.isAcceptableOrUnknown(data['pincode']!, _pincodeMeta),
      );
    } else if (isInserting) {
      context.missing(_pincodeMeta);
    }
    if (data.containsKey('logo_url')) {
      context.handle(
        _logoUrlMeta,
        logoUrl.isAcceptableOrUnknown(data['logo_url']!, _logoUrlMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<drift.GeneratedColumn> get $primaryKey => {id};
  @override
  Shop map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Shop(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      shopName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shop_name'],
      )!,
      ownerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      pincode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pincode'],
      )!,
      logoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logo_url'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ShopsTable createAlias(String alias) {
    return $ShopsTable(attachedDatabase, alias);
  }
}

class Shop extends drift.DataClass implements drift.Insertable<Shop> {
  final String id;
  final String userId;
  final String shopName;
  final String ownerName;
  final String phone;
  final String email;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String? logoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Shop({
    required this.id,
    required this.userId,
    required this.shopName,
    required this.ownerName,
    required this.phone,
    required this.email,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    this.logoUrl,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    map['id'] = drift.Variable<String>(id);
    map['user_id'] = drift.Variable<String>(userId);
    map['shop_name'] = drift.Variable<String>(shopName);
    map['owner_name'] = drift.Variable<String>(ownerName);
    map['phone'] = drift.Variable<String>(phone);
    map['email'] = drift.Variable<String>(email);
    map['address'] = drift.Variable<String>(address);
    map['city'] = drift.Variable<String>(city);
    map['state'] = drift.Variable<String>(state);
    map['pincode'] = drift.Variable<String>(pincode);
    if (!nullToAbsent || logoUrl != null) {
      map['logo_url'] = drift.Variable<String>(logoUrl);
    }
    map['created_at'] = drift.Variable<DateTime>(createdAt);
    map['updated_at'] = drift.Variable<DateTime>(updatedAt);
    return map;
  }

  ShopsCompanion toCompanion(bool nullToAbsent) {
    return ShopsCompanion(
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
      logoUrl: logoUrl == null && nullToAbsent
          ? const drift.Value.absent()
          : drift.Value(logoUrl),
      createdAt: drift.Value(createdAt),
      updatedAt: drift.Value(updatedAt),
    );
  }

  factory Shop.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return Shop(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      shopName: serializer.fromJson<String>(json['shopName']),
      ownerName: serializer.fromJson<String>(json['ownerName']),
      phone: serializer.fromJson<String>(json['phone']),
      email: serializer.fromJson<String>(json['email']),
      address: serializer.fromJson<String>(json['address']),
      city: serializer.fromJson<String>(json['city']),
      state: serializer.fromJson<String>(json['state']),
      pincode: serializer.fromJson<String>(json['pincode']),
      logoUrl: serializer.fromJson<String?>(json['logoUrl']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'shopName': serializer.toJson<String>(shopName),
      'ownerName': serializer.toJson<String>(ownerName),
      'phone': serializer.toJson<String>(phone),
      'email': serializer.toJson<String>(email),
      'address': serializer.toJson<String>(address),
      'city': serializer.toJson<String>(city),
      'state': serializer.toJson<String>(state),
      'pincode': serializer.toJson<String>(pincode),
      'logoUrl': serializer.toJson<String?>(logoUrl),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Shop copyWith({
    String? id,
    String? userId,
    String? shopName,
    String? ownerName,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? state,
    String? pincode,
    drift.Value<String?> logoUrl = const drift.Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Shop(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    shopName: shopName ?? this.shopName,
    ownerName: ownerName ?? this.ownerName,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    address: address ?? this.address,
    city: city ?? this.city,
    state: state ?? this.state,
    pincode: pincode ?? this.pincode,
    logoUrl: logoUrl.present ? logoUrl.value : this.logoUrl,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Shop copyWithCompanion(ShopsCompanion data) {
    return Shop(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      shopName: data.shopName.present ? data.shopName.value : this.shopName,
      ownerName: data.ownerName.present ? data.ownerName.value : this.ownerName,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      address: data.address.present ? data.address.value : this.address,
      city: data.city.present ? data.city.value : this.city,
      state: data.state.present ? data.state.value : this.state,
      pincode: data.pincode.present ? data.pincode.value : this.pincode,
      logoUrl: data.logoUrl.present ? data.logoUrl.value : this.logoUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Shop(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('shopName: $shopName, ')
          ..write('ownerName: $ownerName, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('city: $city, ')
          ..write('state: $state, ')
          ..write('pincode: $pincode, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    shopName,
    ownerName,
    phone,
    email,
    address,
    city,
    state,
    pincode,
    logoUrl,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Shop &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.shopName == this.shopName &&
          other.ownerName == this.ownerName &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.address == this.address &&
          other.city == this.city &&
          other.state == this.state &&
          other.pincode == this.pincode &&
          other.logoUrl == this.logoUrl &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ShopsCompanion extends drift.UpdateCompanion<Shop> {
  final drift.Value<String> id;
  final drift.Value<String> userId;
  final drift.Value<String> shopName;
  final drift.Value<String> ownerName;
  final drift.Value<String> phone;
  final drift.Value<String> email;
  final drift.Value<String> address;
  final drift.Value<String> city;
  final drift.Value<String> state;
  final drift.Value<String> pincode;
  final drift.Value<String?> logoUrl;
  final drift.Value<DateTime> createdAt;
  final drift.Value<DateTime> updatedAt;
  final drift.Value<int> rowid;
  const ShopsCompanion({
    this.id = const drift.Value.absent(),
    this.userId = const drift.Value.absent(),
    this.shopName = const drift.Value.absent(),
    this.ownerName = const drift.Value.absent(),
    this.phone = const drift.Value.absent(),
    this.email = const drift.Value.absent(),
    this.address = const drift.Value.absent(),
    this.city = const drift.Value.absent(),
    this.state = const drift.Value.absent(),
    this.pincode = const drift.Value.absent(),
    this.logoUrl = const drift.Value.absent(),
    this.createdAt = const drift.Value.absent(),
    this.updatedAt = const drift.Value.absent(),
    this.rowid = const drift.Value.absent(),
  });
  ShopsCompanion.insert({
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
    this.logoUrl = const drift.Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const drift.Value.absent(),
  }) : id = drift.Value(id),
       userId = drift.Value(userId),
       shopName = drift.Value(shopName),
       ownerName = drift.Value(ownerName),
       phone = drift.Value(phone),
       email = drift.Value(email),
       address = drift.Value(address),
       city = drift.Value(city),
       state = drift.Value(state),
       pincode = drift.Value(pincode),
       createdAt = drift.Value(createdAt),
       updatedAt = drift.Value(updatedAt);
  static drift.Insertable<Shop> custom({
    drift.Expression<String>? id,
    drift.Expression<String>? userId,
    drift.Expression<String>? shopName,
    drift.Expression<String>? ownerName,
    drift.Expression<String>? phone,
    drift.Expression<String>? email,
    drift.Expression<String>? address,
    drift.Expression<String>? city,
    drift.Expression<String>? state,
    drift.Expression<String>? pincode,
    drift.Expression<String>? logoUrl,
    drift.Expression<DateTime>? createdAt,
    drift.Expression<DateTime>? updatedAt,
    drift.Expression<int>? rowid,
  }) {
    return drift.RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (shopName != null) 'shop_name': shopName,
      if (ownerName != null) 'owner_name': ownerName,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (pincode != null) 'pincode': pincode,
      if (logoUrl != null) 'logo_url': logoUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShopsCompanion copyWith({
    drift.Value<String>? id,
    drift.Value<String>? userId,
    drift.Value<String>? shopName,
    drift.Value<String>? ownerName,
    drift.Value<String>? phone,
    drift.Value<String>? email,
    drift.Value<String>? address,
    drift.Value<String>? city,
    drift.Value<String>? state,
    drift.Value<String>? pincode,
    drift.Value<String?>? logoUrl,
    drift.Value<DateTime>? createdAt,
    drift.Value<DateTime>? updatedAt,
    drift.Value<int>? rowid,
  }) {
    return ShopsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      shopName: shopName ?? this.shopName,
      ownerName: ownerName ?? this.ownerName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      logoUrl: logoUrl ?? this.logoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    if (id.present) {
      map['id'] = drift.Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = drift.Variable<String>(userId.value);
    }
    if (shopName.present) {
      map['shop_name'] = drift.Variable<String>(shopName.value);
    }
    if (ownerName.present) {
      map['owner_name'] = drift.Variable<String>(ownerName.value);
    }
    if (phone.present) {
      map['phone'] = drift.Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = drift.Variable<String>(email.value);
    }
    if (address.present) {
      map['address'] = drift.Variable<String>(address.value);
    }
    if (city.present) {
      map['city'] = drift.Variable<String>(city.value);
    }
    if (state.present) {
      map['state'] = drift.Variable<String>(state.value);
    }
    if (pincode.present) {
      map['pincode'] = drift.Variable<String>(pincode.value);
    }
    if (logoUrl.present) {
      map['logo_url'] = drift.Variable<String>(logoUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = drift.Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = drift.Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = drift.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShopsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('shopName: $shopName, ')
          ..write('ownerName: $ownerName, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('city: $city, ')
          ..write('state: $state, ')
          ..write('pincode: $pincode, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KycDocumentsTable extends KycDocuments
    with drift.TableInfo<$KycDocumentsTable, KycDocument> {
  @override
  final drift.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KycDocumentsTable(this.attachedDatabase, [this._alias]);
  static const drift.VerificationMeta _idMeta = const drift.VerificationMeta(
    'id',
  );
  @override
  late final drift.GeneratedColumn<String> id = drift.GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const drift.VerificationMeta _userIdMeta =
      const drift.VerificationMeta('userId');
  @override
  late final drift.GeneratedColumn<String> userId =
      drift.GeneratedColumn<String>(
        'user_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const drift.VerificationMeta _panPathMeta =
      const drift.VerificationMeta('panPath');
  @override
  late final drift.GeneratedColumn<String> panPath =
      drift.GeneratedColumn<String>(
        'pan_path',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const drift.VerificationMeta _aadhaarPathMeta =
      const drift.VerificationMeta('aadhaarPath');
  @override
  late final drift.GeneratedColumn<String> aadhaarPath =
      drift.GeneratedColumn<String>(
        'aadhaar_path',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const drift.VerificationMeta _addressProofPathMeta =
      const drift.VerificationMeta('addressProofPath');
  @override
  late final drift.GeneratedColumn<String> addressProofPath =
      drift.GeneratedColumn<String>(
        'address_proof_path',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const drift.VerificationMeta _isVerifiedMeta =
      const drift.VerificationMeta('isVerified');
  @override
  late final drift.GeneratedColumn<bool> isVerified =
      drift.GeneratedColumn<bool>(
        'is_verified',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_verified" IN (0, 1))',
        ),
        defaultValue: const drift.Constant(false),
      );
  static const drift.VerificationMeta _createdAtMeta =
      const drift.VerificationMeta('createdAt');
  @override
  late final drift.GeneratedColumn<DateTime> createdAt =
      drift.GeneratedColumn<DateTime>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const drift.VerificationMeta _updatedAtMeta =
      const drift.VerificationMeta('updatedAt');
  @override
  late final drift.GeneratedColumn<DateTime> updatedAt =
      drift.GeneratedColumn<DateTime>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<drift.GeneratedColumn> get $columns => [
    id,
    userId,
    panPath,
    aadhaarPath,
    addressProofPath,
    isVerified,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kyc_documents';
  @override
  drift.VerificationContext validateIntegrity(
    drift.Insertable<KycDocument> instance, {
    bool isInserting = false,
  }) {
    final context = drift.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('pan_path')) {
      context.handle(
        _panPathMeta,
        panPath.isAcceptableOrUnknown(data['pan_path']!, _panPathMeta),
      );
    }
    if (data.containsKey('aadhaar_path')) {
      context.handle(
        _aadhaarPathMeta,
        aadhaarPath.isAcceptableOrUnknown(
          data['aadhaar_path']!,
          _aadhaarPathMeta,
        ),
      );
    }
    if (data.containsKey('address_proof_path')) {
      context.handle(
        _addressProofPathMeta,
        addressProofPath.isAcceptableOrUnknown(
          data['address_proof_path']!,
          _addressProofPathMeta,
        ),
      );
    }
    if (data.containsKey('is_verified')) {
      context.handle(
        _isVerifiedMeta,
        isVerified.isAcceptableOrUnknown(data['is_verified']!, _isVerifiedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<drift.GeneratedColumn> get $primaryKey => {id};
  @override
  KycDocument map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KycDocument(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      panPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pan_path'],
      ),
      aadhaarPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aadhaar_path'],
      ),
      addressProofPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address_proof_path'],
      ),
      isVerified: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_verified'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $KycDocumentsTable createAlias(String alias) {
    return $KycDocumentsTable(attachedDatabase, alias);
  }
}

class KycDocument extends drift.DataClass
    implements drift.Insertable<KycDocument> {
  final String id;
  final String userId;
  final String? panPath;
  final String? aadhaarPath;
  final String? addressProofPath;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  const KycDocument({
    required this.id,
    required this.userId,
    this.panPath,
    this.aadhaarPath,
    this.addressProofPath,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    map['id'] = drift.Variable<String>(id);
    map['user_id'] = drift.Variable<String>(userId);
    if (!nullToAbsent || panPath != null) {
      map['pan_path'] = drift.Variable<String>(panPath);
    }
    if (!nullToAbsent || aadhaarPath != null) {
      map['aadhaar_path'] = drift.Variable<String>(aadhaarPath);
    }
    if (!nullToAbsent || addressProofPath != null) {
      map['address_proof_path'] = drift.Variable<String>(addressProofPath);
    }
    map['is_verified'] = drift.Variable<bool>(isVerified);
    map['created_at'] = drift.Variable<DateTime>(createdAt);
    map['updated_at'] = drift.Variable<DateTime>(updatedAt);
    return map;
  }

  KycDocumentsCompanion toCompanion(bool nullToAbsent) {
    return KycDocumentsCompanion(
      id: drift.Value(id),
      userId: drift.Value(userId),
      panPath: panPath == null && nullToAbsent
          ? const drift.Value.absent()
          : drift.Value(panPath),
      aadhaarPath: aadhaarPath == null && nullToAbsent
          ? const drift.Value.absent()
          : drift.Value(aadhaarPath),
      addressProofPath: addressProofPath == null && nullToAbsent
          ? const drift.Value.absent()
          : drift.Value(addressProofPath),
      isVerified: drift.Value(isVerified),
      createdAt: drift.Value(createdAt),
      updatedAt: drift.Value(updatedAt),
    );
  }

  factory KycDocument.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return KycDocument(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      panPath: serializer.fromJson<String?>(json['panPath']),
      aadhaarPath: serializer.fromJson<String?>(json['aadhaarPath']),
      addressProofPath: serializer.fromJson<String?>(json['addressProofPath']),
      isVerified: serializer.fromJson<bool>(json['isVerified']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'panPath': serializer.toJson<String?>(panPath),
      'aadhaarPath': serializer.toJson<String?>(aadhaarPath),
      'addressProofPath': serializer.toJson<String?>(addressProofPath),
      'isVerified': serializer.toJson<bool>(isVerified),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  KycDocument copyWith({
    String? id,
    String? userId,
    drift.Value<String?> panPath = const drift.Value.absent(),
    drift.Value<String?> aadhaarPath = const drift.Value.absent(),
    drift.Value<String?> addressProofPath = const drift.Value.absent(),
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => KycDocument(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    panPath: panPath.present ? panPath.value : this.panPath,
    aadhaarPath: aadhaarPath.present ? aadhaarPath.value : this.aadhaarPath,
    addressProofPath: addressProofPath.present
        ? addressProofPath.value
        : this.addressProofPath,
    isVerified: isVerified ?? this.isVerified,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  KycDocument copyWithCompanion(KycDocumentsCompanion data) {
    return KycDocument(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      panPath: data.panPath.present ? data.panPath.value : this.panPath,
      aadhaarPath: data.aadhaarPath.present
          ? data.aadhaarPath.value
          : this.aadhaarPath,
      addressProofPath: data.addressProofPath.present
          ? data.addressProofPath.value
          : this.addressProofPath,
      isVerified: data.isVerified.present
          ? data.isVerified.value
          : this.isVerified,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KycDocument(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('panPath: $panPath, ')
          ..write('aadhaarPath: $aadhaarPath, ')
          ..write('addressProofPath: $addressProofPath, ')
          ..write('isVerified: $isVerified, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    panPath,
    aadhaarPath,
    addressProofPath,
    isVerified,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KycDocument &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.panPath == this.panPath &&
          other.aadhaarPath == this.aadhaarPath &&
          other.addressProofPath == this.addressProofPath &&
          other.isVerified == this.isVerified &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class KycDocumentsCompanion extends drift.UpdateCompanion<KycDocument> {
  final drift.Value<String> id;
  final drift.Value<String> userId;
  final drift.Value<String?> panPath;
  final drift.Value<String?> aadhaarPath;
  final drift.Value<String?> addressProofPath;
  final drift.Value<bool> isVerified;
  final drift.Value<DateTime> createdAt;
  final drift.Value<DateTime> updatedAt;
  final drift.Value<int> rowid;
  const KycDocumentsCompanion({
    this.id = const drift.Value.absent(),
    this.userId = const drift.Value.absent(),
    this.panPath = const drift.Value.absent(),
    this.aadhaarPath = const drift.Value.absent(),
    this.addressProofPath = const drift.Value.absent(),
    this.isVerified = const drift.Value.absent(),
    this.createdAt = const drift.Value.absent(),
    this.updatedAt = const drift.Value.absent(),
    this.rowid = const drift.Value.absent(),
  });
  KycDocumentsCompanion.insert({
    required String id,
    required String userId,
    this.panPath = const drift.Value.absent(),
    this.aadhaarPath = const drift.Value.absent(),
    this.addressProofPath = const drift.Value.absent(),
    this.isVerified = const drift.Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const drift.Value.absent(),
  }) : id = drift.Value(id),
       userId = drift.Value(userId),
       createdAt = drift.Value(createdAt),
       updatedAt = drift.Value(updatedAt);
  static drift.Insertable<KycDocument> custom({
    drift.Expression<String>? id,
    drift.Expression<String>? userId,
    drift.Expression<String>? panPath,
    drift.Expression<String>? aadhaarPath,
    drift.Expression<String>? addressProofPath,
    drift.Expression<bool>? isVerified,
    drift.Expression<DateTime>? createdAt,
    drift.Expression<DateTime>? updatedAt,
    drift.Expression<int>? rowid,
  }) {
    return drift.RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (panPath != null) 'pan_path': panPath,
      if (aadhaarPath != null) 'aadhaar_path': aadhaarPath,
      if (addressProofPath != null) 'address_proof_path': addressProofPath,
      if (isVerified != null) 'is_verified': isVerified,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KycDocumentsCompanion copyWith({
    drift.Value<String>? id,
    drift.Value<String>? userId,
    drift.Value<String?>? panPath,
    drift.Value<String?>? aadhaarPath,
    drift.Value<String?>? addressProofPath,
    drift.Value<bool>? isVerified,
    drift.Value<DateTime>? createdAt,
    drift.Value<DateTime>? updatedAt,
    drift.Value<int>? rowid,
  }) {
    return KycDocumentsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      panPath: panPath ?? this.panPath,
      aadhaarPath: aadhaarPath ?? this.aadhaarPath,
      addressProofPath: addressProofPath ?? this.addressProofPath,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    if (id.present) {
      map['id'] = drift.Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = drift.Variable<String>(userId.value);
    }
    if (panPath.present) {
      map['pan_path'] = drift.Variable<String>(panPath.value);
    }
    if (aadhaarPath.present) {
      map['aadhaar_path'] = drift.Variable<String>(aadhaarPath.value);
    }
    if (addressProofPath.present) {
      map['address_proof_path'] = drift.Variable<String>(
        addressProofPath.value,
      );
    }
    if (isVerified.present) {
      map['is_verified'] = drift.Variable<bool>(isVerified.value);
    }
    if (createdAt.present) {
      map['created_at'] = drift.Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = drift.Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = drift.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KycDocumentsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('panPath: $panPath, ')
          ..write('aadhaarPath: $aadhaarPath, ')
          ..write('addressProofPath: $addressProofPath, ')
          ..write('isVerified: $isVerified, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CarsTable extends Cars with drift.TableInfo<$CarsTable, Car> {
  @override
  final drift.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CarsTable(this.attachedDatabase, [this._alias]);
  static const drift.VerificationMeta _idMeta = const drift.VerificationMeta(
    'id',
  );
  @override
  late final drift.GeneratedColumn<String> id = drift.GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const drift.VerificationMeta _userIdMeta =
      const drift.VerificationMeta('userId');
  @override
  late final drift.GeneratedColumn<String> userId =
      drift.GeneratedColumn<String>(
        'user_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const drift.VerificationMeta _makeMeta = const drift.VerificationMeta(
    'make',
  );
  @override
  late final drift.GeneratedColumn<String> make = drift.GeneratedColumn<String>(
    'make',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const drift.VerificationMeta _modelMeta = const drift.VerificationMeta(
    'model',
  );
  @override
  late final drift.GeneratedColumn<String> model =
      drift.GeneratedColumn<String>(
        'model',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const drift.VerificationMeta _yearMeta = const drift.VerificationMeta(
    'year',
  );
  @override
  late final drift.GeneratedColumn<String> year = drift.GeneratedColumn<String>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const drift.VerificationMeta _priceMeta = const drift.VerificationMeta(
    'price',
  );
  @override
  late final drift.GeneratedColumn<String> price =
      drift.GeneratedColumn<String>(
        'price',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const drift.VerificationMeta _imageUrlMeta =
      const drift.VerificationMeta('imageUrl');
  @override
  late final drift.GeneratedColumn<String> imageUrl =
      drift.GeneratedColumn<String>(
        'image_url',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const drift.VerificationMeta _descriptionMeta =
      const drift.VerificationMeta('description');
  @override
  late final drift.GeneratedColumn<String> description =
      drift.GeneratedColumn<String>(
        'description',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const drift.VerificationMeta _isAvailableMeta =
      const drift.VerificationMeta('isAvailable');
  @override
  late final drift.GeneratedColumn<bool> isAvailable =
      drift.GeneratedColumn<bool>(
        'is_available',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_available" IN (0, 1))',
        ),
        defaultValue: const drift.Constant(true),
      );
  static const drift.VerificationMeta _createdAtMeta =
      const drift.VerificationMeta('createdAt');
  @override
  late final drift.GeneratedColumn<DateTime> createdAt =
      drift.GeneratedColumn<DateTime>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const drift.VerificationMeta _updatedAtMeta =
      const drift.VerificationMeta('updatedAt');
  @override
  late final drift.GeneratedColumn<DateTime> updatedAt =
      drift.GeneratedColumn<DateTime>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<drift.GeneratedColumn> get $columns => [
    id,
    userId,
    make,
    model,
    year,
    price,
    imageUrl,
    description,
    isAvailable,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cars';
  @override
  drift.VerificationContext validateIntegrity(
    drift.Insertable<Car> instance, {
    bool isInserting = false,
  }) {
    final context = drift.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('make')) {
      context.handle(
        _makeMeta,
        make.isAcceptableOrUnknown(data['make']!, _makeMeta),
      );
    } else if (isInserting) {
      context.missing(_makeMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('is_available')) {
      context.handle(
        _isAvailableMeta,
        isAvailable.isAcceptableOrUnknown(
          data['is_available']!,
          _isAvailableMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<drift.GeneratedColumn> get $primaryKey => {id};
  @override
  Car map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Car(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      make: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}make'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}year'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}price'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      isAvailable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_available'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CarsTable createAlias(String alias) {
    return $CarsTable(attachedDatabase, alias);
  }
}

class Car extends drift.DataClass implements drift.Insertable<Car> {
  final String id;
  final String userId;
  final String make;
  final String model;
  final String year;
  final String price;
  final String? imageUrl;
  final String? description;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Car({
    required this.id,
    required this.userId,
    required this.make,
    required this.model,
    required this.year,
    required this.price,
    this.imageUrl,
    this.description,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    map['id'] = drift.Variable<String>(id);
    map['user_id'] = drift.Variable<String>(userId);
    map['make'] = drift.Variable<String>(make);
    map['model'] = drift.Variable<String>(model);
    map['year'] = drift.Variable<String>(year);
    map['price'] = drift.Variable<String>(price);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = drift.Variable<String>(imageUrl);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = drift.Variable<String>(description);
    }
    map['is_available'] = drift.Variable<bool>(isAvailable);
    map['created_at'] = drift.Variable<DateTime>(createdAt);
    map['updated_at'] = drift.Variable<DateTime>(updatedAt);
    return map;
  }

  CarsCompanion toCompanion(bool nullToAbsent) {
    return CarsCompanion(
      id: drift.Value(id),
      userId: drift.Value(userId),
      make: drift.Value(make),
      model: drift.Value(model),
      year: drift.Value(year),
      price: drift.Value(price),
      imageUrl: imageUrl == null && nullToAbsent
          ? const drift.Value.absent()
          : drift.Value(imageUrl),
      description: description == null && nullToAbsent
          ? const drift.Value.absent()
          : drift.Value(description),
      isAvailable: drift.Value(isAvailable),
      createdAt: drift.Value(createdAt),
      updatedAt: drift.Value(updatedAt),
    );
  }

  factory Car.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return Car(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      make: serializer.fromJson<String>(json['make']),
      model: serializer.fromJson<String>(json['model']),
      year: serializer.fromJson<String>(json['year']),
      price: serializer.fromJson<String>(json['price']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      description: serializer.fromJson<String?>(json['description']),
      isAvailable: serializer.fromJson<bool>(json['isAvailable']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'make': serializer.toJson<String>(make),
      'model': serializer.toJson<String>(model),
      'year': serializer.toJson<String>(year),
      'price': serializer.toJson<String>(price),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'description': serializer.toJson<String?>(description),
      'isAvailable': serializer.toJson<bool>(isAvailable),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Car copyWith({
    String? id,
    String? userId,
    String? make,
    String? model,
    String? year,
    String? price,
    drift.Value<String?> imageUrl = const drift.Value.absent(),
    drift.Value<String?> description = const drift.Value.absent(),
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Car(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    make: make ?? this.make,
    model: model ?? this.model,
    year: year ?? this.year,
    price: price ?? this.price,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    description: description.present ? description.value : this.description,
    isAvailable: isAvailable ?? this.isAvailable,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Car copyWithCompanion(CarsCompanion data) {
    return Car(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      make: data.make.present ? data.make.value : this.make,
      model: data.model.present ? data.model.value : this.model,
      year: data.year.present ? data.year.value : this.year,
      price: data.price.present ? data.price.value : this.price,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      description: data.description.present
          ? data.description.value
          : this.description,
      isAvailable: data.isAvailable.present
          ? data.isAvailable.value
          : this.isAvailable,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Car(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('make: $make, ')
          ..write('model: $model, ')
          ..write('year: $year, ')
          ..write('price: $price, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('description: $description, ')
          ..write('isAvailable: $isAvailable, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    make,
    model,
    year,
    price,
    imageUrl,
    description,
    isAvailable,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Car &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.make == this.make &&
          other.model == this.model &&
          other.year == this.year &&
          other.price == this.price &&
          other.imageUrl == this.imageUrl &&
          other.description == this.description &&
          other.isAvailable == this.isAvailable &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CarsCompanion extends drift.UpdateCompanion<Car> {
  final drift.Value<String> id;
  final drift.Value<String> userId;
  final drift.Value<String> make;
  final drift.Value<String> model;
  final drift.Value<String> year;
  final drift.Value<String> price;
  final drift.Value<String?> imageUrl;
  final drift.Value<String?> description;
  final drift.Value<bool> isAvailable;
  final drift.Value<DateTime> createdAt;
  final drift.Value<DateTime> updatedAt;
  final drift.Value<int> rowid;
  const CarsCompanion({
    this.id = const drift.Value.absent(),
    this.userId = const drift.Value.absent(),
    this.make = const drift.Value.absent(),
    this.model = const drift.Value.absent(),
    this.year = const drift.Value.absent(),
    this.price = const drift.Value.absent(),
    this.imageUrl = const drift.Value.absent(),
    this.description = const drift.Value.absent(),
    this.isAvailable = const drift.Value.absent(),
    this.createdAt = const drift.Value.absent(),
    this.updatedAt = const drift.Value.absent(),
    this.rowid = const drift.Value.absent(),
  });
  CarsCompanion.insert({
    required String id,
    required String userId,
    required String make,
    required String model,
    required String year,
    required String price,
    this.imageUrl = const drift.Value.absent(),
    this.description = const drift.Value.absent(),
    this.isAvailable = const drift.Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const drift.Value.absent(),
  }) : id = drift.Value(id),
       userId = drift.Value(userId),
       make = drift.Value(make),
       model = drift.Value(model),
       year = drift.Value(year),
       price = drift.Value(price),
       createdAt = drift.Value(createdAt),
       updatedAt = drift.Value(updatedAt);
  static drift.Insertable<Car> custom({
    drift.Expression<String>? id,
    drift.Expression<String>? userId,
    drift.Expression<String>? make,
    drift.Expression<String>? model,
    drift.Expression<String>? year,
    drift.Expression<String>? price,
    drift.Expression<String>? imageUrl,
    drift.Expression<String>? description,
    drift.Expression<bool>? isAvailable,
    drift.Expression<DateTime>? createdAt,
    drift.Expression<DateTime>? updatedAt,
    drift.Expression<int>? rowid,
  }) {
    return drift.RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (make != null) 'make': make,
      if (model != null) 'model': model,
      if (year != null) 'year': year,
      if (price != null) 'price': price,
      if (imageUrl != null) 'image_url': imageUrl,
      if (description != null) 'description': description,
      if (isAvailable != null) 'is_available': isAvailable,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CarsCompanion copyWith({
    drift.Value<String>? id,
    drift.Value<String>? userId,
    drift.Value<String>? make,
    drift.Value<String>? model,
    drift.Value<String>? year,
    drift.Value<String>? price,
    drift.Value<String?>? imageUrl,
    drift.Value<String?>? description,
    drift.Value<bool>? isAvailable,
    drift.Value<DateTime>? createdAt,
    drift.Value<DateTime>? updatedAt,
    drift.Value<int>? rowid,
  }) {
    return CarsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    if (id.present) {
      map['id'] = drift.Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = drift.Variable<String>(userId.value);
    }
    if (make.present) {
      map['make'] = drift.Variable<String>(make.value);
    }
    if (model.present) {
      map['model'] = drift.Variable<String>(model.value);
    }
    if (year.present) {
      map['year'] = drift.Variable<String>(year.value);
    }
    if (price.present) {
      map['price'] = drift.Variable<String>(price.value);
    }
    if (imageUrl.present) {
      map['image_url'] = drift.Variable<String>(imageUrl.value);
    }
    if (description.present) {
      map['description'] = drift.Variable<String>(description.value);
    }
    if (isAvailable.present) {
      map['is_available'] = drift.Variable<bool>(isAvailable.value);
    }
    if (createdAt.present) {
      map['created_at'] = drift.Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = drift.Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = drift.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CarsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('make: $make, ')
          ..write('model: $model, ')
          ..write('year: $year, ')
          ..write('price: $price, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('description: $description, ')
          ..write('isAvailable: $isAvailable, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends drift.GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $ShopsTable shops = $ShopsTable(this);
  late final $KycDocumentsTable kycDocuments = $KycDocumentsTable(this);
  late final $CarsTable cars = $CarsTable(this);
  @override
  Iterable<drift.TableInfo<drift.Table, Object?>> get allTables =>
      allSchemaEntities.whereType<drift.TableInfo<drift.Table, Object?>>();
  @override
  List<drift.DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    shops,
    kycDocuments,
    cars,
  ];
}

typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      required String id,
      required String name,
      required String email,
      required String phone,
      required String gender,
      drift.Value<String?> avatarUrl,
      required DateTime createdAt,
      required DateTime updatedAt,
      drift.Value<int> rowid,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      drift.Value<String> id,
      drift.Value<String> name,
      drift.Value<String> email,
      drift.Value<String> phone,
      drift.Value<String> gender,
      drift.Value<String?> avatarUrl,
      drift.Value<DateTime> createdAt,
      drift.Value<DateTime> updatedAt,
      drift.Value<int> rowid,
    });

class $$UsersTableFilterComposer
    extends drift.Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => drift.ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer
    extends drift.Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => drift.ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends drift.Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  drift.GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  drift.GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  drift.GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  drift.GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  drift.GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  drift.GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  drift.GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UsersTableTableManager
    extends
        drift.RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, drift.BaseReferences<_$AppDatabase, $UsersTable, User>),
          User,
          drift.PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        drift.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                drift.Value<String> id = const drift.Value.absent(),
                drift.Value<String> name = const drift.Value.absent(),
                drift.Value<String> email = const drift.Value.absent(),
                drift.Value<String> phone = const drift.Value.absent(),
                drift.Value<String> gender = const drift.Value.absent(),
                drift.Value<String?> avatarUrl = const drift.Value.absent(),
                drift.Value<DateTime> createdAt = const drift.Value.absent(),
                drift.Value<DateTime> updatedAt = const drift.Value.absent(),
                drift.Value<int> rowid = const drift.Value.absent(),
              }) => UsersCompanion(
                id: id,
                name: name,
                email: email,
                phone: phone,
                gender: gender,
                avatarUrl: avatarUrl,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String email,
                required String phone,
                required String gender,
                drift.Value<String?> avatarUrl = const drift.Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                drift.Value<int> rowid = const drift.Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                name: name,
                email: email,
                phone: phone,
                gender: gender,
                avatarUrl: avatarUrl,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (e.readTable(table), drift.BaseReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    drift.ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, drift.BaseReferences<_$AppDatabase, $UsersTable, User>),
      User,
      drift.PrefetchHooks Function()
    >;
typedef $$ShopsTableCreateCompanionBuilder =
    ShopsCompanion Function({
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
      drift.Value<String?> logoUrl,
      required DateTime createdAt,
      required DateTime updatedAt,
      drift.Value<int> rowid,
    });
typedef $$ShopsTableUpdateCompanionBuilder =
    ShopsCompanion Function({
      drift.Value<String> id,
      drift.Value<String> userId,
      drift.Value<String> shopName,
      drift.Value<String> ownerName,
      drift.Value<String> phone,
      drift.Value<String> email,
      drift.Value<String> address,
      drift.Value<String> city,
      drift.Value<String> state,
      drift.Value<String> pincode,
      drift.Value<String?> logoUrl,
      drift.Value<DateTime> createdAt,
      drift.Value<DateTime> updatedAt,
      drift.Value<int> rowid,
    });

class $$ShopsTableFilterComposer
    extends drift.Composer<_$AppDatabase, $ShopsTable> {
  $$ShopsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get shopName => $composableBuilder(
    column: $table.shopName,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get ownerName => $composableBuilder(
    column: $table.ownerName,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get pincode => $composableBuilder(
    column: $table.pincode,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get logoUrl => $composableBuilder(
    column: $table.logoUrl,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => drift.ColumnFilters(column),
  );
}

class $$ShopsTableOrderingComposer
    extends drift.Composer<_$AppDatabase, $ShopsTable> {
  $$ShopsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get shopName => $composableBuilder(
    column: $table.shopName,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get ownerName => $composableBuilder(
    column: $table.ownerName,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get pincode => $composableBuilder(
    column: $table.pincode,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get logoUrl => $composableBuilder(
    column: $table.logoUrl,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => drift.ColumnOrderings(column),
  );
}

class $$ShopsTableAnnotationComposer
    extends drift.Composer<_$AppDatabase, $ShopsTable> {
  $$ShopsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  drift.GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  drift.GeneratedColumn<String> get shopName =>
      $composableBuilder(column: $table.shopName, builder: (column) => column);

  drift.GeneratedColumn<String> get ownerName =>
      $composableBuilder(column: $table.ownerName, builder: (column) => column);

  drift.GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  drift.GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  drift.GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  drift.GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  drift.GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  drift.GeneratedColumn<String> get pincode =>
      $composableBuilder(column: $table.pincode, builder: (column) => column);

  drift.GeneratedColumn<String> get logoUrl =>
      $composableBuilder(column: $table.logoUrl, builder: (column) => column);

  drift.GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  drift.GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ShopsTableTableManager
    extends
        drift.RootTableManager<
          _$AppDatabase,
          $ShopsTable,
          Shop,
          $$ShopsTableFilterComposer,
          $$ShopsTableOrderingComposer,
          $$ShopsTableAnnotationComposer,
          $$ShopsTableCreateCompanionBuilder,
          $$ShopsTableUpdateCompanionBuilder,
          (Shop, drift.BaseReferences<_$AppDatabase, $ShopsTable, Shop>),
          Shop,
          drift.PrefetchHooks Function()
        > {
  $$ShopsTableTableManager(_$AppDatabase db, $ShopsTable table)
    : super(
        drift.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShopsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShopsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShopsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                drift.Value<String> id = const drift.Value.absent(),
                drift.Value<String> userId = const drift.Value.absent(),
                drift.Value<String> shopName = const drift.Value.absent(),
                drift.Value<String> ownerName = const drift.Value.absent(),
                drift.Value<String> phone = const drift.Value.absent(),
                drift.Value<String> email = const drift.Value.absent(),
                drift.Value<String> address = const drift.Value.absent(),
                drift.Value<String> city = const drift.Value.absent(),
                drift.Value<String> state = const drift.Value.absent(),
                drift.Value<String> pincode = const drift.Value.absent(),
                drift.Value<String?> logoUrl = const drift.Value.absent(),
                drift.Value<DateTime> createdAt = const drift.Value.absent(),
                drift.Value<DateTime> updatedAt = const drift.Value.absent(),
                drift.Value<int> rowid = const drift.Value.absent(),
              }) => ShopsCompanion(
                id: id,
                userId: userId,
                shopName: shopName,
                ownerName: ownerName,
                phone: phone,
                email: email,
                address: address,
                city: city,
                state: state,
                pincode: pincode,
                logoUrl: logoUrl,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
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
                drift.Value<String?> logoUrl = const drift.Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                drift.Value<int> rowid = const drift.Value.absent(),
              }) => ShopsCompanion.insert(
                id: id,
                userId: userId,
                shopName: shopName,
                ownerName: ownerName,
                phone: phone,
                email: email,
                address: address,
                city: city,
                state: state,
                pincode: pincode,
                logoUrl: logoUrl,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (e.readTable(table), drift.BaseReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ShopsTableProcessedTableManager =
    drift.ProcessedTableManager<
      _$AppDatabase,
      $ShopsTable,
      Shop,
      $$ShopsTableFilterComposer,
      $$ShopsTableOrderingComposer,
      $$ShopsTableAnnotationComposer,
      $$ShopsTableCreateCompanionBuilder,
      $$ShopsTableUpdateCompanionBuilder,
      (Shop, drift.BaseReferences<_$AppDatabase, $ShopsTable, Shop>),
      Shop,
      drift.PrefetchHooks Function()
    >;
typedef $$KycDocumentsTableCreateCompanionBuilder =
    KycDocumentsCompanion Function({
      required String id,
      required String userId,
      drift.Value<String?> panPath,
      drift.Value<String?> aadhaarPath,
      drift.Value<String?> addressProofPath,
      drift.Value<bool> isVerified,
      required DateTime createdAt,
      required DateTime updatedAt,
      drift.Value<int> rowid,
    });
typedef $$KycDocumentsTableUpdateCompanionBuilder =
    KycDocumentsCompanion Function({
      drift.Value<String> id,
      drift.Value<String> userId,
      drift.Value<String?> panPath,
      drift.Value<String?> aadhaarPath,
      drift.Value<String?> addressProofPath,
      drift.Value<bool> isVerified,
      drift.Value<DateTime> createdAt,
      drift.Value<DateTime> updatedAt,
      drift.Value<int> rowid,
    });

class $$KycDocumentsTableFilterComposer
    extends drift.Composer<_$AppDatabase, $KycDocumentsTable> {
  $$KycDocumentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get panPath => $composableBuilder(
    column: $table.panPath,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get aadhaarPath => $composableBuilder(
    column: $table.aadhaarPath,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get addressProofPath => $composableBuilder(
    column: $table.addressProofPath,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<bool> get isVerified => $composableBuilder(
    column: $table.isVerified,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => drift.ColumnFilters(column),
  );
}

class $$KycDocumentsTableOrderingComposer
    extends drift.Composer<_$AppDatabase, $KycDocumentsTable> {
  $$KycDocumentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get panPath => $composableBuilder(
    column: $table.panPath,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get aadhaarPath => $composableBuilder(
    column: $table.aadhaarPath,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get addressProofPath => $composableBuilder(
    column: $table.addressProofPath,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<bool> get isVerified => $composableBuilder(
    column: $table.isVerified,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => drift.ColumnOrderings(column),
  );
}

class $$KycDocumentsTableAnnotationComposer
    extends drift.Composer<_$AppDatabase, $KycDocumentsTable> {
  $$KycDocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  drift.GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  drift.GeneratedColumn<String> get panPath =>
      $composableBuilder(column: $table.panPath, builder: (column) => column);

  drift.GeneratedColumn<String> get aadhaarPath => $composableBuilder(
    column: $table.aadhaarPath,
    builder: (column) => column,
  );

  drift.GeneratedColumn<String> get addressProofPath => $composableBuilder(
    column: $table.addressProofPath,
    builder: (column) => column,
  );

  drift.GeneratedColumn<bool> get isVerified => $composableBuilder(
    column: $table.isVerified,
    builder: (column) => column,
  );

  drift.GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  drift.GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$KycDocumentsTableTableManager
    extends
        drift.RootTableManager<
          _$AppDatabase,
          $KycDocumentsTable,
          KycDocument,
          $$KycDocumentsTableFilterComposer,
          $$KycDocumentsTableOrderingComposer,
          $$KycDocumentsTableAnnotationComposer,
          $$KycDocumentsTableCreateCompanionBuilder,
          $$KycDocumentsTableUpdateCompanionBuilder,
          (
            KycDocument,
            drift.BaseReferences<
              _$AppDatabase,
              $KycDocumentsTable,
              KycDocument
            >,
          ),
          KycDocument,
          drift.PrefetchHooks Function()
        > {
  $$KycDocumentsTableTableManager(_$AppDatabase db, $KycDocumentsTable table)
    : super(
        drift.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KycDocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KycDocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KycDocumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                drift.Value<String> id = const drift.Value.absent(),
                drift.Value<String> userId = const drift.Value.absent(),
                drift.Value<String?> panPath = const drift.Value.absent(),
                drift.Value<String?> aadhaarPath = const drift.Value.absent(),
                drift.Value<String?> addressProofPath =
                    const drift.Value.absent(),
                drift.Value<bool> isVerified = const drift.Value.absent(),
                drift.Value<DateTime> createdAt = const drift.Value.absent(),
                drift.Value<DateTime> updatedAt = const drift.Value.absent(),
                drift.Value<int> rowid = const drift.Value.absent(),
              }) => KycDocumentsCompanion(
                id: id,
                userId: userId,
                panPath: panPath,
                aadhaarPath: aadhaarPath,
                addressProofPath: addressProofPath,
                isVerified: isVerified,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                drift.Value<String?> panPath = const drift.Value.absent(),
                drift.Value<String?> aadhaarPath = const drift.Value.absent(),
                drift.Value<String?> addressProofPath =
                    const drift.Value.absent(),
                drift.Value<bool> isVerified = const drift.Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                drift.Value<int> rowid = const drift.Value.absent(),
              }) => KycDocumentsCompanion.insert(
                id: id,
                userId: userId,
                panPath: panPath,
                aadhaarPath: aadhaarPath,
                addressProofPath: addressProofPath,
                isVerified: isVerified,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (e.readTable(table), drift.BaseReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KycDocumentsTableProcessedTableManager =
    drift.ProcessedTableManager<
      _$AppDatabase,
      $KycDocumentsTable,
      KycDocument,
      $$KycDocumentsTableFilterComposer,
      $$KycDocumentsTableOrderingComposer,
      $$KycDocumentsTableAnnotationComposer,
      $$KycDocumentsTableCreateCompanionBuilder,
      $$KycDocumentsTableUpdateCompanionBuilder,
      (
        KycDocument,
        drift.BaseReferences<_$AppDatabase, $KycDocumentsTable, KycDocument>,
      ),
      KycDocument,
      drift.PrefetchHooks Function()
    >;
typedef $$CarsTableCreateCompanionBuilder =
    CarsCompanion Function({
      required String id,
      required String userId,
      required String make,
      required String model,
      required String year,
      required String price,
      drift.Value<String?> imageUrl,
      drift.Value<String?> description,
      drift.Value<bool> isAvailable,
      required DateTime createdAt,
      required DateTime updatedAt,
      drift.Value<int> rowid,
    });
typedef $$CarsTableUpdateCompanionBuilder =
    CarsCompanion Function({
      drift.Value<String> id,
      drift.Value<String> userId,
      drift.Value<String> make,
      drift.Value<String> model,
      drift.Value<String> year,
      drift.Value<String> price,
      drift.Value<String?> imageUrl,
      drift.Value<String?> description,
      drift.Value<bool> isAvailable,
      drift.Value<DateTime> createdAt,
      drift.Value<DateTime> updatedAt,
      drift.Value<int> rowid,
    });

class $$CarsTableFilterComposer
    extends drift.Composer<_$AppDatabase, $CarsTable> {
  $$CarsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get make => $composableBuilder(
    column: $table.make,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<bool> get isAvailable => $composableBuilder(
    column: $table.isAvailable,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => drift.ColumnFilters(column),
  );
}

class $$CarsTableOrderingComposer
    extends drift.Composer<_$AppDatabase, $CarsTable> {
  $$CarsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get make => $composableBuilder(
    column: $table.make,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<bool> get isAvailable => $composableBuilder(
    column: $table.isAvailable,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => drift.ColumnOrderings(column),
  );
}

class $$CarsTableAnnotationComposer
    extends drift.Composer<_$AppDatabase, $CarsTable> {
  $$CarsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  drift.GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  drift.GeneratedColumn<String> get make =>
      $composableBuilder(column: $table.make, builder: (column) => column);

  drift.GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  drift.GeneratedColumn<String> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  drift.GeneratedColumn<String> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  drift.GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  drift.GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  drift.GeneratedColumn<bool> get isAvailable => $composableBuilder(
    column: $table.isAvailable,
    builder: (column) => column,
  );

  drift.GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  drift.GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CarsTableTableManager
    extends
        drift.RootTableManager<
          _$AppDatabase,
          $CarsTable,
          Car,
          $$CarsTableFilterComposer,
          $$CarsTableOrderingComposer,
          $$CarsTableAnnotationComposer,
          $$CarsTableCreateCompanionBuilder,
          $$CarsTableUpdateCompanionBuilder,
          (Car, drift.BaseReferences<_$AppDatabase, $CarsTable, Car>),
          Car,
          drift.PrefetchHooks Function()
        > {
  $$CarsTableTableManager(_$AppDatabase db, $CarsTable table)
    : super(
        drift.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CarsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CarsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CarsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                drift.Value<String> id = const drift.Value.absent(),
                drift.Value<String> userId = const drift.Value.absent(),
                drift.Value<String> make = const drift.Value.absent(),
                drift.Value<String> model = const drift.Value.absent(),
                drift.Value<String> year = const drift.Value.absent(),
                drift.Value<String> price = const drift.Value.absent(),
                drift.Value<String?> imageUrl = const drift.Value.absent(),
                drift.Value<String?> description = const drift.Value.absent(),
                drift.Value<bool> isAvailable = const drift.Value.absent(),
                drift.Value<DateTime> createdAt = const drift.Value.absent(),
                drift.Value<DateTime> updatedAt = const drift.Value.absent(),
                drift.Value<int> rowid = const drift.Value.absent(),
              }) => CarsCompanion(
                id: id,
                userId: userId,
                make: make,
                model: model,
                year: year,
                price: price,
                imageUrl: imageUrl,
                description: description,
                isAvailable: isAvailable,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String make,
                required String model,
                required String year,
                required String price,
                drift.Value<String?> imageUrl = const drift.Value.absent(),
                drift.Value<String?> description = const drift.Value.absent(),
                drift.Value<bool> isAvailable = const drift.Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                drift.Value<int> rowid = const drift.Value.absent(),
              }) => CarsCompanion.insert(
                id: id,
                userId: userId,
                make: make,
                model: model,
                year: year,
                price: price,
                imageUrl: imageUrl,
                description: description,
                isAvailable: isAvailable,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (e.readTable(table), drift.BaseReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CarsTableProcessedTableManager =
    drift.ProcessedTableManager<
      _$AppDatabase,
      $CarsTable,
      Car,
      $$CarsTableFilterComposer,
      $$CarsTableOrderingComposer,
      $$CarsTableAnnotationComposer,
      $$CarsTableCreateCompanionBuilder,
      $$CarsTableUpdateCompanionBuilder,
      (Car, drift.BaseReferences<_$AppDatabase, $CarsTable, Car>),
      Car,
      drift.PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$ShopsTableTableManager get shops =>
      $$ShopsTableTableManager(_db, _db.shops);
  $$KycDocumentsTableTableManager get kycDocuments =>
      $$KycDocumentsTableTableManager(_db, _db.kycDocuments);
  $$CarsTableTableManager get cars => $$CarsTableTableManager(_db, _db.cars);
}
