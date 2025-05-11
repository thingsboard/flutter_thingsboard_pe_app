import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thingsboard_app/constants/assets_path.dart';
import 'package:thingsboard_app/core/context/tb_context.dart';
import 'package:thingsboard_app/core/context/tb_context_widget.dart';
import 'package:thingsboard_app/core/entity/entities_base.dart';
import 'package:thingsboard_app/thingsboard_client.dart';
import 'package:thingsboard_app/utils/services/device_profile_cache.dart';
import 'package:thingsboard_app/utils/services/entity_query_api.dart';
import 'package:thingsboard_app/utils/utils.dart';

mixin DeviceProfilesBase on EntitiesBase<DeviceProfileInfo, PageLink> {
  final RefreshDeviceCounts refreshDeviceCounts = RefreshDeviceCounts();

  @override
  String get title => 'Devices';

  @override
  String get noItemsFoundText => 'No devices found';

  @override
  Future<PageData<DeviceProfileInfo>> fetchEntities(PageLink pageLink) {
    return DeviceProfileCache.getDeviceProfileInfos(tbClient, pageLink);
  }

  @override
  void onEntityTap(DeviceProfileInfo deviceProfile) {
    navigateTo(
      '/deviceList?deviceType=${Uri.encodeComponent(deviceProfile.name)}',
    );
  }

  @override
  Future<void> onRefresh() {
    if (refreshDeviceCounts.onRefresh != null) {
      return refreshDeviceCounts.onRefresh!();
    } else {
      return Future.value();
    }
  }

  @override
  Widget? buildHeading(BuildContext context) {
    return AllDevicesCard(tbContext, refreshDeviceCounts);
  }

  @override
  Widget buildEntityGridCard(
    BuildContext context,
    DeviceProfileInfo deviceProfile,
  ) {
    return DeviceProfileCard(tbContext, deviceProfile);
  }

  @override
  double? gridChildAspectRatio() {
    return 156 / 200;
  }
}

class RefreshDeviceCounts {
  Future<void> Function()? onRefresh;
}

class AllDevicesCard extends TbContextWidget {
  final RefreshDeviceCounts refreshDeviceCounts;

  AllDevicesCard(TbContext tbContext, this.refreshDeviceCounts, {super.key})
      : super(tbContext);

  @override
  State<StatefulWidget> createState() => _AllDevicesCardState();
}

class _AllDevicesCardState extends TbContextState<AllDevicesCard> {
  final StreamController<int?> _activeDevicesCount =
      StreamController.broadcast();
  final StreamController<int?> _inactiveDevicesCount =
      StreamController.broadcast();

  @override
  void initState() {
    super.initState();
    widget.refreshDeviceCounts.onRefresh = _countDevices;
    _countDevices();
  }

  @override
  void didUpdateWidget(AllDevicesCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.refreshDeviceCounts.onRefresh = _countDevices;
  }

  @override
  void dispose() {
    _activeDevicesCount.close();
    _inactiveDevicesCount.close();
    widget.refreshDeviceCounts.onRefresh = null;
    super.dispose();
  }

  Future<void> _countDevices() {
    _activeDevicesCount.add(null);
    _inactiveDevicesCount.add(null);
    Future<int> activeDevicesCount =
        EntityQueryApi.countDevices(tbClient, active: true);
    Future<int> inactiveDevicesCount =
        EntityQueryApi.countDevices(tbClient, active: false);
    Future<List<int>> countsFuture =
        Future.wait([activeDevicesCount, inactiveDevicesCount]);
    countsFuture.then((counts) {
      if (mounted) {
        _activeDevicesCount.add(counts[0]);
        _inactiveDevicesCount.add(counts[1]);
      }
    });
    return countsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.05).ceil()),
            blurRadius: 6.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: (){
                navigateTo('/deviceList');
              },
              child: Container(
                // margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 4,vertical: 5),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[300]!),
                    color: Colors.white
                ),
                child: Text(S.of(context).allDevices),
              ),
            ),
            const SizedBox(width: 2,),
            InkWell(
              onTap: (){
                navigateTo('/deviceList?active=true');
              },
              child: Container(
                // margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 4,vertical: 5),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[300]!),
                  color: Colors.white
                ),
                child: const Text('Active Devices'),
              ),
            ),
            const SizedBox(width: 2,),
            InkWell(
              onTap: (){
                navigateTo('/deviceList?active=false');
              },
              child: Container(
                // margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 4,vertical: 5),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[300]!),
                    color: Colors.white
                ),
                child: const Text('Inactive Devices'),
              ),
            ),
          ],
        )
    );
  }
}

class DeviceProfileCard extends TbContextWidget {
  final DeviceProfileInfo deviceProfile;

  DeviceProfileCard(TbContext tbContext, this.deviceProfile, {super.key})
      : super(tbContext);

  @override
  State<StatefulWidget> createState() => _DeviceProfileCardState();
}

class _DeviceProfileCardState extends TbContextState<DeviceProfileCard> {
  late Future<int> activeDevicesCount;
  late Future<int> inactiveDevicesCount;

  @override
  void initState() {
    super.initState();
    _countDevices();
  }

  @override
  void didUpdateWidget(DeviceProfileCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (tbContext.isAuthenticated) {
      _countDevices();
    }
  }

  _countDevices() {
    activeDevicesCount = EntityQueryApi.countDevices(
      tbClient,
      deviceType: widget.deviceProfile.name,
      active: true,
    );
    inactiveDevicesCount = EntityQueryApi.countDevices(
      tbClient,
      deviceType: widget.deviceProfile.name,
      active: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    var entity = widget.deviceProfile;
    var hasImage = entity.image != null;
    Widget image;
    BoxFit imageFit;
    double padding;
    if (hasImage) {
      image = Utils.imageFromTbImage(context, tbClient, entity.image!);
      imageFit = BoxFit.contain;
      padding = 8;
    } else {
      image = SvgPicture.asset(
        ThingsboardImage.deviceProfilePlaceholder,
        colorFilter: ColorFilter.mode(
          Theme.of(context).primaryColor,
          BlendMode.overlay,
        ),
        semanticsLabel: 'Device profile',
      );
      imageFit = BoxFit.cover;
      padding = 0;
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Column(
        children: [
          // rami
          const SizedBox(height: 8,),
          Stack(
            children: [
              SizedBox(
                height: 50,
                width: 50,
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: FittedBox(
                    clipBehavior: Clip.hardEdge,
                    fit: imageFit,
                    child: image,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 44,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Center(
                child: AutoSizeText(
                  entity.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  minFontSize: 12,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    height: 20 / 14,
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: FutureBuilder<int>(
                  future: activeDevicesCount,
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        snapshot.connectionState == ConnectionState.done) {
                      var deviceCount = snapshot.data!;
                      return _buildDeviceCount(context, true, deviceCount);
                    } else {
                      return SizedBox(
                        height: 40,
                        child: Center(
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(
                                Theme.of(
                                  tbContext.currentState!.context,
                                ).colorScheme.primary,
                              ),
                              strokeWidth: 2.5,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
                onTap: () {
                  navigateTo(
                    '/deviceList?active=true&deviceType=${Uri.encodeComponent(entity.name)}',
                  );
                },
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: FutureBuilder<int>(
                  future: inactiveDevicesCount,
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        snapshot.connectionState == ConnectionState.done) {
                      var deviceCount = snapshot.data!;
                      return _buildDeviceCount(context, false, deviceCount);
                    } else {
                      return SizedBox(
                        height: 40,
                        child: Center(
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(
                                Theme.of(
                                  tbContext.currentState!.context,
                                ).colorScheme.primary,
                              ),
                              strokeWidth: 2.5,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
                onTap: () {
                  navigateTo(
                    '/deviceList?active=false&deviceType=${Uri.encodeComponent(entity.name)}',
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _buildDeviceCount(BuildContext context, bool active, int count) {
  Color color = active ? const Color(0xFF008A00) : const Color(0xFFAFAFAF);
  return Padding(
    padding: const EdgeInsets.all(4),
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
          color: Colors.white
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            active ? S.of(context).active : S.of(context).inactive,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 16 / 12,
              color: color,
            ),
          ),
          const SizedBox(height: 8.67),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 16 / 12,
                  color: color,
                ),
              ),
              const SizedBox(width: 8.67),
              const Icon(Icons.chevron_right, size: 16, color: Color(0xFFACACAC)),
            ],
          ),
        ],
      ),
    ),
  );
}

class StrikeThroughPainter extends CustomPainter {
  final Color color;
  final double offset;

  StrikeThroughPainter({required this.color, this.offset = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    paint.strokeWidth = 1.5;
    canvas.drawLine(
      Offset(offset, offset),
      Offset(size.width - offset, size.height - offset),
      paint,
    );
    paint.color = Colors.white;
    canvas.drawLine(
      const Offset(2, 0),
      Offset(size.width + 2, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant StrikeThroughPainter oldDelegate) {
    return color != oldDelegate.color;
  }
}
