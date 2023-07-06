import 'package:dartx/dartx.dart';
import 'package:hiddify/utils/validators.dart';

typedef ProfileLink = ({String url, String name});

// TODO: test and improve
abstract class LinkParser {
  static const protocols = ['clash', 'clashmeta'];

  static ProfileLink? simple(String link) {
    if (!isUrl(link)) return null;
    final uri = Uri.parse(link);
    final params = uri.queryParameters;
    return (
      url: uri
          .replace(queryParameters: {})
          .toString()
          .removeSuffix('?')
          .split('&')
          .first,
      name: params['name'] ?? '',
    );
  }

  static ProfileLink? deep(String link) {
    final uri = Uri.parse(link);
    if (protocols.none((e) => uri.scheme == e)) return null;
    if (uri.authority != 'install-config') return null;
    final params = uri.queryParameters;
    if (params['url'] == null) return null;
    return (url: params['url']!, name: params['name'] ?? '');
  }
}
