import 'package:dio/dio.dart';

/// Catalog URL. Override per build: --dart-define=CATALOG_URL=https://...
const catalogUrl = String.fromEnvironment(
  'CATALOG_URL',
  defaultValue: 'https://hub.sribees.com/catalog.json',
);

/// How an app is delivered.
/// - apk: Hub downloads, verifies and installs it.
/// - store_link: Hub only opens Play / App Store (e.g. the customer app).
enum DeliveryKind { apk, storeLink }

class HubApp {
  HubApp({
    required this.package,
    required this.names,
    required this.descriptions,
    required this.kind,
    required this.audience,
    this.versionCode,
    this.versionName,
    this.apkUrl,
    this.sha256,
    this.certSha256 = const [],
    this.playUrl,
    this.iosUrl,
    this.changelog = const {},
  });

  final String package;
  final Map<String, String> names;
  final Map<String, String> descriptions;
  final DeliveryKind kind;

  /// public | staff  (role filtering arrives with Hub login).
  final String audience;
  final int? versionCode;
  final String? versionName;
  final String? apkUrl;
  final String? sha256;

  /// Lowercase hex SHA-256 digests of the allowed signing certificates.
  final List<String> certSha256;
  final String? playUrl;
  final String? iosUrl;
  final Map<String, String> changelog;

  String name(String lang) => names[lang] ?? names['en'] ?? package;
  String description(String lang) => descriptions[lang] ?? descriptions['en'] ?? '';

  static Map<String, String> _texts(Object? v) =>
      v is Map ? v.map((k, x) => MapEntry('$k', '$x')) : <String, String>{};

  factory HubApp.fromJson(Map<String, dynamic> j) {
    final kind = j['kind'] == 'apk' ? DeliveryKind.apk : DeliveryKind.storeLink;
    final app = HubApp(
      package: j['package'] as String,
      names: _texts(j['name']),
      descriptions: _texts(j['description']),
      kind: kind,
      audience: (j['audience'] as String?) ?? 'public',
      versionCode: (j['version_code'] as num?)?.toInt(),
      versionName: j['version_name'] as String?,
      apkUrl: j['apk_url'] as String?,
      sha256: (j['sha256'] as String?)?.toLowerCase(),
      certSha256: ((j['cert_sha256'] as List?) ?? const [])
          .map((e) => '$e'.toLowerCase().replaceAll(':', ''))
          .toList(),
      playUrl: j['play_url'] as String?,
      iosUrl: j['ios_url'] as String?,
      changelog: _texts(j['changelog']),
    );
    if (kind == DeliveryKind.apk &&
        (app.apkUrl == null ||
            app.sha256 == null ||
            app.versionCode == null ||
            app.certSha256.isEmpty)) {
      throw FormatException('APK entry ${app.package} is missing url/sha256/version/cert');
    }
    return app;
  }
}

class CatalogRepository {
  CatalogRepository([Dio? dio])
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 30),
            ));

  final Dio _dio;

  Future<List<HubApp>> fetch() async {
    final res = await _dio.get<Map<String, dynamic>>(
      catalogUrl,
      options: Options(headers: {'Cache-Control': 'no-cache'}),
    );
    final apps = (res.data?['apps'] as List?) ?? const [];
    return apps.map((e) => HubApp.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }
}
