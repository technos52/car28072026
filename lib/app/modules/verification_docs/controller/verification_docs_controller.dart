import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/database/database_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/remote_service.dart';
import '../../../../core/utils/toast.dart';

class VerificationDocsController extends GetxController {
  final List<String> panOptions = <String>['PAN Card'];
  final List<String> aadhaarOptions = <String>['Aadhaar Card'];
  final List<String> addressProofOptions = <String>[
    'Electricity Bill',
    'Water Bill',
    'Bank Statement',
  ];

  final RxString selectedPan = 'PAN Card'.obs;
  final RxString selectedAadhaar = 'Aadhaar Card'.obs;
  final RxString selectedAddressProof = 'Electricity Bill'.obs;

  // Step progress for bottom sheet (1 or 2)
  final RxInt currentStep = 1.obs;

  // Whether a file is selected/uploaded
  final RxBool isFileSelected = false.obs;

  // Progress for the Document Verification header (0.0 - 1.0)
  // Defaults to initial partial progress when screen loads
  final RxDouble verificationProgress = 0.35.obs;

  final GetStorage _box = GetStorage();
  static const String _keyPan = 'doc_pan_path';
  static const String _keyAadhaar = 'doc_aadhaar_path';
  static const String _keyAddress = 'doc_address_path';

  final RxString panPath = ''.obs;
  final RxString aadhaarPath = ''.obs;
  final RxString addressPath = ''.obs;
  final RxBool isUploadingPan = false.obs;
  final RxBool isUploadingAadhaar = false.obs;
  final RxBool isUploadingAddress = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedDocuments();
  }

  void _loadSavedDocuments() async {
    try {
      // Load from GetStorage first (for onboarding flow)
      panPath.value = _box.read<String>(_keyPan) ?? '';
      aadhaarPath.value = _box.read<String>(_keyAadhaar) ?? '';
      addressPath.value = _box.read<String>(_keyAddress) ?? '';

      // Also load from database if available (for returning users)
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (!Get.isRegistered<DatabaseService>()) {
          await Get.putAsync<DatabaseService>(() async => DatabaseService());
        }
        final databaseService = Get.find<DatabaseService>();
        final kycDoc = await databaseService.getKycDocument(user.uid);

        if (kycDoc != null) {
          if (kycDoc.panPath != null && kycDoc.panPath!.isNotEmpty) {
            panPath.value = kycDoc.panPath!;
            _box.write(_keyPan, kycDoc.panPath!);
          }
          if (kycDoc.aadhaarPath != null && kycDoc.aadhaarPath!.isNotEmpty) {
            aadhaarPath.value = kycDoc.aadhaarPath!;
            _box.write(_keyAadhaar, kycDoc.aadhaarPath!);
          }
          if (kycDoc.addressProofPath != null &&
              kycDoc.addressProofPath!.isNotEmpty) {
            addressPath.value = kycDoc.addressProofPath!;
            _box.write(_keyAddress, kycDoc.addressProofPath!);
          }
        }

        if (!Get.isRegistered<RemoteService>()) {
          Get.put(RemoteService());
        }
        final remoteService = Get.find<RemoteService>();
        final remoteKycDoc = await remoteService.getKycDocument(user.uid);

        if (remoteKycDoc != null) {
          if (remoteKycDoc['panPath'] != null &&
              remoteKycDoc['panPath'].toString().isNotEmpty) {
            final remotePan = remoteKycDoc['panPath'].toString();
            if (remotePan.startsWith('http')) {
              panPath.value = remotePan;
              _box.write(_keyPan, remotePan);
            }
          }
          if (remoteKycDoc['aadhaarPath'] != null &&
              remoteKycDoc['aadhaarPath'].toString().isNotEmpty) {
            final remoteAadhaar = remoteKycDoc['aadhaarPath'].toString();
            if (remoteAadhaar.startsWith('http')) {
              aadhaarPath.value = remoteAadhaar;
              _box.write(_keyAadhaar, remoteAadhaar);
            }
          }
          if (remoteKycDoc['addressProofPath'] != null &&
              remoteKycDoc['addressProofPath'].toString().isNotEmpty) {
            final remoteAddress = remoteKycDoc['addressProofPath'].toString();
            if (remoteAddress.startsWith('http')) {
              addressPath.value = remoteAddress;
              _box.write(_keyAddress, remoteAddress);
            }
          }
        }
      }

      _recomputeProgress();
    } catch (e) {
      print('Error loading saved documents: $e');
      _recomputeProgress();
    }
  }

  void resetUploadFlow() {
    currentStep.value = 1;
    isFileSelected.value = false;
    // When resetting (opening sheet from screen), expand header progress to mid stage
    verificationProgress.value = 0.65;
  }

  // Call when user selects a file. We immediately advance to step 2.
  void markFileSelected() {
    isFileSelected.value = true;
    currentStep.value = 2;
  }

  Future<void> uploadDocumentToFirebase(
    String documentType,
    String localPath,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Ensure StorageService is registered
      if (!Get.isRegistered<StorageService>()) {
        Get.put(StorageService());
      }
      final storageService = Get.find<StorageService>();
      final String firebaseUrl = await storageService.uploadKycDocument(
        userId: user.uid,
        filePath: localPath,
        documentType: documentType,
      );

      if (documentType == 'pan') {
        panPath.value = firebaseUrl;
        _box.write(_keyPan, firebaseUrl);
        isUploadingPan.value = false;
      } else if (documentType == 'aadhaar') {
        aadhaarPath.value = firebaseUrl;
        _box.write(_keyAadhaar, firebaseUrl);
        isUploadingAadhaar.value = false;
      } else if (documentType == 'address') {
        addressPath.value = firebaseUrl;
        _box.write(_keyAddress, firebaseUrl);
        isUploadingAddress.value = false;
      }

      _recomputeProgress();

      Toast.showSuccess('Document uploaded successfully');
    } catch (e) {
      if (documentType == 'pan') {
        isUploadingPan.value = false;
        panPath.value = '';
        _box.remove(_keyPan);
      } else if (documentType == 'aadhaar') {
        isUploadingAadhaar.value = false;
        aadhaarPath.value = '';
        _box.remove(_keyAadhaar);
      } else if (documentType == 'address') {
        isUploadingAddress.value = false;
        addressPath.value = '';
        _box.remove(_keyAddress);
      }

      _recomputeProgress();
      print('Error uploading document to Firebase: $e');
      rethrow;
    }
  }

  void markUploadCompleted() async {
    verificationProgress.value = 1.0;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      if (!Get.isRegistered<DatabaseService>()) {
        await Get.putAsync<DatabaseService>(() async => DatabaseService());
      }
      if (!Get.isRegistered<RemoteService>()) {
        Get.put(RemoteService());
      }

      final databaseService = Get.find<DatabaseService>();
      final remoteService = Get.find<RemoteService>();

      final String panUrl = panPath.value.startsWith('http')
          ? panPath.value
          : '';
      final String aadhaarUrl = aadhaarPath.value.startsWith('http')
          ? aadhaarPath.value
          : '';
      final String addressUrl = addressPath.value.startsWith('http')
          ? addressPath.value
          : '';

      await databaseService.saveKycDocument(
        id: '${user.uid}_kyc',
        userId: user.uid,
        panPath: panUrl.isNotEmpty ? panUrl : null,
        aadhaarPath: aadhaarUrl.isNotEmpty ? aadhaarUrl : null,
        addressProofPath: addressUrl.isNotEmpty ? addressUrl : null,
        isVerified: false,
      );

      await remoteService.saveKycDocument(
        id: '${user.uid}_kyc',
        userId: user.uid,
        panPath: panUrl.isNotEmpty ? panUrl : null,
        aadhaarPath: aadhaarUrl.isNotEmpty ? aadhaarUrl : null,
        addressProofPath: addressUrl.isNotEmpty ? addressUrl : null,
        isVerified: false,
      );

      final userData = await remoteService.getUser(user.uid);
      final userName =
          userData?['name']?.toString() ??
          user.displayName ??
          user.email?.split('@').first ??
          'Unknown User';
      final userEmail = userData?['email']?.toString() ?? user.email ?? '';

      if (panUrl.isNotEmpty && aadhaarUrl.isNotEmpty && addressUrl.isNotEmpty) {
        await remoteService.sendKycUploadNotificationToAdmin(
          userId: user.uid,
          userName: userName,
          userEmail: userEmail,
          panPath: panUrl,
          aadhaarPath: aadhaarUrl,
          addressProofPath: addressUrl,
        );
      }
    } catch (e) {
      print('Error saving KYC data: $e');
    }
  }

  Future<void> pickPan() async {
    final String? path = await _pickSingleFile();
    if (path != null) {
      panPath.value = path;
      _box.write(_keyPan, path);
      isUploadingPan.value = true;
      _recomputeProgress();

      Toast.showInfo('Document selected. Uploading in background...');

      uploadDocumentToFirebase('pan', path).catchError((e) {
        print('Error uploading PAN: $e');
        Toast.showError('Failed to upload PAN document. Please try again.');
      });
    }
  }

  Future<void> pickAadhaar() async {
    final String? path = await _pickSingleFile();
    if (path != null) {
      aadhaarPath.value = path;
      _box.write(_keyAadhaar, path);
      isUploadingAadhaar.value = true;
      _recomputeProgress();

      Toast.showInfo('Document selected. Uploading in background...');

      uploadDocumentToFirebase('aadhaar', path).catchError((e) {
        print('Error uploading Aadhaar: $e');
        Toast.showError('Failed to upload Aadhaar document. Please try again.');
      });
    }
  }

  Future<void> pickAddressProof() async {
    final String? path = await _pickSingleFile();
    if (path != null) {
      addressPath.value = path;
      _box.write(_keyAddress, path);
      isUploadingAddress.value = true;
      _recomputeProgress();

      Toast.showInfo('Document selected. Uploading in background...');

      uploadDocumentToFirebase('address', path).catchError((e) {
        print('Error uploading Address Proof: $e');
        Toast.showError('Failed to upload Address Proof. Please try again.');
      });
    }
  }

  Future<void> removeDocument(String documentType) async {
    String? oldPath;

    if (documentType == 'pan') {
      oldPath = panPath.value;
      panPath.value = '';
      _box.remove(_keyPan);
    } else if (documentType == 'aadhaar') {
      oldPath = aadhaarPath.value;
      aadhaarPath.value = '';
      _box.remove(_keyAadhaar);
    } else if (documentType == 'address') {
      oldPath = addressPath.value;
      addressPath.value = '';
      _box.remove(_keyAddress);
    }

    _recomputeProgress();

    if (oldPath != null && oldPath.isNotEmpty && oldPath.startsWith('http')) {
      try {
        // Ensure StorageService is registered
        if (!Get.isRegistered<StorageService>()) {
          Get.put(StorageService());
        }
        final storageService = Get.find<StorageService>();
        storageService.deleteImage(oldPath).catchError((e) {
          print('Error deleting document from Firebase Storage: $e');
        });
      } catch (e) {
        print('Error initiating Firebase Storage deletion: $e');
      }
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        if (!Get.isRegistered<DatabaseService>()) {
          await Get.putAsync<DatabaseService>(() async => DatabaseService());
        }
        if (!Get.isRegistered<RemoteService>()) {
          Get.put(RemoteService());
        }

        final databaseService = Get.find<DatabaseService>();
        final remoteService = Get.find<RemoteService>();

        final String panUrl = panPath.value.startsWith('http')
            ? panPath.value
            : '';
        final String aadhaarUrl = aadhaarPath.value.startsWith('http')
            ? aadhaarPath.value
            : '';
        final String addressUrl = addressPath.value.startsWith('http')
            ? addressPath.value
            : '';

        try {
          await databaseService.saveKycDocument(
            id: '${user.uid}_kyc',
            userId: user.uid,
            panPath: panUrl.isNotEmpty ? panUrl : null,
            aadhaarPath: aadhaarUrl.isNotEmpty ? aadhaarUrl : null,
            addressProofPath: addressUrl.isNotEmpty ? addressUrl : null,
            isVerified: false,
          );
        } catch (e) {
          print('Error saving to local database: $e');
        }

        try {
          await remoteService.saveKycDocument(
            id: '${user.uid}_kyc',
            userId: user.uid,
            panPath: panUrl.isNotEmpty ? panUrl : null,
            aadhaarPath: aadhaarUrl.isNotEmpty ? aadhaarUrl : null,
            addressProofPath: addressUrl.isNotEmpty ? addressUrl : null,
            isVerified: false,
          );
        } catch (e) {
          print('Error saving to Firestore: $e');
        }
      } catch (e) {
        print('Error updating database after removing document: $e');
      }
    }
  }

  Future<String?> _pickSingleFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: false,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final file = result.files.single;
      final String? filePath = file.path;
      final String? fileName = file.name;

      if (filePath == null && fileName == null) {
        Get.snackbar(
          'Error',
          'Unable to access file',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return null;
      }

      final String fileExtension = (filePath ?? fileName ?? '')
          .toLowerCase()
          .split('.')
          .last;

      const List<String> allowed = ['pdf', 'jpg', 'jpeg', 'png'];
      if (!allowed.contains(fileExtension)) {
        Get.snackbar(
          'Error',
          'Only PDF, JPG, and PNG files are supported',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return null;
      }

      final String? selectedPath = filePath ?? fileName;
      if (selectedPath != null && selectedPath.isNotEmpty) {
        return selectedPath;
      }

      return null;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick file: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  bool get areAllDocumentsUploaded {
    final bool panUploaded =
        panPath.value.isNotEmpty && panPath.value.startsWith('http');
    final bool aadhaarUploaded =
        aadhaarPath.value.isNotEmpty && aadhaarPath.value.startsWith('http');
    final bool addressUploaded =
        addressPath.value.isNotEmpty && addressPath.value.startsWith('http');
    return panUploaded && aadhaarUploaded && addressUploaded;
  }

  void _recomputeProgress() {
    int uploaded = 0;
    int selected = 0;
    if (panPath.value.isNotEmpty) {
      selected++;
      if (panPath.value.startsWith('http')) uploaded++;
    }
    if (aadhaarPath.value.isNotEmpty) {
      selected++;
      if (aadhaarPath.value.startsWith('http')) uploaded++;
    }
    if (addressPath.value.isNotEmpty) {
      selected++;
      if (addressPath.value.startsWith('http')) uploaded++;
    }
    if (selected == 0) {
      verificationProgress.value = 0.35;
    } else if (uploaded < 3) {
      verificationProgress.value = 0.65;
    } else {
      verificationProgress.value = 1.0;
    }
  }
}
