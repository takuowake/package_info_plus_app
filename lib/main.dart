import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  Future<PackageInfo> _getPackageInfo() {
    return PackageInfo.fromPlatform();
  }

  Future<DeviceData> _getDeviceInfo() async {
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
    DeviceData? deviceData;

    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        deviceData = DeviceData(
          'android',
          build.model,
          build.id ?? 'unknown',
        );
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        deviceData = DeviceData(
          'ios',
          data.model,
          data.identifierForVendor ?? 'unknown',
        );
      }
    } on PlatformException {
      deviceData = DeviceData(
        'Failed to get platform version.',
        '',
        '',
      );
    }

    if (deviceData == null) {
      throw Exception('Unsupported platform');
    }

    return deviceData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Package Info Plus'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FutureBuilder<PackageInfo>(
              future: _getPackageInfo(),
              builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
                if (snapshot.hasError) {
                  return const Text('ERROR');
                } else if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final data = snapshot.data!;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('App Name: ${data.appName}'),
                    Text('Package Name: ${data.packageName}'),
                    Text('Version: ${data.version}'),
                    Text('Build Number: ${data.buildNumber}'),
                  ],
                );
              },
            ),
            FutureBuilder<DeviceData>(
              future: _getDeviceInfo(),
              builder: (BuildContext context, AsyncSnapshot<DeviceData> snapshot) {
                if (snapshot.hasError) {
                  return const Text('ERROR');
                } else if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final data = snapshot.data!;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('OS: ${data.os}'),
                    Text('Model: ${data.model}'),
                    Text('Identifier: ${data.identifier}'),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DeviceData {
  final String os;
  final String model;
  final String identifier;

  DeviceData(this.os, this.model, this.identifier);
}
