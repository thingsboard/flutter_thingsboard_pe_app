import 'package:flutter/material.dart';
import 'package:thingsboard_app/core/context/tb_context.dart';
import 'package:thingsboard_app/core/entity/entity_details_page.dart';
import 'package:thingsboard_pe_client/thingsboard_client.dart';

class DeviceDetailsPage extends EntityDetailsPage<Device> {
  DeviceDetailsPage(TbContext tbContext, String deviceId, {super.key})
      : super(tbContext, entityId: deviceId, defaultTitle: 'Device');

  @override
  Future<Device?> fetchEntity(String id) {
    return tbClient.getDeviceService().getDevice(id);
  }

  @override
  Widget buildEntityDetails(BuildContext context, Device entity) {
    return ListTile(
      title: Text(entity.name),
      subtitle: Text(entity.type),
    );
  }
}
