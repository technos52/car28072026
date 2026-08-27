import 'dart:async';

class CatalogService {
  // TODO: Replace with real HTTP calls. These are stubbed for now.
  Future<List<String>> fetchCarNames() async => Future<List<String>>.delayed(const Duration(milliseconds: 200), () => <String>['Audi India', 'Bentley Motors', 'BMW India', 'BYD India', 'Citroen India', 'Ferrari', 'Honda Cars India', 'Hyundai Motor India', 'Jaguar Land Rover India', 'Jeep India', 'Kia India', 'Lamborghini', 'Land Rover India', 'Lexus India', 'MG Motor India', 'Mahindra & Mahindra', 'Maruti Suzuki', 'Maserati', 'Mercedes-Benz India', 'Mini India', 'Nissan Motor India', 'Porsche India', 'Renault India', 'Rolls-Royce Motor Cars', 'Skoda Auto India', 'Tata Motors', 'Tesla India', 'Toyota Kirloskar Motor', 'Volkswagen India', 'Volvo Car India']);
  Future<List<String>> fetchVariants(String carName) async {
    final Map<String, List<String>> variantsMap = {
      'Audi India': ['Premium', 'Premium Plus', 'Quattro (AWD)', 'S Line', 'Technology'],
      'Bentley Motors': ['Azure', 'Mulliner', 'Speed', 'V8', 'W12'],
      'BMW India': ['Competition', 'Luxury Line', 'M Sport', 'M Sport Pro', 'xDrive (AWD)', 'xLine'],
      'BYD India': ['Dynamic', 'Extended Range', 'Performance', 'Premium'],
      'Citroen India': ['Feel', 'Live', 'Shine', 'Shine Turbo'],
      'Ferrari': ['Assetto Fiorano', 'Competizione', 'Spider', 'Standard'],
      'Honda Cars India': ['e:HEV (Hybrid)', 'SV', 'V', 'VX', 'ZX'],
      'Hyundai Motor India': ['E', 'EX', 'IVT / DCT Options', 'N Line', 'S', 'S(O)', 'SX', 'SX(O)', 'Turbo'],
      'Jaguar Land Rover India': ['HSE', 'S', 'SE', 'R-Dynamic', 'First Edition'],
      'Jeep India': ['Limited', 'Longitude', 'Rubicon', 'Sport', 'Summit', 'Trailhawk'],
      'Kia India': ['GTX+', 'HTE', 'HTK', 'HTK+', 'HTX', 'HTX+', 'X-Line'],
      'Lamborghini': ['EVO', 'Performante', 'STO', 'Tecnica'],
      'Land Rover India': ['Autobiography', 'Dynamic', 'SE', 'First Edition', 'HSE', 'S'],
      'Lexus India': ['F-Sport', 'Luxury', 'Premium', 'Ultra Luxury'],
      'MG Motor India': ['Essence', 'EV', 'Exclusive / EV', 'Excite', 'Exclusive', 'Savvy', 'Sharp', 'Smart', 'Style', 'Super'],
      'Mahindra & Mahindra': ['AX(O)', 'AX3', 'AX5', 'AX7', 'AX7L', 'LX', 'MX', 'Z2', 'Z4', 'Z6', 'Z8', 'Z8L'],
      'Maruti Suzuki': ['AGS (Automatic)', 'Alpha', 'Alpha+', 'CNG Option', 'Delta', 'LXi', 'Sigma', 'VXi', 'Zeta', 'ZXi', 'ZXi+'],
      'Maserati': ['Folgore (EV)', 'GT', 'Modena', 'Trofeo'],
      'Mercedes-Benz India': ['4MATIC (AWD)', 'AMG', 'AMG Line', 'EQ (Electric Series)', 'Exclusive', 'Progressive'],
      'Mini India': ['Classic', 'JCW (John Cooper Works)', 'Signature'],
      'Nissan Motor India': ['Turbo', 'CVT', 'XE', 'XL', 'XV', 'XV Premium'],
      'Porsche India': ['4 / 4S (AWD)', 'GT3', 'GTS', 'S', 'Standard', 'Turbo', 'Turbo S'],
      'Renault India': ['RXE', 'RXL', 'RXT', 'RXT(O)', 'Turbo'],
      'Rolls-Royce Motor Cars': ['Black Badge', 'Extended Wheelbase (EWB)', 'Standard'],
      'Skoda Auto India': ['Active', 'Ambition', 'L&K (Laurin & Klement)', 'Monte Carlo', 'Sportline', 'Style'],
      'Tata Motors': ['Creative', 'Dark Edition', 'EV (MR / LR – Medium Range / Long Range)', 'Fearless', 'Pure', 'Smart', 'XE', 'XM', 'XT', 'XZ', 'XZ+', 'XZA+ (Automatic)'],
      'Tesla India': ['Long Range', 'Performance', 'Plaid', 'Standard Range'],
      'Toyota Kirloskar Motor': ['4x2 / 4x4', 'E', 'G', 'GX', 'Hybrid (Strong Hybrid Option)', 'S', 'V', 'VX', 'ZX', 'Z'],
      'Volkswagen India': ['Comfortline', 'GT', 'GT Edge', 'GT Plus', 'Highline', 'Topline'],
      'Volvo Car India': ['Core', 'Plus', 'Recharge (EV)', 'Ultimate']
    };
    return Future<List<String>>.delayed(
      const Duration(milliseconds: 200),
      () => variantsMap[carName] ?? <String>[],
    );
  }
  Future<List<String>> fetchYears() async {
    return List<String>.generate(21, (int i) => (2031 - i).toString());
  }
  Future<List<String>> fetchOwners() async => Future<List<String>>.delayed(const Duration(milliseconds: 200), () => <String>['First', 'Second', 'Third', 'Fourth', 'Fourth+']);
  Future<List<String>> fetchColours() async => Future<List<String>>.delayed(
        const Duration(milliseconds: 200),
        () => <String>[
          'Arctic White',
          'Beige',
          'Black',
          'Blue',
          'Bronze',
          'Brown',
          'Champagne',
          'Cherry Red',
          'Dark Grey',
          'Deep Red / Burgundy',
          'Emerald Green',
          'Gold',
          'Green',
          'Grey',
          'Gunmetal Grey',
          'Metallic Black',
          'Metallic Silver',
          'Midnight Blue',
          'Navy Blue',
          'Olive Green',
          'Orange',
          'Pearl Black',
          'Pearl White',
          'Purple',
          'Racing Yellow',
          'Red',
          'Silver',
          'Sky Blue',
          'Solid White',
          'Yellow',
        ],
      );
  Future<List<String>> fetchModels(String carName) async => Future<List<String>>.delayed(const Duration(milliseconds: 200), () => <String>['Model A', 'Model B', 'Model C']);
  Future<List<String>> fetchFuelTypes() async => Future<List<String>>.delayed(
        const Duration(milliseconds: 200),
        () => <String>[
          'CNG',
          'Diesel',
          'Electric (EV)',
          'Flex Fuel (Ethanol)',
          'Hybrid (HEV)',
          'Petrol',
          'Plug-in Hybrid (PHEV)',
        ],
      );
  Future<List<String>> fetchInsuranceStatuses() async => Future<List<String>>.delayed(const Duration(milliseconds: 200), () => <String>['Active', 'Expired', 'NA']);
  Future<List<String>> fetchTransmissions() async => Future<List<String>>.delayed(const Duration(milliseconds: 200), () => <String>['AMT', 'Automatic', 'CVT', 'DCT', 'DSG', 'e-CVT', 'iMT', 'Manual']);
  Future<List<String>> fetchStates() async {
    return _statesAndCities.keys.toList()..sort();
  }

  Future<List<String>> fetchCities(String state) async {
    return Future<List<String>>.delayed(
      const Duration(milliseconds: 200),
      () => _statesAndCities[state] ?? <String>[],
    );
  }

  final Map<String, List<String>> _statesAndCities = {
    'Andaman and Nicobar Islands': ['Port Blair'],
    'Andhra Pradesh': ['Adoni', 'Amaravati', 'Anantapur', 'Chandragiri', 'Chittoor', 'Dowlaiswaram', 'Eluru', 'Guntur', 'Kadapa', 'Kakinada', 'Kurnool', 'Machilipatnam', 'Nagarjunako', 'Rajahmundry', 'Srikakulam', 'Tirupati', 'Vijayawada', 'Visakhapatnam', 'Vizianagaram', 'Yemmiganur'],
    'Arunachal Pradesh': ['Itanagar'],
    'Assam': ['Dhuburi', 'Dibrugarh', 'Dispur', 'Guwahati', 'Jorhat', 'Nagaon', 'Sivasagar', 'Silchar', 'Tezpur', 'Tinsukia'],
    'Bihar': ['Ara', 'Barauni', 'Begusarai', 'Bettiah', 'Bhagalpur', 'Bihar Sharif', 'Bodh Gaya', 'Buxar', 'Chapra', 'Darbhanga', 'Dehri', 'Dinapur Nizamat', 'Gaya', 'Hajipur', 'Jamalpur', 'Katihar', 'Madhubani', 'Motihari', 'Munger', 'Muzaffarpur', 'Patna', 'Purnia', 'Pusa', 'Saharsa', 'Samastipur', 'Sasaram', 'Sitamarhi', 'Siwan'],
    'Chandigarh': ['Chandigarh'],
    'Chhattisgarh': ['Ambikapur', 'Bhilai', 'Bilaspur', 'Dhamtari', 'Durg', 'Jagdalpur', 'Raipur', 'Rajnandgaon'],
    'Dadra and Nagar Haveli and Daman and Diu': ['Daman', 'Diu', 'Silvassa'],
    'Delhi': ['Delhi', 'New Delhi'],
    'Goa': ['Madgaon', 'Panaji', 'Marmagao'],
    'Gujarat': ['Ahmedabad', 'Amreli', 'Bharuch', 'Bhavnagar', 'Bhuj', 'Dwarka', 'Gandhinagar', 'Godhra', 'Jamnagar', 'Junagadh', 'Kandla', 'Khambhat', 'Kheda', 'Mahesana', 'Morbi', 'Nadiad', 'Navsari', 'Okha', 'Palanpur', 'Patan', 'Porbandar', 'Rajkot', 'Surat', 'Surendranagar', 'Valsad', 'Veraval'],
    'Haryana': ['Ambala', 'Bhiwani', 'Chandigarh', 'Faridabad', 'Firozpur Jhirka', 'Gurugram', 'Hansi', 'Hisar', 'Jind', 'Kaithal', 'Karnal', 'Kurukshetra', 'Panipat', 'Pehowa', 'Rewari', 'Rohtak', 'Sirsa', 'Sonipat'],
    'Himachal Pradesh': ['Bilaspur', 'Chamba', 'Dalhousie', 'Dharmshala', 'Hamirpur', 'Kangra', 'Kullu', 'Mandi', 'Nahan', 'Shimla', 'Una'],
    'Jammu and Kashmir': ['Anantnag', 'Baramula', 'Batamalu', 'Jammu', 'Punch', 'Srinagar', 'Udhampur'],
    'Jharkhand': ['Bokaro', 'Chaibasa', 'Deoghar', 'Dhanbad', 'Dumka', 'Giridih', 'Hazaribag', 'Jamshedpur', 'Jharia', 'Rajmahal', 'Ranchi', 'Saraikela'],
    'Karnataka': ['Badami', 'Ballari', 'Bengaluru', 'Belagavi', 'Bhadravati', 'Bidar', 'Chikkamagaluru', 'Chitradurga', 'Davangere', 'Halebid', 'Hassan', 'Hubballi-Dharwad', 'Kalaburagi', 'Kolar', 'Madikeri', 'Mandya', 'Mangaluru', 'Mysuru', 'Raichur', 'Shivamogga', 'Shravanabelagola', 'Shrirangapattana', 'Tumakuru', 'Vijayapura'],
    'Kerala': ['Alappuzha', 'Badagara', 'Idukki', 'Kannur', 'Kochi', 'Kollam', 'Kottayam', 'Kozhikode', 'Mattancheri', 'Palakkad', 'Thalassery', 'Thiruvananthapuram', 'Thrissur'],
    'Ladakh': ['Kargil', 'Leh'],
    'Madhya Pradesh': ['Balaghat', 'Barwani', 'Betul', 'Bharhut', 'Bhind', 'Bhojpur', 'Bhopal', 'Burhanpur', 'Chhatarpur', 'Chhindwara', 'Damoh', 'Datia', 'Dewas', 'Dhar', 'Dr. Ambedkar Nagar (Mhow)', 'Guna', 'Gwalior', 'Hoshangabad', 'Indore', 'Itarsi', 'Jabalpur', 'Jhabua', 'Khajuraho', 'Khandwa', 'Khargone', 'Maheshwar', 'Mandla', 'Mandsaur', 'Morena', 'Murwara', 'Narsimhapur', 'Narsinghgarh', 'Narwar', 'Neemuch', 'Nowgong', 'Orchha', 'Panna', 'Raisen', 'Rajgarh', 'Ratlam', 'Rewa', 'Sagar', 'Sarangpur', 'Satna', 'Sehore', 'Seoni', 'Shahdol', 'Shajapur', 'Sheopur', 'Shivpuri', 'Ujjain', 'Vidisha'],
    'Maharashtra': ['Ahmadnagar', 'Akola', 'Amravati', 'Aurangabad', 'Bhandara', 'Bhusawal', 'Bid', 'Buldhana', 'Chandrapur', 'Daulatabad', 'Dhule', 'Jalgaon', 'Kalyan', 'Karli', 'Kolhapur', 'Mahabaleshwar', 'Malegaon', 'Matheran', 'Mumbai', 'Nagpur', 'Nanded', 'Nashik', 'Osmanabad', 'Pandharpur', 'Parbhani', 'Pune', 'Ratnagiri', 'Sangli', 'Satara', 'Sevagram', 'Solapur', 'Thane', 'Ulhasnagar', 'Vasai-Virar', 'Wardha', 'Yavatmal'],
    'Manipur': ['Imphal'],
    'Meghalaya': ['Cherrapunji', 'Shillong'],
    'Mizoram': ['Aizawl'],
    'Nagaland': ['Kohima', 'Mon', 'Phek', 'Wokha', 'Zunheboto'],
    'Odisha': ['Balangir', 'Baleshwar', 'Barbil', 'Bhubaneshwar', 'Brahmapur', 'Cuttack', 'Dhenkanal', 'Kendujhar', 'Konark', 'Koraput', 'Paradip', 'Phulabani', 'Puri', 'Sambalpur', 'Udayagiri'],
    'Puducherry': ['Karaikal', 'Mahe', 'Puducherry', 'Yanam'],
    'Punjab': ['Amritsar', 'Batala', 'Chandigarh', 'Faridkot', 'Firozpur', 'Gurdaspur', 'Hoshiarpur', 'Jalandhar', 'Kapurthala', 'Ludhiana', 'Nabha', 'Patiala', 'Rupnagar', 'Sangrur'],
    'Rajasthan': ['Abu', 'Ajmer', 'Alwar', 'Amer', 'Barmer', 'Beawar', 'Bharatpur', 'Bhilwara', 'Bikaner', 'Bundi', 'Chittaurgarh', 'Churu', 'Dhaulpur', 'Dungarpur', 'Ganganagar', 'Hanumangarh', 'Jaipur', 'Jaisalmer', 'Jalor', 'Jhalawar', 'Jhunjhunu', 'Jodhpur', 'Kishangarh', 'Kota', 'Merta', 'Nagaur', 'Nathdwara', 'Pali', 'Phalodi', 'Pushkar', 'Sawai Madhopur', 'Shahpura', 'Sikar', 'Sirohi', 'Tonk', 'Udaipur'],
    'Sikkim': ['Gangtok', 'Gyalshing', 'Lachung', 'Mangan'],
    'Tamil Nadu': ['Arcot', 'Chengalpattu', 'Chennai', 'Chidambaram', 'Coimbatore', 'Cuddalore', 'Dharmapuri', 'Dindigul', 'Erode', 'Kanchipuram', 'Kanyakumari', 'Kodaikanal', 'Kumbakonam', 'Madurai', 'Mamallapuram', 'Nagappattinam', 'Nagercoil', 'Palayamkottai', 'Pudukkottai', 'Rajapalayam', 'Ramanathapuram', 'Salem', 'Thanjavur', 'Tiruchchirappalli', 'Tirunelveli', 'Tiruppur', 'Tuticorin', 'Udhagamandalam', 'Vellore'],
    'Telangana': ['Hyderabad', 'Karimnagar', 'Khammam', 'Mahbubnagar', 'Nizamabad', 'Sangareddi', 'Warangal'],
    'Tripura': ['Agartala'],
    'Uttar Pradesh': ['Agra', 'Aligarh', 'Amroha', 'Ayodhya', 'Azamgarh', 'Bahraich', 'Ballia', 'Banda', 'Bara Banki', 'Bareilly', 'Basti', 'Bijnor', 'Bithur', 'Budaun', 'Bulandshahr', 'Deoria', 'Etah', 'Etawah', 'Faizabad', 'Farrukhabad-cum-Fatehgarh', 'Fatehpur', 'Fatehpur Sikri', 'Ghaziabad', 'Ghazipur', 'Gonda', 'Gorakhpur', 'Hamirpur', 'Hapur', 'Hardoi', 'Hathras', 'Jalaun', 'Jaunpur', 'Jhansi', 'Kannauj', 'Kanpur', 'Lakhimpur', 'Lalitpur', 'Lucknow', 'Mainpuri', 'Mathura', 'Meerut', 'Mirzapur-Vindhyachal', 'Moradabad', 'Muzaffarnagar', 'Partapgarh', 'Pilibhit', 'Prayagraj', 'Rae Bareli', 'Rampur', 'Saharanpur', 'Sambhal', 'Shahjahanpur', 'Sitapur', 'Sultanpur', 'Tehri', 'Varanasi'],
    'Uttarakhand': ['Almora', 'Dehradun', 'Haridwar', 'Mussoorie', 'Nainital', 'Pithoragarh'],
    'West Bengal': ['Alipore', 'Alipur Duar', 'Asansol', 'Baharampur', 'Bally', 'Balurghat', 'Bankura', 'Baranagar', 'Barasat', 'Barrackpore', 'Basirhat', 'Bhatpara', 'Bishnupur', 'Budge Budge', 'Burdwan', 'Chandernagore', 'Darjeeling', 'Diamond Harbour', 'Dum Dum', 'Durgapur', 'Halisahar', 'Haora', 'Hugli', 'Ingraj Bazar', 'Jalpaiguri', 'Kalimpong', 'Kamarhati', 'Kanchrapara', 'Kharagpur', 'Cooch Behar', 'Kolkata', 'Krishnanagar', 'Malda', 'Midnapore', 'Murshidabad', 'Nabadwip', 'Palashi', 'Panihati', 'Purulia', 'Raiganj', 'Santipur', 'Shantiniketan', 'Shrirampur', 'Siliguri', 'Titagarh']
  };
}


