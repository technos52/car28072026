import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/widgets/admin_layout.dart';
import '../../routes/app_routes.dart';

class KycPage extends StatefulWidget {
  const KycPage({super.key});

  @override
  State<KycPage> createState() => _KycPageState();
}

class _KycPageState extends State<KycPage> {
  final AdminService _adminService = AdminService();
  List<Map<String, dynamic>> _users = [];
  Map<String, Map<String, dynamic>> _kycMap = {};
  bool _isLoading = true;
  String _filterStatus = 'pending';

  @override
  void initState() {
    super.initState();
    _loadKycData();
  }

  Future<void> _loadKycData() async {
    setState(() => _isLoading = true);
    final users = await _adminService.getAllUsers();
    final kycMap = <String, Map<String, dynamic>>{};

    for (var user in users) {
      final kyc = await _adminService.getKycDocument(user['id']);
      if (kyc != null) {
        kycMap[user['id']] = kyc;
      }
    }

    setState(() {
      _users = users;
      _kycMap = kycMap;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredUsers {
    return _users.where((user) {
      final userId = user['id'];
      final kyc = _kycMap[userId];
      if (kyc == null) return false;
      if (_filterStatus == 'pending') {
        return kyc['isVerified'] != true;
      } else if (_filterStatus == 'verified') {
        return kyc['isVerified'] == true;
      }
      return true;
    }).toList();
  }

  Future<void> _verifyKyc(String userId, bool isVerified) async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    
    try {
      await _adminService.verifyKycAndNotify(userId, isVerified);
      Get.back();
      Get.snackbar(
        'Success',
        isVerified 
          ? 'KYC verified successfully. User has been notified.' 
          : 'KYC verification removed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      _loadKycData();
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error', 
        'Failed to update KYC: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: AppRoutes.kyc,
      title: 'KYC Verification',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadKycData,
        ),
      ],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Pending'),
                    selected: _filterStatus == 'pending',
                    onSelected: (selected) {
                      if (selected) setState(() => _filterStatus = 'pending');
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Verified'),
                    selected: _filterStatus == 'verified',
                    onSelected: (selected) {
                      if (selected) setState(() => _filterStatus = 'verified');
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: _filterStatus == 'all',
                    onSelected: (selected) {
                      if (selected) setState(() => _filterStatus = 'all');
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? const Center(child: Text('No KYC documents found'))
                    : ListView.builder(
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          final kyc = _kycMap[user['id']];
                          final isVerified = kyc?['isVerified'] == true;
                          
                          // Try multiple possible field name formats
                          final panPath = (kyc?['panPath'] ?? kyc?['pan_path'] ?? '').toString().trim();
                          final aadhaarPath = (kyc?['aadhaarPath'] ?? kyc?['aadhaar_path'] ?? '').toString().trim();
                          final addressProofPath = (kyc?['addressProofPath'] ?? kyc?['address_proof_path'] ?? '').toString().trim();
                          
                          final hasPan = panPath.isNotEmpty && panPath.startsWith('http');
                          final hasAadhaar = aadhaarPath.isNotEmpty && aadhaarPath.startsWith('http');
                          final hasAddress = addressProofPath.isNotEmpty && addressProofPath.startsWith('http');
                          final allDocsSubmitted = hasPan && hasAadhaar && hasAddress;
                          
                          // Debug: Print KYC data
                          print('KYC for ${user['name']}: panPath=$panPath, aadhaarPath=$aadhaarPath, addressProofPath=$addressProofPath');
                          print('KYC full data: $kyc');
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Theme(
                              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                                initiallyExpanded: false,
                                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                childrenPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: isVerified
                                    ? Colors.green.shade100
                                    : Colors.orange.shade100,
                                child: Icon(
                                  isVerified ? Icons.verified : Icons.pending,
                                  color: isVerified ? Colors.green : Colors.orange,
                                ),
                              ),
                              title: Text(user['name'] ?? 'Unknown'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user['email'] ?? ''),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      if (hasPan)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade100,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'PAN',
                                            style: TextStyle(fontSize: 10, color: Colors.blue.shade800),
                                          ),
                                        ),
                                      if (hasPan && hasAadhaar) const SizedBox(width: 4),
                                      if (hasAadhaar)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade100,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'Aadhaar',
                                            style: TextStyle(fontSize: 10, color: Colors.green.shade800),
                                          ),
                                        ),
                                      if ((hasPan || hasAadhaar) && hasAddress) const SizedBox(width: 4),
                                      if (hasAddress)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.purple.shade100,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'Address',
                                            style: TextStyle(fontSize: 10, color: Colors.purple.shade800),
                                          ),
                                        ),
                                      if (!allDocsSubmitted)
                                        Container(
                                          margin: const EdgeInsets.only(left: 4),
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade100,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'Incomplete',
                                            style: TextStyle(fontSize: 10, color: Colors.red.shade800),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: isVerified
                                  ? const Chip(
                                      label: Text('Verified'),
                                      backgroundColor: Colors.green,
                                      labelStyle: TextStyle(color: Colors.white),
                                    )
                                  : const Chip(
                                      label: Text('Pending'),
                                      backgroundColor: Colors.orange,
                                      labelStyle: TextStyle(color: Colors.white),
                                    ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'KYC Documents',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      if (!allDocsSubmitted)
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          margin: const EdgeInsets.only(bottom: 16),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.shade50,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.orange.shade200),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.warning_rounded, color: Colors.orange.shade700, size: 20),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'Some documents are missing. Please ensure all documents are submitted before verification.',
                                                  style: TextStyle(
                                                    color: Colors.orange.shade900,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          final isWide = constraints.maxWidth > 800;
                                          return isWide
                                              ? Row(
                                        children: [
                                          Expanded(
                                            child: _DocumentCard(
                                              title: 'PAN Card',
                                                        imageUrl: panPath.isNotEmpty ? panPath : null,
                                              icon: Icons.credit_card_rounded,
                                              color: const Color(0xFF3B82F6),
                                                        isSubmitted: hasPan,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: _DocumentCard(
                                              title: 'Aadhaar Card',
                                                        imageUrl: aadhaarPath.isNotEmpty ? aadhaarPath : null,
                                              icon: Icons.badge_rounded,
                                              color: const Color(0xFF10B981),
                                                        isSubmitted: hasAadhaar,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: _DocumentCard(
                                              title: 'Address Proof',
                                                        imageUrl: addressProofPath.isNotEmpty ? addressProofPath : null,
                                              icon: Icons.home_rounded,
                                              color: const Color(0xFF8B5CF6),
                                                        isSubmitted: hasAddress,
                                            ),
                                          ),
                                        ],
                                                )
                                              : Column(
                                                  children: [
                                                    _DocumentCard(
                                                      title: 'PAN Card',
                                                      imageUrl: panPath.isNotEmpty ? panPath : null,
                                                      icon: Icons.credit_card_rounded,
                                                      color: const Color(0xFF3B82F6),
                                                      isSubmitted: hasPan,
                                                    ),
                                                    const SizedBox(height: 16),
                                                    _DocumentCard(
                                                      title: 'Aadhaar Card',
                                                      imageUrl: aadhaarPath.isNotEmpty ? aadhaarPath : null,
                                                      icon: Icons.badge_rounded,
                                                      color: const Color(0xFF10B981),
                                                      isSubmitted: hasAadhaar,
                                                    ),
                                                    const SizedBox(height: 16),
                                                    _DocumentCard(
                                                      title: 'Address Proof',
                                                      imageUrl: addressProofPath.isNotEmpty ? addressProofPath : null,
                                                      icon: Icons.home_rounded,
                                                      color: const Color(0xFF8B5CF6),
                                                      isSubmitted: hasAddress,
                                                    ),
                                                  ],
                                                );
                                        },
                                      ),
                                      const SizedBox(height: 24),
                                      Wrap(
                                        spacing: 12,
                                        runSpacing: 12,
                                        alignment: WrapAlignment.center,
                                        children: [
                                          if (!isVerified)
                                            ElevatedButton.icon(
                                              onPressed: allDocsSubmitted
                                                  ? () => _verifyKyc(user['id'], true)
                                                  : null,
                                              icon: const Icon(Icons.check_circle_rounded),
                                              label: const Text('Verify KYC'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: allDocsSubmitted
                                                    ? const Color(0xFF10B981)
                                                    : Colors.grey,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 24,
                                                  vertical: 14,
                                                ),
                                              ),
                                            ),
                                          if (isVerified)
                                            ElevatedButton.icon(
                                              onPressed: () =>
                                                  _verifyKyc(user['id'], false),
                                              icon: const Icon(Icons.cancel_rounded),
                                              label: const Text('Unverify'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFFF59E0B),
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 24,
                                                  vertical: 14,
                                                ),
                                              ),
                                            ),
                                          OutlinedButton.icon(
                                            onPressed: () {
                                              Get.toNamed(
                                                AppRoutes.userDetail.replaceAll(
                                                    ':id', user['id']),
                                              );
                                            },
                                            icon: const Icon(Icons.person_rounded),
                                            label: const Text('View User'),
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 24,
                                                vertical: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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

class _DocumentCard extends StatefulWidget {
  final String title;
  final String? imageUrl;
  final IconData icon;
  final Color color;
  final bool isSubmitted;

  const _DocumentCard({
    required this.title,
    required this.imageUrl,
    required this.icon,
    required this.color,
    this.isSubmitted = false,
  });

  @override
  State<_DocumentCard> createState() => _DocumentCardState();
}

class _DocumentCardState extends State<_DocumentCard> {
  bool _isHovered = false;
  OverlayEntry? _previewOverlay;

  void _showHoverPreview() {
    if (widget.imageUrl == null || widget.imageUrl!.isEmpty) return;
    if (_previewOverlay != null) return;

    final overlayState = Overlay.of(context);

    final isPdf = widget.imageUrl!.toLowerCase().endsWith('.pdf') || 
                  widget.imageUrl!.contains('.pdf?');

    _previewOverlay = OverlayEntry(
      builder: (context) => Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            GestureDetector(
              onTap: _hideHoverPreview,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Center(
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 200),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.8 + (0.2 * value),
                    child: Opacity(
                      opacity: value,
                      child: Container(
                        width: 800,
                        height: 600,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3 * value),
                              blurRadius: 40,
                              spreadRadius: 10,
                              offset: Offset(0, 20 * value),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            children: [
                              if (isPdf)
                                _buildPdfPreview()
                              else
                                _buildImagePreview(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

    overlayState.insert(_previewOverlay!);
  }

  Widget _buildPdfPreview() {
    final String viewId = 'pdf-preview-${widget.imageUrl.hashCode}-${DateTime.now().millisecondsSinceEpoch}';
    
    html.IFrameElement iframe = html.IFrameElement()
      ..src = '${widget.imageUrl}#toolbar=1&navpanes=1&scrollbar=1'
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..allowFullscreen = true
      ..setAttribute('allow', 'fullscreen');
    
    ui_web.platformViewRegistry.registerViewFactory(
      viewId,
      (int viewId) => iframe,
    );
    
    return HtmlElementView(viewType: viewId);
  }

  Widget _buildImagePreview() {
    final imageUrl = widget.imageUrl;
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        color: Colors.grey.shade900,
        child: const Center(
          child: Text(
            'No image URL',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: Center(
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
              color: Colors.grey.shade900,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                  color: Colors.white,
                            ),
                          ),
                        );
                      },
          errorBuilder: (context, error, stackTrace) {
            print('Preview image error: $error');
            print('Preview image URL: $imageUrl');
            return Container(
              color: Colors.grey.shade900,
              child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.white70),
                    const SizedBox(height: 8),
                    const Text(
                      'Failed to load image',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        imageUrl.length > 80 ? '${imageUrl.substring(0, 80)}...' : imageUrl,
                        style: const TextStyle(color: Colors.white54, fontSize: 10),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _hideHoverPreview() {
    if (_previewOverlay != null) {
      _previewOverlay!.remove();
      _previewOverlay = null;
    }
  }

  @override
  void dispose() {
    _hideHoverPreview();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
          if (_previewOverlay == null) {
            _showHoverPreview();
          } else {
            _hideHoverPreview();
          }
        }
      },
      child: MouseRegion(
        onEnter: (_) {
          setState(() => _isHovered = true);
        },
        onExit: (_) {
          setState(() => _isHovered = false);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? widget.color
                  : Colors.grey.shade200,
              width: _isHovered ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? widget.color.withOpacity(0.2)
                    : Colors.black.withOpacity(0.05),
                blurRadius: _isHovered ? 12 : 6,
                offset: Offset(0, _isHovered ? 6 : 2),
                spreadRadius: _isHovered ? 2 : 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.color.withOpacity(0.1),
                      widget.color.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: widget.color,
                          letterSpacing: 0.2,
                        ),
                          ),
                          const SizedBox(width: 8),
                          if (widget.isSubmitted)
                            Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: Colors.green.shade700,
                            )
                          else
                            Icon(
                              Icons.cancel_rounded,
                              size: 16,
                              color: Colors.red.shade700,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.imageUrl == null || widget.imageUrl!.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported_rounded,
                          size: 32,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No document',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.imageUrl!.toLowerCase().endsWith('.pdf') || 
                          widget.imageUrl!.contains('.pdf?')
                              ? Icons.picture_as_pdf_rounded
                              : Icons.image_rounded,
                          color: widget.color,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Click to view document',
                          style: TextStyle(
                            color: widget.color,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
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

