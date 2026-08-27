import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage({
    required String userId,
    required String filePath,
    required String folderName,
    String? fileName,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Normalize file path - remove file:// prefix if present
      String normalizedPath = filePath;
      if (normalizedPath.startsWith('file://')) {
        normalizedPath = normalizedPath.replaceFirst('file://', '');
      }

      print('Attempting to upload image from path: $normalizedPath');

      final File file = File(normalizedPath);
      final bool fileExists = await file.exists();

      if (!fileExists) {
        print('File does not exist at path: $normalizedPath');
        // Try original path
        if (normalizedPath != filePath) {
          final File originalFile = File(filePath);
          if (await originalFile.exists()) {
            normalizedPath = filePath;
            print('File exists at original path: $filePath');
          } else {
            throw Exception(
              'File does not exist at path: $filePath or $normalizedPath',
            );
          }
        } else {
          throw Exception('File does not exist: $filePath');
        }
      }

      final File actualFile = File(normalizedPath);
      final fileSize = await actualFile.length();
      print('File exists. Size: $fileSize bytes');

      // Generate unique filename if not provided
      final String uniqueFileName =
          fileName ??
          '${DateTime.now().millisecondsSinceEpoch}_${normalizedPath.split('/').last.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_')}';
      final String storagePath = 'users/$userId/$folderName/$uniqueFileName';

      print('Uploading to Firebase Storage path: $storagePath');

      // Upload file with metadata
      final Reference ref = _storage.ref().child(storagePath);

      print('Starting file upload...');
      print('Storage bucket: ${_storage.app.options.storageBucket}');
      final data = await actualFile.readAsBytes();
      final UploadTask uploadTask = ref.putData(
        data,
        SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'max-age=3600',
        ),
      );

      // Monitor upload progress
      uploadTask.snapshotEvents.listen(
        (TaskSnapshot snapshot) {
          if (snapshot.totalBytes > 0) {
            final progress =
                (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
            print('Upload progress: ${progress.toStringAsFixed(1)}%');
          }
        },
        onError: (error) {
          print('Upload progress error: $error');
        },
      );

      // Wait for upload to complete
      print('Waiting for upload to complete...');
      final TaskSnapshot snapshot = await uploadTask.whenComplete(() {
        print('Upload task completed');
      });

      if (snapshot.state == TaskState.success) {
        print(
          'Upload completed successfully. Bytes transferred: ${snapshot.totalBytes}',
        );

        // Get download URL
        print('Getting download URL...');
        final String downloadUrl = await snapshot.ref.getDownloadURL();

        print('Image uploaded successfully to: $downloadUrl');
        return downloadUrl;
      } else if (snapshot.state == TaskState.error) {
        throw Exception('Upload failed with state: ${snapshot.state}');
      } else {
        throw Exception('Upload incomplete. State: ${snapshot.state}');
      }
    } catch (e, stackTrace) {
      print('Error uploading image: $e');
      print('Stack trace: $stackTrace');

      if (e is FirebaseException) {
        print('Firebase error code: ${e.code}');
        print('Firebase error message: ${e.message}');
        print('Firebase storage bucket: ${_storage.app.options.storageBucket}');
        throw Exception('Upload failed. Please check your internet connection and try again.');
      }

      // Handle other exceptions
      if (e.toString().contains('404') || e.toString().contains('Not Found')) {
        throw Exception('Upload failed. Service unavailable.');
      }

      throw Exception('An unexpected error occurred during upload. Please try again.');
    }
  }

  Future<String> uploadProfileImage(String userId, String filePath) async {
    return uploadImage(
      userId: userId,
      filePath: filePath,
      folderName: 'avatars',
      fileName: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
  }

  Future<String> uploadCarImage(
    String userId,
    String filePath,
    String carId,
    int imageIndex,
  ) async {
    return uploadImage(
      userId: userId,
      filePath: filePath,
      folderName: 'cars/$carId',
      fileName: 'image_$imageIndex.jpg',
    );
  }

  Future<String> uploadShopImage(String userId, String filePath) async {
    return uploadImage(
      userId: userId,
      filePath: filePath,
      folderName: 'shops',
      fileName: 'shop_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
  }

  Future<void> deleteImage(String downloadUrl) async {
    try {
      final Reference ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
      print('Image deleted successfully: $downloadUrl');
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  Future<String> uploadKycDocument({
    required String userId,
    required String filePath,
    required String documentType,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      String normalizedPath = filePath;
      if (normalizedPath.startsWith('file://')) {
        normalizedPath = normalizedPath.replaceFirst('file://', '');
      }

      print('Attempting to upload KYC document from path: $normalizedPath');

      final File file = File(normalizedPath);
      final bool fileExists = await file.exists();

      if (!fileExists) {
        print('File does not exist at path: $normalizedPath');
        if (normalizedPath != filePath) {
          final File originalFile = File(filePath);
          if (await originalFile.exists()) {
            normalizedPath = filePath;
            print('File exists at original path: $filePath');
          } else {
            throw Exception(
              'File does not exist at path: $filePath or $normalizedPath',
            );
          }
        } else {
          throw Exception('File does not exist: $filePath');
        }
      }

      final File actualFile = File(normalizedPath);
      final fileSize = await actualFile.length();
      print('File exists. Size: $fileSize bytes');

      final String extension = normalizedPath.split('.').last.toLowerCase();
      final String fileName =
          '${documentType}_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final String storagePath = 'users/$userId/kyc_documents/$fileName';

      print('Uploading to Firebase Storage path: $storagePath');

      final Reference ref = _storage.ref().child(storagePath);

      print('Starting file upload...');
      final data = await actualFile.readAsBytes();
      
      String contentType = 'application/pdf';
      if (extension == 'jpg' || extension == 'jpeg') {
        contentType = 'image/jpeg';
      } else if (extension == 'png') {
        contentType = 'image/png';
      }

      final UploadTask uploadTask = ref.putData(
        data,
        SettableMetadata(
          contentType: contentType,
          cacheControl: 'max-age=3600',
        ),
      );

      uploadTask.snapshotEvents.listen(
        (TaskSnapshot snapshot) {
          if (snapshot.totalBytes > 0) {
            final progress =
                (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
            print('Upload progress: ${progress.toStringAsFixed(1)}%');
          }
        },
        onError: (error) {
          print('Upload progress error: $error');
        },
      );

      print('Waiting for upload to complete...');
      final TaskSnapshot snapshot = await uploadTask.whenComplete(() {
        print('Upload task completed');
      });

      if (snapshot.state == TaskState.success) {
        print(
          'Upload completed successfully. Bytes transferred: ${snapshot.totalBytes}',
        );

        print('Getting download URL...');
        final String downloadUrl = await snapshot.ref.getDownloadURL();

        print('KYC document uploaded successfully to: $downloadUrl');
        return downloadUrl;
      } else if (snapshot.state == TaskState.error) {
        throw Exception('Upload failed with state: ${snapshot.state}');
      } else {
        throw Exception('Upload incomplete. State: ${snapshot.state}');
      }
    } catch (e, stackTrace) {
      print('Error uploading KYC document: $e');
      print('Stack trace: $stackTrace');

      if (e is FirebaseException) {
        print('Firebase error code: ${e.code}');
        print('Firebase error message: ${e.message}');
        throw Exception('Upload failed. Please check your internet connection and try again.');
      }

      if (e.toString().contains('404') || e.toString().contains('Not Found')) {
        throw Exception('Upload failed. Service unavailable.');
      }

      throw Exception('An unexpected error occurred during upload. Please try again.');
    }
  }
}
