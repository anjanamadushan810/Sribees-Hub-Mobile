import 'package:flutter_test/flutter_test.dart';
import 'package:sribees_hub/core/catalog.dart';

void main() {
  test('apk entry parses and normalises cert digests', () {
    final app = HubApp.fromJson({
      'package': 'com.sribeesonline.sribees_new_orders',
      'name': {'en': 'New Orders', 'si': 'නව ඇණවුම්'},
      'kind': 'apk',
      'audience': 'staff',
      'version_code': 9,
      'version_name': '0.8.0',
      'apk_url': 'https://hub.sribees.com/apk/new-orders-9.apk',
      'sha256': 'ABCDEF',
      'cert_sha256': ['AA:BB:CC'],
    });
    expect(app.kind, DeliveryKind.apk);
    expect(app.sha256, 'abcdef');
    expect(app.certSha256, ['aabbcc']);
    expect(app.name('si'), 'නව ඇණවුම්');
    expect(app.name('ta'), 'New Orders'); // falls back to English
  });

  test('apk entry without signer is rejected', () {
    expect(
      () => HubApp.fromJson({
        'package': 'x',
        'kind': 'apk',
        'version_code': 1,
        'apk_url': 'https://x',
        'sha256': 'aa',
      }),
      throwsFormatException,
    );
  });

  test('store link entry needs no apk fields', () {
    final app = HubApp.fromJson({
      'package': 'com.sribeesonline.sribees_mobile',
      'name': {'en': 'SriBees Online'},
      'kind': 'store_link',
      'play_url': 'https://play.google.com/store/apps/details?id=com.sribeesonline.sribees_mobile',
    });
    expect(app.kind, DeliveryKind.storeLink);
    expect(app.audience, 'public');
  });
}
