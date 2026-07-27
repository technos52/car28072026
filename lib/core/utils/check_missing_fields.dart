import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/firebase_config.dart';

class CheckMissingFields {
  static final FirebaseFirestore _db = FirebaseConfig.firestoreDatabaseId != null
      ? FirebaseFirestore.instanceFor(
          app: Firebase.app(),
          databaseId: FirebaseConfig.firestoreDatabaseId!,
        )
      : FirebaseFirestore.instance;

  static Future<void> checkAndReportMissingFields() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('CheckMissingFields: Skipping check because user is not authenticated');
        return;
      }
      print('=== Checking for cars with missing fields ===\n');
      
      final snapshot = await _db.collection('cars').get();
      final carsWithMissingFields = <Map<String, dynamic>>[];
      
      final requiredFields = [
        'owner',
        'color',
        'variant',
        'kmsDriven',
        'fuelType',
        'transmission',
        'insurance',
        'mileage',
        'tankCapacity'
      ];
      
      int totalCars = 0;
      
      for (var doc in snapshot.docs) {
        totalCars++;
        final data = doc.data();
        final missingFields = <String>[];
        
        for (var field in requiredFields) {
          if (data[field] == null || 
              (data[field] is String && (data[field] as String).trim().isEmpty)) {
            missingFields.add(field);
          }
        }
        
        if (missingFields.isNotEmpty) {
          final description = data['description'] as String? ?? '';
          final descriptionParts = _parseDescription(description);
          
          carsWithMissingFields.add({
            'id': doc.id,
            'make': data['make'] ?? 'N/A',
            'model': data['model'] ?? 'N/A',
            'year': data['year'] ?? 'N/A',
            'missingFields': missingFields,
            'description': description,
            'descriptionParts': descriptionParts,
            'data': data,
          });
        }
      }
      
      print('Total cars in database: $totalCars');
      print('Cars with missing fields: ${carsWithMissingFields.length}\n');
      
      if (carsWithMissingFields.isEmpty) {
        print('✅ All cars have all required fields!');
        return;
      }
      
      print('=== Cars with Missing Fields ===\n');
      
      for (var car in carsWithMissingFields) {
        print('Car ID: ${car['id']}');
        print('Make: ${car['make']}, Model: ${car['model']}, Year: ${car['year']}');
        print('Missing fields: ${car['missingFields'].join(', ')}');
        print('Description: ${car['description']}');
        if ((car['descriptionParts'] as Map).isNotEmpty) {
          print('Can extract from description:');
          car['descriptionParts'].forEach((key, value) {
            if (value.isNotEmpty) {
              print('  - $key: $value');
            }
          });
        }
        print('---\n');
      }
      
      print('\n=== Summary ===');
      print('Total cars: $totalCars');
      print('Cars with missing fields: ${carsWithMissingFields.length}');
      print('Cars with all fields: ${totalCars - carsWithMissingFields.length}');
      
      final fieldCounts = <String, int>{};
      for (var car in carsWithMissingFields) {
        for (var field in car['missingFields'] as List<String>) {
          fieldCounts[field] = (fieldCounts[field] ?? 0) + 1;
        }
      }
      
      print('\nMissing field counts:');
      fieldCounts.forEach((field, count) {
        print('  - $field: $count cars');
      });
      
    } catch (e, stackTrace) {
      print('Error checking missing fields: $e');
      print('Stack trace: $stackTrace');
    }
  }

  static Map<String, String> _parseDescription(String description) {
    final Map<String, String> result = {
      'variant': '',
      'color': '',
      'fuelType': '',
    };
    
    if (description.isEmpty) return result;
    
    final parts = description.split(',').map((e) => e.trim()).toList();
    if (parts.length >= 1) result['variant'] = parts[0];
    if (parts.length >= 2) result['color'] = parts[1];
    if (parts.length >= 3) result['fuelType'] = parts[2];
    
    return result;
  }

  static Future<void> updateCarsWithDescriptionData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('CheckMissingFields: Skipping update because user is not authenticated');
        return;
      }
      print('=== Updating cars with data from description ===\n');
      
      final snapshot = await _db.collection('cars').get();
      int updatedCount = 0;
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final description = data['description'] as String? ?? '';
        
        if (description.isEmpty) continue;
        
        final descriptionParts = _parseDescription(description);
        final updates = <String, dynamic>{};
        bool needsUpdate = false;
        
        final variant = descriptionParts['variant'] ?? '';
        final color = descriptionParts['color'] ?? '';
        final fuelType = descriptionParts['fuelType'] ?? '';
        
        if (variant.isNotEmpty && 
            (data['variant'] == null || (data['variant'] as String? ?? '').trim().isEmpty)) {
          updates['variant'] = variant;
          needsUpdate = true;
        }
        
        if (color.isNotEmpty && 
            (data['color'] == null || (data['color'] as String? ?? '').trim().isEmpty)) {
          updates['color'] = color;
          needsUpdate = true;
        }
        
        if (fuelType.isNotEmpty && 
            (data['fuelType'] == null || (data['fuelType'] as String? ?? '').trim().isEmpty)) {
          updates['fuelType'] = fuelType;
          needsUpdate = true;
        }
        
        if (needsUpdate) {
          final userId = data['userId'] as String?;
          
          await _db.collection('cars').doc(doc.id).update(updates);
          
          if (userId != null) {
            await _db.collection('users').doc(userId).collection('cars').doc(doc.id).update(updates);
          }
          
          updatedCount++;
          print('Updated car ${doc.id}: $updates');
        }
      }
      
      print('\n✅ Updated $updatedCount cars with data from description');
      
    } catch (e, stackTrace) {
      print('Error updating cars: $e');
      print('Stack trace: $stackTrace');
    }
  }
}
