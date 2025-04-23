import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thingsboard_app/constants/assets_path.dart';
import 'package:thingsboard_app/core/context/tb_context.dart';
import 'package:thingsboard_app/core/context/tb_context_widget.dart';
import 'package:thingsboard_app/thingsboard_client.dart';
import 'package:thingsboard_app/utils/utils.dart';
import 'package:timeago/timeago.dart' as timeago;

// rami
class DashboardGridCard extends TbContextWidget {
  final DashboardInfo dashboard;

  DashboardGridCard(TbContext tbContext, {super.key, required this.dashboard})
      : super(tbContext);

  @override
  State<StatefulWidget> createState() => _DashboardGridCardState();
}

class _DashboardGridCardState extends TbContextState<DashboardGridCard> {
  _DashboardGridCardState() : super();

  @override
  void didUpdateWidget(DashboardGridCard oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  String getTimeAgo(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return timeago.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    // var hasImage = widget.dashboard.image != null;
    // Widget image;
    // if (hasImage) {
    //   image =
    //       Utils.imageFromTbImage(context, tbClient, widget.dashboard.image!);
    // } else {
    //   image = SvgPicture.asset(
    //     ThingsboardImage.dashboardPlaceholder,
    //     colorFilter: ColorFilter.mode(
    //       Theme.of(context).primaryColor,
    //       BlendMode.overlay,
    //     ),
    //     semanticsLabel: 'Dashboard',
    //   );
    // }

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset('assets/images/ambience_monitoring.png'),
          const SizedBox(height: 16),
          Text(
            widget.dashboard.title,
            //textAlign: TextAlign.center,
            maxLines: 2,
            //minFontSize: 12,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 18,
              //height: 20 / 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            getTimeAgo(widget.dashboard.createdTime!),
            // textAlign: TextAlign.center,
            maxLines: 1,
            // minFontSize: 12,
            // overflow: TextOverflow.ellipsis,
            style: TextStyle(
              // fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.grey[700]!,
              fontWeight: FontWeight.w500
              // height: 20 / 14,
            ),
          ),
        ],
      ),
    );
  }
}
