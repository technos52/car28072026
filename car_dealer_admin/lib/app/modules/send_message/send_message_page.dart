import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/widgets/admin_layout.dart';
import '../../routes/app_routes.dart';

class SendMessagePage extends StatefulWidget {
  final String? userId;
  final String? userName;

  const SendMessagePage({
    super.key,
    this.userId,
    this.userName,
  });

  @override
  State<SendMessagePage> createState() => _SendMessagePageState();
}

class _SendMessagePageState extends State<SendMessagePage> {
  final AdminService _adminService = AdminService();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _buttonTextController = TextEditingController();
  final _buttonActionController = TextEditingController();

  String? _imageUrl;
  bool _isUploading = false;
  bool _isSending = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _buttonTextController.dispose();
    _buttonActionController.dispose();
    super.dispose();
  }

  Future<void> _uploadImage() async {
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
    uploadInput.click();

    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;
      if (files == null || files.isEmpty) return;

      final file = files[0];
      const maxSizeInMB = 5;
      const maxSizeInBytes = maxSizeInMB * 1024 * 1024;

      if (file.size > maxSizeInBytes) {
        Get.snackbar(
          'File Too Large',
          'Image size must be less than $maxSizeInMB MB',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      setState(() => _isUploading = true);

      try {
        final reader = html.FileReader();
        reader.onLoadEnd.listen((e) async {
          try {
            final bytes = reader.result as Uint8List;
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final fileName = 'message_${timestamp}_${file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_')}';
            final ref = FirebaseStorage.instance.ref().child('message_images/$fileName');

            final extension = file.name.split('.').last.toLowerCase();
            String contentType = 'image/jpeg';
            if (extension == 'png') contentType = 'image/png';
            else if (extension == 'webp') contentType = 'image/webp';
            else if (extension == 'gif') contentType = 'image/gif';

            await ref.putData(bytes, SettableMetadata(contentType: contentType));
            final downloadUrl = await ref.getDownloadURL();

            setState(() {
              _imageUrl = downloadUrl;
              _isUploading = false;
            });

            Get.snackbar(
              'Success',
              'Image uploaded successfully',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          } catch (e) {
            setState(() => _isUploading = false);
            Get.snackbar(
              'Error',
              'Failed to upload image: $e',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        });

        reader.readAsArrayBuffer(file);
      } catch (e) {
        setState(() => _isUploading = false);
        Get.snackbar(
          'Error',
          'Failed to upload image: $e',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    try {
      final result = widget.userId != null
          ? await _adminService.sendIndividualMessage(
              userId: widget.userId!,
              title: _titleController.text.trim(),
              message: _messageController.text.trim(),
              imageUrl: _imageUrl,
              buttonText: _buttonTextController.text.trim().isEmpty
                  ? null
                  : _buttonTextController.text.trim(),
              buttonAction: _buttonActionController.text.trim().isEmpty
                  ? null
                  : _buttonActionController.text.trim(),
            )
          : await _adminService.sendBroadcastMessage(
              title: _titleController.text.trim(),
              message: _messageController.text.trim(),
              imageUrl: _imageUrl,
              buttonText: _buttonTextController.text.trim().isEmpty
                  ? null
                  : _buttonTextController.text.trim(),
              buttonAction: _buttonActionController.text.trim().isEmpty
                  ? null
                  : _buttonActionController.text.trim(),
            );

      setState(() => _isSending = false);

      if (result['success'] == true) {
        // Clear the form fields upon success
        _titleController.clear();
        _messageController.clear();
        _buttonTextController.clear();
        _buttonActionController.clear();
        setState(() {
          _imageUrl = null;
        });

        Get.snackbar(
          'Success',
          result['message'] ?? 'Message sent successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        
        // Only navigate back if we were sending a targeted individual message (likely opened in a dialog/new page)
        if (widget.userId != null) {
          Get.back();
        }
      } else {
        Get.snackbar(
          'Error',
          result['error'] ?? 'Failed to send message',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      setState(() => _isSending = false);
      Get.snackbar(
        'Error',
        'Failed to send message: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIndividual = widget.userId != null;

    return AdminLayout(
      currentRoute: AppRoutes.sendMessage,
      title: isIndividual ? 'Send Message to ${widget.userName ?? "User"}' : 'Send Message to All Users',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
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
                              Icons.message_rounded,
                              color: Color(0xFF6366F1),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isIndividual
                                      ? 'Send Message to User'
                                      : 'Broadcast Message',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isIndividual
                                      ? 'Send a personalized message to this user'
                                      : 'Send a message to all users in the system',
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title *',
                          hintText: 'Enter message title',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title_rounded),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          labelText: 'Message *',
                          hintText: 'Enter your message',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.message_rounded),
                        ),
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a message';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      // Image upload section
                      const Text(
                        'Image (Optional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_imageUrl != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  _imageUrl!,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Material(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: const CircleBorder(),
                                  child: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.white),
                                    onPressed: () {
                                      setState(() => _imageUrl = null);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ElevatedButton.icon(
                        onPressed: _isUploading ? null : _uploadImage,
                        icon: _isUploading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.image_rounded),
                        label: Text(_imageUrl != null ? 'Change Image' : 'Upload Image'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Button section
                      const Text(
                        'Action Button (Optional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _buttonTextController,
                        decoration: const InputDecoration(
                          labelText: 'Button Text',
                          hintText: 'e.g., View Details, Learn More',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.label_rounded),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _buttonActionController,
                        decoration: const InputDecoration(
                          labelText: 'Button Action',
                          hintText: 'e.g., /home, https://example.com, or route name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.open_in_new_rounded),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSending ? null : _sendMessage,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                          ),
                          child: _isSending
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  isIndividual ? 'Send Message' : 'Send to All Users',
                                  style: const TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

