/// Local PNG skill logos under [basePath].
class SkillAssets {
  SkillAssets._();

  static const basePath = 'assets/icons/skills';

  static const _fileById = <String, String>{
    'angular': 'angular.png',
    'cplusplus': 'c++.png',
    'css': 'css.png',
    'csharp': 'csharp.png',
    'dart': 'dart.png',
    'django': 'django.png',
    'docker': 'dockers.png',
    'firebase': 'firebase.png',
    'flutter': 'flutter.png',
    'html': 'html.png',
    'java': 'java.png',
    'javascript': 'js.png',
    'kotlin': 'kotlin.png',
    'laravel': 'laravel.png',
    'mongodb': 'mongo-db.png',
    'mysql': 'mysql.png',
    'nextjs': 'next-js.png',
    'nodejs': 'node-js.png',
    'php': 'php.png',
    'postgresql': 'postgre-sql.png',
    'python': 'python.png',
    'react': 'react.png',
    'spring': 'springboot.png',
    'vuejs': 'vue-js.png',
  };

  static const _labelToId = <String, String>{
    'angular': 'angular',
    'c++': 'cplusplus',
    'css': 'css',
    'c#': 'csharp',
    'dart': 'dart',
    'django': 'django',
    'docker': 'docker',
    'firebase': 'firebase',
    'flutter': 'flutter',
    'html': 'html',
    'java': 'java',
    'javascript': 'javascript',
    'js': 'javascript',
    'kotlin': 'kotlin',
    'laravel': 'laravel',
    'mongodb': 'mongodb',
    'mongo db': 'mongodb',
    'mysql': 'mysql',
    'next.js': 'nextjs',
    'nextjs': 'nextjs',
    'node.js': 'nodejs',
    'nodejs': 'nodejs',
    'php': 'php',
    'postgresql': 'postgresql',
    'postgres': 'postgresql',
    'python': 'python',
    'react': 'react',
    'spring boot': 'spring',
    'springboot': 'spring',
    'vue.js': 'vuejs',
    'vuejs': 'vuejs',
  };

  static List<String> get catalogIds =>
      _fileById.keys.toList(growable: false);

  static bool hasAsset({String? iconKey, String? label}) =>
      assetPath(iconKey: iconKey, label: label) != null;

  static String? assetPath({String? iconKey, String? label}) {
    final id = _resolveId(iconKey: iconKey, label: label);
    if (id == null) return null;
    final file = _fileById[id];
    if (file == null) return null;
    return '$basePath/$file';
  }

  static String? _resolveId({String? iconKey, String? label}) {
    final key = iconKey?.trim().toLowerCase();
    if (key != null && key.isNotEmpty && _fileById.containsKey(key)) {
      return key;
    }
    final normalized = label?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return null;
    return _labelToId[normalized];
  }
}
