import 'package:flutter/material.dart';

// Notification types enum
enum NotificationType { success, error, warning }

// Notification service class
class NotificationService {
  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;

  static void show({
    required BuildContext context,
    required String message,
    required NotificationType type,
    Duration duration = const Duration(seconds: 5),
    String? title,
  }) {
    if (_isShowing) {
      hide();
    }

    _overlayEntry = _createOverlayEntry(
      message: message,
      type: type,
      title: title,
    );

    Overlay.of(context).insert(_overlayEntry!);
    _isShowing = true;

    // Auto hide after duration
    Future.delayed(duration, () {
      hide();
    });
  }

  static void hide() {
    if (_overlayEntry != null && _isShowing) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      _isShowing = false;
    }
  }

  static OverlayEntry _createOverlayEntry({
    required String message,
    required NotificationType type,
    String? title,
  }) {
    return OverlayEntry(
      builder:
          (context) => NotificationBanner(
            message: message,
            type: type,
            title: title,
            onDismiss: hide,
          ),
    );
  }
}

// Notification banner widget
class NotificationBanner extends StatefulWidget {
  final String message;
  final NotificationType type;
  final String? title;
  final VoidCallback onDismiss;

  const NotificationBanner({
    super.key,
    required this.message,
    required this.type,
    required this.onDismiss,
    this.title,
  });

  @override
  State<NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<NotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case NotificationType.success:
        return const Color(0xFF4CAF50);
      case NotificationType.error:
        return const Color(0xFFF44336);
      case NotificationType.warning:
        return const Color(0xFFFF9800);
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.warning:
        return Icons.warning;
    }
  }

  String _getDefaultTitle() {
    switch (widget.type) {
      case NotificationType.success:
        return 'Success';
      case NotificationType.error:
        return 'Error';
      case NotificationType.warning:
        return 'Warning';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(_getIcon(), color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title ?? _getDefaultTitle(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onDismiss,
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Extension for easy access
extension NotificationExtension on BuildContext {
  void showSuccessNotification(String message, {String? title}) {
    NotificationService.show(
      context: this,
      message: message,
      type: NotificationType.success,
      title: title,
    );
  }

  void showErrorNotification(String message, {String? title}) {
    NotificationService.show(
      context: this,
      message: message,
      type: NotificationType.error,
      title: title,
    );
  }

  void showWarningNotification(String message, {String? title}) {
    NotificationService.show(
      context: this,
      message: message,
      type: NotificationType.warning,
      title: title,
    );
  }
}
