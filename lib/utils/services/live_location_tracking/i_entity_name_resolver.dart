/// Resolves an entity's display name from its type + id. Returns null on any
/// failure (offline, deleted entity, unknown type) so callers fall back.
abstract interface class IEntityNameResolver {
  Future<String?> resolveName(String entityType, String id);
}
