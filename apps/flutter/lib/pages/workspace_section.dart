import 'package:flutter/material.dart';

class WorkspaceSection {
  const WorkspaceSection({
    required this.title,
    required this.icon,
    required this.activeIcon,
  });

  final String title;
  final IconData icon;
  final IconData activeIcon;
}
