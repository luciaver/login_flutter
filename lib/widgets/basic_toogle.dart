import 'package:flutter/material.dart';

/// Widget de toggle/switch básico
class BasicToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? label;
  final Color? activeColor;

  const BasicToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 12),
        ],
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: activeColor ?? Colors.green.shade700,
        ),
      ],
    );
  }
}

/// Widget de toggle con card
class BasicToggleCard extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? activeColor;

  const BasicToggleCard({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
    this.subtitle,
    this.icon,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: icon != null
            ? Icon(icon, color: value ? (activeColor ?? Colors.green.shade700) : Colors.grey)
            : null,
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: activeColor ?? Colors.green.shade700,
        ),
      ),
    );
  }
}