
import 'package:package_info/package_info.dart' as lib;


class PackageInfo{

  static lib.PackageInfo info;

  init() async {

    info = await lib.PackageInfo.fromPlatform();
  }

  static get name => info?.packageName;

  static get version => info?.version;

  static get number => info?.buildNumber;
}

