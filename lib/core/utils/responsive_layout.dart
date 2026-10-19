import 'package:flutter/material.dart';

enum DeviceScreenType {
  compact, // < 600px (Mobile, e.g. 360px)
  medium, // 600px - 1023px (Tablet, e.g. 600px)
  expanded, // >= 1024px (Desktop, e.g. 1280px)
}

class ResponsiveLayout extends StatelessWidget {
  final Widget Function(BuildContext context) compact;
  final Widget Function(BuildContext context)? medium;
  final Widget Function(BuildContext context)? expanded;

  const ResponsiveLayout({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
  });

  static DeviceScreenType getDeviceType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 600) return DeviceScreenType.compact;
    if (width < 1024) return DeviceScreenType.medium;
    return DeviceScreenType.expanded;
  }

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 600;

  static bool isMedium(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= 600 && w < 1024;
  }

  static bool isExpanded(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 1024;

  @override
  Widget build(BuildContext context) {
    final deviceType = getDeviceType(context);

    if (deviceType == DeviceScreenType.expanded && expanded != null) {
      return expanded!(context);
    }
    if (deviceType == DeviceScreenType.medium && medium != null) {
      return medium!(context);
    }
    return compact(context);
  }
}
