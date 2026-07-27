import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'tap_wrapper.dart';

class CachedImage extends StatelessWidget {
  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.borderRadius = 0,
    this.errorWidget,
    this.headers,
    this.placeholder,
    this.showImageOnTap = false,
    this.hasAnimation = false,
  });
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final double borderRadius;
  final bool hasAnimation;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool showImageOnTap;
  final Map<String, String>? headers;

  ExtendedNetworkImageProvider provider() {
    return ExtendedNetworkImageProvider(imageUrl ?? '', printError: false);
  }

  Widget _wImage(BuildContext context) {
    // Check if imageUrl is valid
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildErrorWidget();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: kIsWeb
          ? Image.network(
              imageUrl!,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildPlaceholder();
              },
            )
          : ExtendedImage.network(
              imageUrl!,
              maxBytes: 2 * 1024 * 1024, // Increased to 2MB
              width: width,
              height: height,
              headers: headers,
              fit: fit,
              cache: true,
              retries: 3,
              timeLimit: const Duration(seconds: 10),
              loadStateChanged: (ExtendedImageState state) {
                switch (state.extendedImageLoadState) {
                  case LoadState.loading:
                    return _buildPlaceholder();
                  case LoadState.completed:
                    return TapWrapper(
                      onTap: showImageOnTap ? () {} : null,
                      child: ExtendedRawImage(
                        image: state.extendedImageInfo?.image,
                        width: width,
                        height: height,
                        fit: fit,
                      ),
                    );
                  case LoadState.failed:
                    state.imageProvider.evict();
                    return _buildErrorWidget();
                }
              },
            ),
    );
  }

  Widget _buildPlaceholder() {
    return placeholder ??
        Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
          ),
        );
  }

  Widget _buildErrorWidget() {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Icon(
            Icons.image_not_supported,
            color: Colors.grey.shade400,
            size: (height != null && height! < 50) ? 16 : 24,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return hasAnimation && imageUrl != null
        ? Hero(tag: imageUrl!, child: _wImage(context))
        : _wImage(context);
  }
}
