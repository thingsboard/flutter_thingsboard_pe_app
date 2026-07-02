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
    final allOps = genericPerms[Operation.ALL.name];
    return allOps != null &&
        (allOps.contains(Operation.ALL) || allOps.contains(operation));
  }

  bool hasReadGenericPermission(Resource resource) =>
      hasGenericPermission(resource, Operation.READ);
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
