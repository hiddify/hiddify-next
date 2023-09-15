import 'package:dartx/dartx.dart';
import 'package:hiddify/utils/validators.dart';

typedef ProfileLink = ({String url, String name});

// TODO: test and improve
abstract class LinkParser {
  static const protocols = ['clash', 'clashmeta', 'sing-box', 'hiddify'];

  static ProfileLink? parse(String link) {
    return simple(link) ?? deep(link);
  }

  static ProfileLink? simple(String link) {
    if (!isUrl(link)) return null;
    final uri = Uri.parse(link.trim());
    final params = uri.queryParameters;
    return (
      url: uri.toString(),
      // .replace(queryParameters: {})
      // .toString()
      // .removeSuffix('?')
      // .split('&')
      // .first,
      name: params['name'] ?? '',
    );
  }

  static ProfileLink? deep(String link) {
    final uri = Uri.tryParse(link.trim());
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) return null;
    final queryParams = uri.queryParameters;
    switch (uri.scheme) {
      case 'clash' || 'clashmeta':
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
