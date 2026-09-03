import 'package:thingsboard_pe_client/thingsboard_pe_client.dart';

/// Extension that restores the old `hasGenericPermission()` / `hasReadGenericPermission()`
/// helpers on the new built_value [AllowedPermissionsInfo] model.
///
/// The new client stores merged generic permissions in
/// `userPermissions.genericPermissions: BuiltMap<String, BuiltSet<Operation>>`.
/// The key is the resource name string (e.g. `'ALARM'`), mirroring the
/// old `Map<Resource, Set<Operation>>` but JSON-serialised.
extension AllowedPermissionsInfoExt on AllowedPermissionsInfo {
  bool hasGenericPermission(Resource resource, Operation operation) {
    final genericPerms = userPermissions?.genericPermissions;
    if (genericPerms == null) return false;

    final ops = genericPerms[resource.name];
    if (ops != null &&
        (ops.contains(Operation.ALL) || ops.contains(operation))) {
      return true;
    }
    // The `Resource.ALL` wildcard entry applies only to resources allowed for
    // the user's authority — same as `hasGenericAllPermission` in the web UI.
    if (!_isResourceAllowed(resource)) return false;
    final allOps = genericPerms[Resource.ALL.name];
    return allOps != null &&
        (allOps.contains(Operation.ALL) || allOps.contains(operation));
  }

  bool hasReadGenericPermission(Resource resource) =>
      hasGenericPermission(resource, Operation.READ);

  /// Mirrors `hasSharedReadGroupsPermission` in the web UI: the user has at
  /// least one entity group of [entityType] shared via a group role.
  ///
  /// `hasGenericRead` is intentionally ignored here — it reflects the generic
  /// group-resource permission (e.g. "Customer group"), which only unlocks the
  /// group-browsing UI that exists on the web but not in the mobile app; the
  /// `/api/user/*` list endpoints ignore it too.
  bool hasSharedReadGroupsPermission(EntityType entityType) {
    final info = userPermissions?.readGroupPermissions?[entityType.name];
    return info?.entityGroupIds?.isNotEmpty ?? false;
  }

  /// The user can list entities of [resource]: either through a generic READ
  /// permission or because at least one group of [entityType] is shared with
  /// them via a group role. This is what the `/api/user/*` list endpoints
  /// resolve data by, so it is the right gate for list pages.
  bool hasReadGenericOrSharedGroupsPermission(
    Resource resource,
    EntityType entityType,
  ) =>
      hasReadGenericPermission(resource) ||
      hasSharedReadGroupsPermission(entityType);

  bool _isResourceAllowed(Resource resource) {
    final allowed = allowedResources;
    return allowed == null || allowed.contains(resource);
  }
}

/// Extension that restores typed access to an [AlarmCommentInfo]'s free-form
/// `comment` payload on the new built_value model.
///
/// The new client types `comment` as a [JsonObject] (a `MapJsonObject` at
/// runtime), whereas the old client exposed it pre-parsed. This decodes the
/// underlying map back into the handwritten [AlarmCommentJsonNode] consumed by
/// the alarm activity widgets.
/// Memoizes the parsed [AlarmCommentJsonNode] per [AlarmCommentInfo] instance.
///
/// Extensions cannot hold state, so the parse result is cached by identity here.
/// [AlarmCommentInfo] is immutable (built_value), so a cached node stays valid
/// for the lifetime of the instance — this avoids re-decoding the JSON on every
/// `commentNode` access during widget rebuilds (e.g. while scrolling the alarm
/// activity list).
final _commentNodeCache = Expando<AlarmCommentJsonNode>('commentNode');

extension AlarmCommentInfoExt on AlarmCommentInfo {
  /// `comment` is nullable on the new built_value model, and system-generated
  /// activity entries may not carry a payload, so callers must handle null.
  AlarmCommentJsonNode? get commentNode {
    final cached = _commentNodeCache[this];
    if (cached != null) {
      return cached;
    }
    final raw = comment?.asMap;
    if (raw == null) {
      return null;
    }
    return _commentNodeCache[this] = AlarmCommentJsonNode.fromJson(
      raw.cast<String, dynamic>(),
    );
  }
}
