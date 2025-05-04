import 'package:flutter/material.dart';
import 'package:thingsboard_app/core/context/tb_context.dart';
import 'package:thingsboard_app/core/context/tb_context_widget.dart';
import 'package:thingsboard_app/core/entity/entities_base.dart';
import 'package:thingsboard_app/modules/device/add_device_page.dart';
import 'package:thingsboard_app/modules/device/device_profiles_grid.dart';
import 'package:thingsboard_app/modules/device/qr_code.dart';
import 'package:thingsboard_app/widgets/tb_app_bar.dart';
import 'package:thingsboard_pe_client/thingsboard_client.dart';

import '../../constants/app_constants.dart';

class DevicesMainPage extends TbContextWidget {
  DevicesMainPage(TbContext tbContext, {super.key}) : super(tbContext);

  @override
  State<StatefulWidget> createState() => _DevicesMainPageState();
}

class _DevicesMainPageState extends TbContextState<DevicesMainPage>
    with AutomaticKeepAliveClientMixin<DevicesMainPage> {
  final PageLinkController _pageLinkController = PageLinkController();

  @override
  bool get wantKeepAlive {
    return true;
  }

  void _showDeviceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose an Option'),
          content: const Text('How would you like to add a device?'),
          actions: <Widget>[
            InkWell(
              onTap: () async {
                Navigator.of(context).pop();
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QRViewExample(
                    tbContext: widget.tbContext,
                    token: widget.tbContext.tbClient.getJwtToken()!,
                    owner: '${widget.tbContext.tbClient.getAuthUser()!.firstName!} ${widget.tbContext.tbClient.getAuthUser()!.lastName!}',
                  )),
                );
                print('Scanned QR Code: $result');
              },
              child: Container(
                width: 120,
                height: 45,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  border: Border.fromBorderSide(
                    BorderSide(color: ThingsboardAppConstants.primaryColor, width: 1),
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(50,)),
                  color: Colors.white,
                ),
                child: const Row(
                  children: [
                    Icon(Icons.qr_code_2_outlined,color: ThingsboardAppConstants.primaryColor,),
                    SizedBox(width: 5,),
                    Text('Scan Device', textAlign: TextAlign.center,style: TextStyle(fontSize: 12,color: ThingsboardAppConstants.primaryColor,fontWeight: FontWeight.bold),),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: (){
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddDevicePage(
                    tbContext: widget.tbContext,
                    token: widget.tbContext.tbClient.getJwtToken()!,
                    owner: '${widget.tbContext.tbClient.getAuthUser()!.firstName!} ${widget.tbContext.tbClient.getAuthUser()!.lastName!}',
                  )),
                );
              },
              child: Container(
                width: 120,
                height: 45,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                  color: ThingsboardAppConstants.primaryColor,
                ),
                child: const Text('+ Add Manually', textAlign: TextAlign.center,style: TextStyle(fontSize: 12,color: Colors.white,fontWeight: FontWeight.bold),),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var deviceProfilesList = DeviceProfilesGrid(tbContext, _pageLinkController);
    return Scaffold(
      appBar: TbAppBar(tbContext, title: Text(deviceProfilesList.title)),
      body: deviceProfilesList,
      floatingActionButton: InkWell(
        onTap: (){
          _showDeviceDialog(context);
        },
        child: Container(
          width: 120,
          height: 45,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(50)),
            color: ThingsboardAppConstants.primaryColor,
          ),
          child: const Text('+ Add Device', textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageLinkController.dispose();
    super.dispose();
  }
}
