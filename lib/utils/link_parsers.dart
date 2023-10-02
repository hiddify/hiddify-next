import 'dart:convert';

import 'package:hiddify/domain/clash/clash.dart';
import 'package:hiddify/utils/validators.dart';

typedef ProfileLink = ({String url, String name});

// TODO: test and improve
abstract class LinkParser {
  // protocols schemas
  static const protocols = {'clash', 'clashmeta', 'sing-box', 'hiddify'};
  static const rawProtocols = {'vmess', 'vless', 'trojan', 'ss', 'tuic'};

  static ProfileLink? parse(String link) {
    return simple(link) ?? deep(link);
  }

  static ProfileLink? simple(String link) {
    if (!isUrl(link)) return null;
    final uri = Uri.parse(link.trim());
    return (
      url: uri.toString(),
      name: uri.queryParameters['name'] ?? '',
    );
  }

  static ({String content, String name})? protocol(String content) {
    final lines = safeDecodeBase64(content).split('\n');
    for (final line in lines) {
      final uri = Uri.tryParse(line);
      if (uri == null) continue;
      final fragment =
          uri.hasFragment ? Uri.decodeComponent(uri.fragment) : null;
      final name = switch (uri.scheme) {
        'ss' => fragment ?? ProxyType.shadowSocks.label,
        'vless' => fragment ?? ProxyType.vless.label,
        'tuic' => fragment ?? ProxyType.tuic.label,
        'vmess' => ProxyType.vmess.label,
        _ => null,
      };
      if (name != null) {
        return (content: content, name: name);
      }
    }
    return null;
  }

  static ProfileLink? deep(String link) {
    final uri = Uri.tryParse(link.trim());
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) return null;
    final queryParams = uri.queryParameters;
    switch (uri.scheme) {
      case 'clash' || 'clashmeta' when uri.authority == 'install-config':
        if (uri.authority != 'install-config' ||
            !queryParams.containsKey('url')) return null;
        return (url: queryParams['url']!, name: queryParams['name'] ?? '');
      case 'sing-box':
        if (uri.authority != 'import-remote-profile' ||
            !queryParams.containsKey('url')) return null;
        return (url: queryParams['url']!, name: queryParams['name'] ?? '');
      case 'hiddify':
        if ((uri.authority != 'install-config' &&
                uri.authority != 'install-sub') ||
            !queryParams.containsKey('url')) return null;
        return (url: queryParams['url']!, name: queryParams['name'] ?? '');
      default:
        return null;
    }
  }
}

String safeDecodeBase64(String str) {
  try {
    return utf8.decode(base64Decode(str));
  } catch (e) {
    return str;
  }
}
