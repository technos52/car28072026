import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/modules/home/home_controller.dart';

class SimpleHomeTest extends StatelessWidget {
  const SimpleHomeTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Car Dealer'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: GetBuilder<HomeController>(
        init: HomeController(),
        builder: (controller) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting section
                Obx(
                  () => Text(
                    '${controller.getGreeting()} ${controller.userName.value.isNotEmpty ? controller.userName.value : 'User'}! 👋',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Stats section
                Obx(
                  () => Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  '${controller.userCars.length}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const Text('My Cars'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  '${controller.topDealsCars.length}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                const Text('Available'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  '${controller.brands.length}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                                const Text('Brands'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Loading indicator or content
                Expanded(
                  child: Obx(() {
                    if (controller.allOtherCars.isEmpty &&
                        controller.userCars.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Loading cars...'),
                          ],
                        ),
                      );
                    }

                    return ListView(
                      children: [
                        if (controller.userCars.isNotEmpty) ...[
                          const Text(
                            'My Cars',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...controller.userCars.map(
                            (car) => Card(
                              child: ListTile(
                                leading: const Icon(Icons.car_rental),
                                title: Text('${car.name} ${car.model}'),
                                subtitle: Text(
                                  '${car.yearOfManufacture} • ${car.demandPrice}',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        if (controller.topDealsCars.isNotEmpty) ...[
                          const Text(
                            'Available Cars',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...controller.topDealsCars
                              .take(5)
                              .map(
                                (car) => Card(
                                  child: ListTile(
                                    leading: const Icon(
                                      Icons.car_rental,
                                      color: Colors.green,
                                    ),
                                    title: Text('${car.name} ${car.model}'),
                                    subtitle: Text(
                                      '${car.yearOfManufacture} • ${car.demandPrice}',
                                    ),
                                  ),
                                ),
                              ),
                        ],

                        if (controller.brands.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'Available Brands',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: controller.brands
                                .take(10)
                                .map(
                                  (brand) => Chip(
                                    label: Text(brand),
                                    backgroundColor: Colors.blue.shade50,
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ],
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add car functionality
          Get.snackbar('Add Car', 'Feature coming soon!');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
