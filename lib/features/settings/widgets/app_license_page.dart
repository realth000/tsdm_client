import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tsdm_client/constants/constants.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';

class AppLicensePage extends StatelessWidget {
  const AppLicensePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: rootBundle.loadString(assetsLicensePath),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(snapshot.error.toString())),
          );
        }
        if (snapshot.hasData) {
          return LicensePage(
            applicationName: context.t.appName,
            applicationVersion: appFullVersion,
            applicationIcon:
                Image.asset(assetsLogoPath, width: 192, height: 192),
            applicationLegalese: snapshot.data,
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
