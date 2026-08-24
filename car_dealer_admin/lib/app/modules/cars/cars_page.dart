import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/widgets/admin_layout.dart';
import '../../routes/app_routes.dart';

class CarsPage extends StatefulWidget {
  const CarsPage({super.key});

  @override
  State<CarsPage> createState() => _CarsPageState();
}

class _CarsPageState extends State<CarsPage> {
  final AdminService _adminService = AdminService();
  List<Map<String, dynamic>> _cars = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  Future<void> _loadCars() async {
    setState(() => _isLoading = true);
    final cars = await _adminService.getAllCars();
    setState(() {
      _cars = cars;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredCars {
    var filtered = _cars;
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((car) {
        final make = (car['make'] ?? '').toString().toLowerCase();
        final model = (car['model'] ?? '').toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return make.contains(query) || model.contains(query);
      }).toList();
    }
    if (_filterStatus != 'all') {
      final isAvailable = _filterStatus == 'available';
      filtered = filtered.where((car) {
        return car['isAvailable'] == isAvailable;
      }).toList();
    }
    return filtered;
  }

  Future<void> _toggleCarAvailability(Map<String, dynamic> car) async {
    try {
      await _adminService.updateCarAvailability(
        car['id'],
        !(car['isAvailable'] ?? true),
      );
      Get.snackbar('Success', 'Car status updated');
      _loadCars();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update car: $e');
    }
  }

  Future<void> _deleteCar(Map<String, dynamic> car) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Car'),
        content: const Text('Are you sure you want to delete this car?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _adminService.deleteCar(car['id']);
        Get.snackbar('Success', 'Car deleted successfully');
        _loadCars();
      } catch (e) {
        Get.snackbar('Error', 'Failed to delete car: $e');
      }
    }
  }
  void _showCarDetails(Map<String, dynamic> car) {
    final excludedKeys = ['id', 'userid', 'shopid', 'createdat', 'updatedat', 'timestamp', 'sellername', 'shopname', 'isavailable'];
    
    final specs = car.entries.where((e) {
      final key = e.key.toLowerCase();
      if (excludedKeys.contains(key)) return false;
      if (key.contains('image') || key.contains('url') || key.contains('path')) return false;
      if (key.contains('time') || key.contains('date')) return false;
      if (e.value == null || e.value.toString().trim().isEmpty) return false;
      return true;
    }).toList();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${car['make'] ?? ''} ${car['model'] ?? ''} - ${car['shopName'] ?? car['sellerName'] ?? 'Unknown Shop'}'.trim().toUpperCase(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    onPressed: () => Get.back(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (car['year'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${car['year']}',
                        style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold),
                      ),
                    ),
                  const SizedBox(width: 8),
                  if (car['price'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '₹${car['price']}',
                        style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Vehicle Specifications',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: specs.map((e) {
                      String formattedKey = e.key.replaceAll(RegExp(r'(?<=[a-z])(?=[A-Z])'), ' ');
                      formattedKey = formattedKey[0].toUpperCase() + formattedKey.substring(1);
                      return Container(
                        width: 200,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formattedKey,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${e.value}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF334155),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _getCarImage(Map<String, dynamic> car) {
    if (car['imageUrl'] != null && car['imageUrl'].toString().isNotEmpty) {
      return car['imageUrl'];
    }
    if (car['imageUrls'] is List && (car['imageUrls'] as List).isNotEmpty) {
      return (car['imageUrls'] as List).first.toString();
    }
    if (car['imagePaths'] is List && (car['imagePaths'] as List).isNotEmpty) {
      return (car['imagePaths'] as List).first.toString();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: AppRoutes.cars,
      title: 'Cars Management',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadCars,
        ),
      ],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search cars by make or model',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('All'),
                        selected: _filterStatus == 'all',
                        onSelected: (selected) {
                          if (selected) setState(() => _filterStatus = 'all');
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Available'),
                        selected: _filterStatus == 'available',
                        onSelected: (selected) {
                          if (selected)
                            setState(() => _filterStatus = 'available');
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Sold'),
                        selected: _filterStatus == 'sold',
                        onSelected: (selected) {
                          if (selected) setState(() => _filterStatus = 'sold');
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCars.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isEmpty
                              ? 'No cars found'
                              : 'No cars match your search',
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredCars.length,
                        itemBuilder: (context, index) {
                          final car = _filteredCars[index];
                          final isAvailable = car['isAvailable'] ?? true;
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              onTap: () => _showCarDetails(car),
                              leading: _getCarImage(car) != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        _getCarImage(car)!,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return const SizedBox(
                                            width: 80,
                                            height: 80,
                                            child: Center(
                                              child: CircularProgressIndicator(),
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.directions_car, size: 40),
                                      ),
                                    )
                                  : const Icon(Icons.directions_car, size: 40),
                              title: Text(
                                '${car['make'] ?? ''} ${car['model'] ?? ''} - ${car['shopName'] ?? car['sellerName'] ?? 'Unknown Shop'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Year: ${car['year'] ?? ''}'),
                                  Text('Price: ₹${car['price'] ?? ''}'),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isAvailable
                                              ? Colors.green.shade100
                                              : Colors.red.shade100,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          isAvailable ? 'Available' : 'Sold',
                                          style: TextStyle(
                                            color: isAvailable
                                                ? Colors.green.shade800
                                                : Colors.red.shade800,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'toggle',
                                    child: Text(
                                      isAvailable ? 'Mark as Sold' : 'Mark as Available',
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'delete') {
                                    _deleteCar(car);
                                  } else if (value == 'toggle') {
                                    _toggleCarAvailability(car);
                                  }
                                },
                                child: const Icon(Icons.more_vert),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

