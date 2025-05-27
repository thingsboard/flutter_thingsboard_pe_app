import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:thingsboard_app/modules/device/add_device_page.dart';

import '../../core/context/tb_context.dart';

class QRViewExample extends StatefulWidget {
  QRViewExample({
    required this.token,
    required this.owner,
    required this.tbContext,
  });
  late final String token;
  late final String owner;
  late final TbContext tbContext;

  @override
  _QRViewExampleState createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? scannedData;

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan QR Code')),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          const Expanded(
            flex: 1,
            child: Center(
              child: Text(
                'Scan a code',
                style: TextStyle(fontSize: 18),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      controller.pauseCamera(); // Stop scanning once data is received
      setState(() {
        scannedData = scanData.code;
      });
      scannedData = scannedData!.split('{').last;
      scannedData = scannedData!.split('}').first;
      Map<String, String> result = {
        for (var pair in scannedData!.split(','))
          pair.split(':')[0].replaceAll('"', '').trim():
          pair.split(':')[1].replaceAll('"', '').trim()
      };
      Navigator.pop(context, scannedData);
      if(result['name'] != null){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddDevicePage(
            tbContext: widget.tbContext,
            token: widget.token,
            owner: widget.owner,
            name: result['name'],
            label: result['label'],
          )),
        );
      }else{
        widget.tbContext.showErrorNotification('Invalid qr code');
      }

    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
