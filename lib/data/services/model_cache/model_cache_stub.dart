/// Web: no hay cache de archivos; se devuelve la URL de red tal cual.
class ModelCache {
  const ModelCache();

  Future<String> resolve(String url, {void Function(double)? onProgress}) async {
    return url;
  }

  Future<void> preload(String url) async {}
}
