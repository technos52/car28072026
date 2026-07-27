import 'dart:async';

class CatalogService {
  // TODO: Replace with real HTTP calls. These are stubbed for now.
  Future<List<String>> fetchCarNames() async => Future<List<String>>.delayed(const Duration(milliseconds: 200), () => <String>['KIA', 'Hyundai', 'Maruti', 'Tata', 'Toyota']);
  Future<List<String>> fetchVariants(String carName) async => Future<List<String>>.delayed(const Duration(milliseconds: 200), () => <String>['Base', 'Mid', 'Top']);
  Future<List<String>> fetchYears() async {
    final int currentYear = DateTime.now().year;
    return List<String>.generate(30, (int i) => (currentYear - i).toString());
  }
  Future<List<String>> fetchOwners() async => Future<List<String>>.delayed(const Duration(milliseconds: 200), () => <String>['First', 'Second', 'Third', 'Fourth', 'Fourth+']);
  Future<List<String>> fetchColours() async => Future<List<String>>.delayed(const Duration(milliseconds: 200), () => <String>['Red', 'Blue', 'Black', 'Silver', 'White']);
  Future<List<String>> fetchModels(String carName) async => Future<List<String>>.delayed(const Duration(milliseconds: 200), () => <String>['Model A', 'Model B', 'Model C']);
  Future<List<String>> fetchFuelTypes() async => Future<List<String>>.delayed(const Duration(milliseconds: 200), () => <String>['Petrol', 'Diesel', 'CNG', 'Electric', 'Hybrid']);
  Future<List<String>> fetchInsuranceStatuses() async => Future<List<String>>.delayed(const Duration(milliseconds: 200), () => <String>['Active', 'Expired', 'NA']);
  Future<List<String>> fetchTransmissions() async => Future<List<String>>.delayed(const Duration(milliseconds: 200), () => <String>['Manual', 'Automatic', 'AMT', 'DCT', 'CVT']);
  Future<List<String>> fetchStates() async => Future<List<String>>.delayed(const Duration(milliseconds: 200), () => <String>['Delhi', 'Maharashtra', 'Karnataka', 'Tamil Nadu', 'Gujarat', 'Uttar Pradesh', 'Rajasthan', 'Punjab', 'Haryana', 'Madhya Pradesh']);
  Future<List<String>> fetchCities(String state) async => Future<List<String>>.delayed(const Duration(milliseconds: 200), () => <String>['Mumbai', 'Delhi', 'Bangalore', 'Chennai', 'Hyderabad', 'Ahmedabad', 'Pune', 'Jaipur', 'Lucknow', 'Kanpur']);
}


