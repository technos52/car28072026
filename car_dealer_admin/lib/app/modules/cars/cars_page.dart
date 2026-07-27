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
                              leading: car['imageUrl'] != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        car['imageUrl'],
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
                                '${car['make'] ?? ''} ${car['model'] ?? ''}',
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

