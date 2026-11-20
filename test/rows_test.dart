import 'package:flutter_test/flutter_test.dart';
import 'package:sribees_hub/core/catalog.dart';
import 'package:sribees_hub/core/installer.dart';
import 'package:sribees_hub/features/apps/apps_controller.dart';

HubApp _apk(String package, int versionCode) => HubApp.fromJson({
      'package': package,
      'name': {'en': package},
      'kind': 'apk',
      'version_code': versionCode,
      'version_name': '0.$versionCode.0',
      'apk_url': 'https://hub.sribees.com/apk/$package-$versionCode.apk',
      'sha256': 'aa',
      'cert_sha256': ['bb'],
    });

InstalledInfo _on(int versionCode) => InstalledInfo(versionCode, '0.$versionCode.0', null, const ['bb']);

void main() {
  const orders = 'com.sribeesonline.sribees_new_orders';
  final shop = HubApp.fromJson({
    'package': 'com.sribeesonline.sribees_mobile',
    'name': {'en': 'SriBees Online'},
    'kind': 'store_link',
    'play_url': 'https://play.google.com/store/apps/details?id=com.sribeesonline.sribees_mobile',
  });

  test('Hub row is hidden when the Hub is up to date', () {
    final rows = buildRows(
      [_apk(hubPackage, 2), _apk(orders, 9)],
      {hubPackage: _on(2), orders: null},
    );
    expect(rows.map((r) => r.app.package), [orders]);
    expect(rows.single.isInstalled, isFalse);
  });

  test('Hub row comes first when a Hub update is waiting', () {
    final rows = buildRows(
      [shop, _apk(orders, 9), _apk(hubPackage, 3)],
      {hubPackage: _on(2), orders: _on(8)},
    );
    expect(rows.first.app.package, hubPackage);
    expect(rows.first.hasUpdate, isTrue);
    expect(rows.firstWhere((r) => r.app.package == orders).hasUpdate, isTrue);
  });

  test('store links never offer an update', () {
    final rows = buildRows([shop], {shop.package: _on(1)});
    expect(rows.single.hasUpdate, isFalse);
    expect(rows.single.isInstalled, isTrue);
  });

  test('same or newer installed version is not an update', () {
    final rows = buildRows([_apk(orders, 9)], {orders: _on(9)});
    expect(rows.single.hasUpdate, isFalse);
  });
}
