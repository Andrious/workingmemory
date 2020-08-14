import 'package:package_info/package_info.dart' as lib;

class PackageInfo {
  static lib.PackageInfo info;

  void init() async {
    info = await lib.PackageInfo.fromPlatform();
  }

  static String get name => info?.packageName;

  static String get version => info?.version;

  static String get number => info?.buildNumber;
}
