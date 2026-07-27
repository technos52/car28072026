import 'dart:html' as html;
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/widgets/admin_layout.dart';
import '../../routes/app_routes.dart';

class CarouselImagesPage extends StatefulWidget {
  const CarouselImagesPage({super.key});

  @override
  State<CarouselImagesPage> createState() => _CarouselImagesPageState();
}

class _CarouselImagesPageState extends State<CarouselImagesPage> {
  final AdminService _adminService = AdminService();
  List<Map<String, dynamic>> _images = [];
  bool _isLoading = true;
  bool _isUploading = false;
  String? _uploadingImageId;
  final Map<String, double> _uploadProgress = {};
  int _totalUploading = 0;
  int _completedUploads = 0;
  int _failedUploads = 0;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    setState(() => _isLoading = true);
    try {
      final images = await _adminService.getCarouselImages();
      print('Loaded ${images.length} carousel images');
      for (var img in images) {
        print('Image ID: ${img['id']}, URL: ${img['imageUrl']}');
      }
      setState(() {
        _images = images;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading images: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to load images: $e',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  bool _validateFile(html.File file) {
    const maxSizeInMB = 5;
    const maxSizeInBytes = maxSizeInMB * 1024 * 1024;
    
    if (file.size > maxSizeInBytes) {
      Get.snackbar(
        'File Too Large',
        'Image size must be less than $maxSizeInMB MB. Current size: ${(file.size / 1024 / 1024).toStringAsFixed(2)} MB',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return false;
    }

    final extension = file.name.split('.').last.toLowerCase();
    const allowedExtensions = ['jpg', 'jpeg', 'png', 'webp', 'gif'];
    if (!allowedExtensions.contains(extension)) {
      Get.snackbar(
        'Invalid File Type',
        'Please upload an image file (JPG, PNG, WEBP, or GIF)',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  Future<void> _uploadImage({String? replaceImageId}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar(
        'Authentication Required',
        'Please log in to upload images',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.multiple = false;
    uploadInput.click();

    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;
      if (files == null || files.isEmpty) return;

      final file = files[0];
      
      if (!_validateFile(file)) {
        return;
      }

      final reader = html.FileReader();

      reader.onLoadEnd.listen((e) async {
        try {
          setState(() {
            _isUploading = true;
            _uploadingImageId = replaceImageId;
          });

          final bytes = reader.result as Uint8List;
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileName = 'carousel_${timestamp}_${file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_')}';
          final ref = FirebaseStorage.instance.ref().child('carousel_images/$fileName');

          final extension = file.name.split('.').last.toLowerCase();
          String contentType = 'image/jpeg';
          if (extension == 'png') contentType = 'image/png';
          else if (extension == 'webp') contentType = 'image/webp';
          else if (extension == 'gif') contentType = 'image/gif';

          final uploadTask = ref.putData(
            bytes,
            SettableMetadata(contentType: contentType),
          );

          await uploadTask;
          final downloadUrl = await ref.getDownloadURL();

          if (replaceImageId != null) {
            final oldImage = _images.firstWhere(
              (img) => img['id'] == replaceImageId,
              orElse: () => {},
            );
            final oldImageUrl = oldImage['imageUrl'] as String?;
            
            await _adminService.updateCarouselImage(replaceImageId, downloadUrl);
            
            if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
              try {
                final oldRef = FirebaseStorage.instance.refFromURL(oldImageUrl);
                await oldRef.delete();
              } catch (e) {
                print('Error deleting old image from storage: $e');
              }
            }
          } else {
            await _adminService.uploadCarouselImage(downloadUrl);
          }

          await _loadImages();

          if (mounted) {
            Get.snackbar(
              'Success',
              replaceImageId != null 
                ? 'Image replaced successfully' 
                : 'Image uploaded successfully',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          }
        } catch (e) {
          String errorMessage = 'Failed to upload image';
          if (e.toString().contains('unauthorized')) {
            errorMessage = 'Permission denied. Please ensure you are logged in as an admin.';
          } else if (e.toString().contains('network')) {
            errorMessage = 'Network error. Please check your connection and try again.';
          } else {
            errorMessage = 'Failed to upload image: ${e.toString()}';
          }
          
          if (mounted) {
            Get.snackbar(
              'Error',
              errorMessage,
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red,
              colorText: Colors.white,
              duration: const Duration(seconds: 5),
            );
          }
        } finally {
          if (mounted) {
            setState(() {
              _isUploading = false;
              _uploadingImageId = null;
            });
          }
        }
      });

      reader.readAsArrayBuffer(file);
    });
  }

  Future<void> _uploadMultipleImages() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar(
        'Authentication Required',
        'Please log in to upload images',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.multiple = true;
    uploadInput.click();

    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;
      if (files == null || files.isEmpty) return;

      // Validate all files first
      final validFiles = <html.File>[];
      for (var i = 0; i < files.length; i++) {
        final file = files[i];
        if (_validateFile(file)) {
          validFiles.add(file);
        }
      }

      if (validFiles.isEmpty) {
        Get.snackbar(
          'No Valid Files',
          'Please select valid image files (JPG, PNG, WEBP, GIF, max 5MB each)',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      setState(() {
        _isUploading = true;
        _totalUploading = validFiles.length;
        _completedUploads = 0;
        _failedUploads = 0;
        _uploadProgress.clear();
      });

      // Upload all files
      for (var i = 0; i < validFiles.length; i++) {
        final file = validFiles[i];
        final fileName = file.name;
        _uploadProgress[fileName] = 0.0;

        _uploadSingleFileFromMultiple(file, i, validFiles.length);
      }
    });
  }

  Future<void> _uploadSingleFileFromMultiple(html.File file, int index, int totalFiles) async {
    final fileName = file.name;
    
    try {
      final reader = html.FileReader();
      final completer = Completer<void>();
      
      reader.onLoadEnd.listen((e) async {
        try {
          final bytes = reader.result as Uint8List;
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final safeFileName = 'carousel_${timestamp}_${index}_${file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_')}';
          final ref = FirebaseStorage.instance.ref().child('carousel_images/$safeFileName');

          final extension = file.name.split('.').last.toLowerCase();
          String contentType = 'image/jpeg';
          if (extension == 'png') contentType = 'image/png';
          else if (extension == 'webp') contentType = 'image/webp';
          else if (extension == 'gif') contentType = 'image/gif';

          final uploadTask = ref.putData(
            bytes,
            SettableMetadata(contentType: contentType),
          );

          // Track upload progress
          uploadTask.snapshotEvents.listen((snapshot) {
            final progress = snapshot.bytesTransferred / snapshot.totalBytes;
            if (mounted) {
              setState(() {
                _uploadProgress[fileName] = progress;
              });
            }
          });

          await uploadTask;
          final downloadUrl = await ref.getDownloadURL();
          await _adminService.uploadCarouselImage(downloadUrl);

          if (mounted) {
            setState(() {
              _completedUploads++;
              _uploadProgress[fileName] = 1.0;
            });
            _checkAllUploadsComplete();
          }
        } catch (e) {
          print('Error uploading $fileName: $e');
          if (mounted) {
            setState(() {
              _failedUploads++;
              _uploadProgress.remove(fileName);
            });
            _checkAllUploadsComplete();
          }
        } finally {
          if (!completer.isCompleted) {
            completer.complete();
          }
        }
      });
      
      reader.readAsArrayBuffer(file);
      await completer.future;
    } catch (e) {
      print('Error processing $fileName: $e');
      if (mounted) {
        setState(() {
          _failedUploads++;
          _uploadProgress.remove(fileName);
        });
        _checkAllUploadsComplete();
      }
    }
  }

  void _checkAllUploadsComplete() {
    if ((_completedUploads + _failedUploads) >= _totalUploading && _totalUploading > 0) {
      _finalizeMultipleUpload();
    }
  }

  Future<void> _finalizeMultipleUpload() async {
    if (!mounted) return;
    
    final successCount = _completedUploads;
    final failCount = _failedUploads;
    
    await _loadImages();
    
    setState(() {
      _isUploading = false;
      _totalUploading = 0;
      _uploadProgress.clear();
    });

    if (failCount == 0) {
      Get.snackbar(
        'Success',
        'Successfully uploaded $successCount image${successCount > 1 ? 's' : ''}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Upload Complete',
        'Uploaded $successCount image${successCount > 1 ? 's' : ''}, $failCount failed',
        snackPosition: SnackPosition.TOP,
        backgroundColor: failCount == _totalUploading ? Colors.red : Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
    
    setState(() {
      _completedUploads = 0;
      _failedUploads = 0;
    });
  }

  Future<void> _replaceImage(String imageId) async {
    await _uploadImage(replaceImageId: imageId);
  }

  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.9,
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 400,
                          color: Colors.grey.shade100,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 400,
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 48, color: Colors.red),
                              SizedBox(height: 8),
                              Text('Failed to load image'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: Material(
                color: Colors.black.withOpacity(0.5),
                shape: const CircleBorder(),
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteImage(String imageId, String imageUrl) async {
    if (_images.length <= 1) {
      Get.snackbar(
        'Cannot Delete',
        'You must have at least one carousel image',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Image'),
        content: const Text('Are you sure you want to delete this image? This action cannot be undone.'),
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

    if (confirmed != true) return;

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await _adminService.deleteCarouselImage(imageId);
      
      if (imageUrl.isNotEmpty) {
        try {
          final ref = FirebaseStorage.instance.refFromURL(imageUrl);
          await ref.delete();
        } catch (e) {
          print('Error deleting from storage: $e');
        }
      }

      Get.back();

      await _loadImages();

      if (mounted) {
        Get.snackbar(
          'Success',
          'Image deleted successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back();
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to delete image: $e',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: AppRoutes.carouselImages,
      title: 'Carousel Images',
      actions: [
        if (_isUploading && _uploadingImageId == null && _totalUploading > 0)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Uploading: $_completedUploads/$_totalUploading',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 100,
                  height: 4,
                  child: LinearProgressIndicator(
                    value: _totalUploading > 0 
                        ? (_completedUploads + _failedUploads) / _totalUploading 
                        : 0,
                    backgroundColor: Colors.grey[300],
                  ),
                ),
              ],
            ),
          )
        else if (_isUploading && _uploadingImageId == null)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (!_isUploading)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.add_photo_alternate_rounded),
                onPressed: () => _uploadImage(),
                tooltip: 'Add Single Image',
              ),
              IconButton(
                icon: const Icon(Icons.collections_rounded),
                onPressed: () => _uploadMultipleImages(),
                tooltip: 'Add Multiple Images',
              ),
            ],
          ),
      ],
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6366F1).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.image_rounded,
                                  color: Color(0xFF6366F1),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Carousel Images',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Manage images displayed below brand chips on home page. Max file size: 5MB',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _images.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported_rounded,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No carousel images yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: _isUploading ? null : () => _uploadImage(),
                                    icon: const Icon(Icons.add_photo_alternate_rounded),
                                    label: const Text('Add Single Image'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton.icon(
                                    onPressed: _isUploading ? null : () => _uploadMultipleImages(),
                                    icon: const Icon(Icons.collections_rounded),
                                    label: const Text('Add Multiple Images'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _images.length,
                          itemBuilder: (context, index) {
                            final image = _images[index];
                            final imageId = image['id'] as String;
                            final imageUrl = (image['imageUrl'] as String? ?? 
                                             image['url'] as String? ?? 
                                             image['downloadUrl'] as String? ?? '').trim();
                            final isUploading = _isUploading && _uploadingImageId == imageId;
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: isUploading
                                    ? const SizedBox(
                                        width: 48,
                                        height: 48,
                                        child: CircularProgressIndicator(),
                                      )
                                    : Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.image_rounded,
                                          color: Colors.grey,
                                          size: 28,
                                        ),
                                      ),
                                title: Text(
                                  'Carousel Image ${index + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: imageUrl.isNotEmpty
                                    ? Text(
                                        imageUrl.length > 60 
                                            ? '${imageUrl.substring(0, 60)}...' 
                                            : imageUrl,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : const Text(
                                        'No image URL',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                trailing: isUploading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit_rounded),
                                            color: Colors.blue,
                                            onPressed: () => _replaceImage(imageId),
                                            tooltip: 'Replace',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_rounded),
                                            color: Colors.red,
                                            onPressed: () => _deleteImage(imageId, imageUrl),
                                            tooltip: 'Delete',
                                          ),
                                        ],
                                      ),
                                onTap: imageUrl.isNotEmpty && !isUploading
                                    ? () => _showFullImage(imageUrl)
                                    : null,
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}
