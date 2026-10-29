/// Call sites build URLs as `endpoint + '/api/...'`, so a trailing slash turns
/// into `//api/...`, which the server's `StrictHttpFirewall` rejects with 400.
/// The `://` of a scheme-only value is kept so it is not mangled further.
String normalizeEndpoint(String endpoint) {
  var normalized = endpoint.trim();
  while (normalized.endsWith('/') && !normalized.endsWith('://')) {
    normalized = normalized.substring(0, normalized.length - 1);
  }

  return normalized;
}
