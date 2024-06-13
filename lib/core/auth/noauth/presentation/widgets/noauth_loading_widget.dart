import 'package:flutter/material.dart';
import 'package:thingsboard_app/core/context/tb_context.dart';
import 'package:thingsboard_app/widgets/tb_progress_indicator.dart';

class NoAuthLoadingWidget extends StatelessWidget {
  const NoAuthLoadingWidget({required this.tbContext});

  final TbContext tbContext;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        color: const Color(0x99FFFFFF),
        child: Center(
          child: TbProgressIndicator(tbContext, size: 50.0),
        ),
      ),
    );
  }
}
