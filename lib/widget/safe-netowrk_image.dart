import 'package:flutter/material.dart';

/// Widget آمن لتحميل الصور من الإنترنت مع معالجة الأخطاء
class SafeNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const SafeNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // إذا لم يكن هناك URL، عرض صورة بديلة
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildErrorWidget();
    }

    // إذا كان URL غير صحيح (لا يبدأ بـ http)
    if (!imageUrl!.startsWith('http://') && !imageUrl!.startsWith('https://')) {
      return _buildErrorWidget();
    }

    Widget imageWidget = Image.network(
      imageUrl!,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        // تسجيل الخطأ للتشخيص
        debugPrint('Image load error: $imageUrl');
        debugPrint('Error: $error');
        return _buildErrorWidget();
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return _buildPlaceholder();
      },
      // إعادة المحاولة عند الفشل
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        }
        if (frame == null) {
          return _buildPlaceholder();
        }
        return child;
      },
    );

    // إضافة BorderRadius إذا كان موجوداً
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildErrorWidget() {
    if (errorWidget != null) {
      return errorWidget!;
    }
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade300,
      child: Icon(
        Icons.person,
        size: (height != null && height! < 100) ? height! * 0.5 : 50,
        color: Colors.grey.shade600,
      ),
    );
  }

  Widget _buildPlaceholder() {
    if (placeholder != null) {
      return placeholder!;
    }
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: Center(
        child: CircularProgressIndicator(
          color: Colors.teal,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

/// CircleAvatar آمن لتحميل الصور من الإنترنت
class SafeCircleAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final Color? backgroundColor;
  final IconData fallbackIcon;
  final Color? fallbackIconColor;

  const SafeCircleAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 30,
    this.backgroundColor,
    this.fallbackIcon = Icons.person,
    this.fallbackIconColor,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.grey.shade200,
      child: imageUrl != null && 
             imageUrl!.isNotEmpty && 
             (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://'))
          ? ClipOval(
              child: SafeNetworkImage(
                imageUrl: imageUrl,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorWidget: Icon(
                  fallbackIcon,
                  size: radius * 0.8,
                  color: fallbackIconColor ?? Colors.grey.shade600,
                ),
              ),
            )
          : Icon(
              fallbackIcon,
              size: radius * 0.8,
              color: fallbackIconColor ?? Colors.grey.shade600,
            ),
    );
  }
}
