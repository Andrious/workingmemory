//
import 'package:package_info_plus/package_info_plus.dart' as lib;

///
class PackageInfo {
  ///
  static lib.PackageInfo? info;

  ///
  Future<void> init() async {
    info = await lib.PackageInfo.fromPlatform();
  }

  ///
  static String? get name => info?.packageName;

  ///
  static String? get version => info?.version;

  ///
  static String? get number => info?.buildNumber;
}
