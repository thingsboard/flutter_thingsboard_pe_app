import 'package:flutter/material.dart';
import 'package:thingsboard_app/utils/ui/tb_text_styles.dart';

class AlarmStatusButton extends StatelessWidget {
  const AlarmStatusButton({
    required this.text,
    required this.onTap,
    super.key,
  });

  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // 👈 Rounded corners
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        backgroundColor: onTap != null
            ? Theme.of(context).primaryColor
            : Colors.grey.withOpacity(0.3),
        foregroundColor: Colors.white,
      ),
      child: Text(
        text,
        style: TbTextStyles.titleXs.copyWith(color: Colors.white),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

