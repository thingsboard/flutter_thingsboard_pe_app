// ignore_for_file: parameter_assignments

import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:thingsboard_app/config/routes/v2/router_2.dart';
import 'package:thingsboard_app/config/themes/tb_theme.dart';
import 'package:thingsboard_app/config/themes/tb_theme_utils.dart';
import 'package:thingsboard_app/constants/app_constants.dart';
import 'package:thingsboard_app/constants/assets_path.dart';
import 'package:thingsboard_app/core/auth/login/models/login_state.dart';
import 'package:thingsboard_app/core/auth/login/provider/login_provider.dart';

import 'package:thingsboard_app/core/context/tb_context.dart';
import 'package:thingsboard_app/core/select_region/model/region.dart';
import 'package:thingsboard_app/locator.dart';
import 'package:thingsboard_app/thingsboard_client.dart';
import 'package:thingsboard_app/utils/services/local_database/i_local_database_service.dart';
import 'package:thingsboard_app/utils/services/tb_client_service/i_tb_client_service.dart';
import 'package:thingsboard_app/utils/utils.dart';
part 'wl_provider.g.dart';
part 'wl_provider.freezed.dart';

const defaultLogoUrl = 'LOGO-PE';

@freezed
abstract class WlState with _$WlState {
  const factory WlState({
    required LoginWhiteLabelingParams loginWhiteLabelingParams,
    required WhiteLabelingParams userParams,
    required ThemeData theme,
    required bool isUserWlMode,
    required Widget logo,
  }) = _WlState;
  const WlState._();

  WhiteLabelingParams get wlParams =>
      isUserWlMode ? userParams : _loginToWlParams(loginWhiteLabelingParams);

  bool? get loginShowNameVersion => loginWhiteLabelingParams.showNameVersion;

  bool? get showNameBottom => loginWhiteLabelingParams.showNameBottom;

  bool? get showNameVersion =>
      isUserWlMode
          ? userParams.showNameVersion
          : loginWhiteLabelingParams.showNameVersion;

  String get platformName =>
      (isUserWlMode
          ? userParams.platformName
          : loginWhiteLabelingParams.platformName) ??
      '';

  String get platformVersion =>
      (isUserWlMode
          ? userParams.platformVersion
          : loginWhiteLabelingParams.platformVersion) ??
      '';

  String get platformNameAndVersion => '$platformName v.$platformVersion';

  bool get isCustomLogo =>
      isUserWlMode
          ? userParams.logoImageUrl != defaultLogoUrl
          : loginWhiteLabelingParams.logoImageUrl != defaultLogoUrl;
}

WhiteLabelingParams _loginToWlParams(LoginWhiteLabelingParams p) =>
    WhiteLabelingParams(
      (b) =>
          b
            ..logoImageUrl = p.logoImageUrl
            ..logoImageHeight = p.logoImageHeight
            ..appTitle = p.appTitle
            ..favicon = p.favicon?.toBuilder()
            ..paletteSettings = p.paletteSettings?.toBuilder()
            ..helpLinkBaseUrl = p.helpLinkBaseUrl
            ..uiHelpBaseUrl = p.uiHelpBaseUrl
            ..enableHelpLinks = p.enableHelpLinks
            ..whiteLabelingEnabled = p.whiteLabelingEnabled
            ..showNameVersion = p.showNameVersion
            ..platformName = p.platformName
            ..platformVersion = p.platformVersion
            ..customCss = p.customCss
            ..hideConnectivityDialog = p.hideConnectivityDialog
            ..overrideTrendzName = p.overrideTrendzName,
    );

@riverpod
class Wl extends _$Wl {
  late final ThingsboardClient _tbClient;
  late ProviderSubscription<LoginState> _subscription;
  @override
  WlState build() {
    _tbClient = getIt<ITbClientService>().client;

    _subscription = ref.listen(loginProvider, (prev, next) {
      print('wl update');
      updateWhiteLabeling();
    });
    ref.onDispose(() => _subscription.close());
    return WlState(
      loginWhiteLabelingParams: _defaultLoginWlParams,
      userParams: _defaultWLParams,
      theme: _defaultThemeData,
      isUserWlMode: false,
      logo: _defaultLogo,
    );
  }

  static final _defaultWLParams = _createDefaultWlParams();
  static final _defaultThemeData = tbTheme(
    TbThemeUtils.tbPrimary,
    TbThemeUtils.tbPrimaryColor,
    TbThemeUtils.tbAccentColor,
  );
  static final _defaultLoginWlParams = _createDefaultLoginWlParams();

  static final _defaultLogo = SvgPicture.asset(
    ThingsboardImage.thingsBoardWithTitle,
    height: 36 / 3 * 2,
    colorFilter: ColorFilter.mode(TbThemeUtils.tbPrimary, BlendMode.srcIn),
    semanticsLabel: 'ThingsBoard Logo',
  );

  static final _defaultLoginLogo = SvgPicture.asset(
    ThingsboardImage.thingsBoardWithTitle,
    height: 50 / 3 * 2,
    colorFilter: ColorFilter.mode(TbThemeUtils.tbPrimary, BlendMode.srcIn),
    semanticsLabel: 'ThingsBoard Logo',
  );

  static WhiteLabelingParams _createDefaultWlParams() => WhiteLabelingParams(
    (b) =>
        b
          ..logoImageUrl = defaultLogoUrl
          ..logoImageHeight = 36
          ..appTitle = 'ThingsBoard PE'
          ..favicon = (FaviconBuilder()..url = 'thingsboard.ico')
          ..paletteSettings =
              (PaletteSettingsBuilder()
                ..primaryPalette =
                    (PaletteBuilder()
                      ..type = 'tb-primary') // translate-me-ignore
                ..accentPalette =
                    (PaletteBuilder()
                      ..type = 'tb-accent')) // translate-me-ignore
          ..helpLinkBaseUrl = 'https://thingsboard.io'
          ..enableHelpLinks = true
          ..showNameVersion = false
          ..platformName = 'ThingsBoard'
          ..platformVersion = '3.4.1PE',
  );

  static LoginWhiteLabelingParams _createDefaultLoginWlParams() {
    // Build login WL params from default WL params values
    return LoginWhiteLabelingParams(
      (b) =>
          b
            ..logoImageUrl = defaultLogoUrl
            ..logoImageHeight = 50
            ..appTitle = 'ThingsBoard PE'
            ..favicon = (FaviconBuilder()..url = 'thingsboard.ico')
            ..paletteSettings =
                (PaletteSettingsBuilder()
                  ..primaryPalette =
                      (PaletteBuilder()
                        ..type = 'tb-primary') // translate-me-ignore
                  ..accentPalette =
                      (PaletteBuilder()
                        ..type = 'tb-accent')) // translate-me-ignore
            ..helpLinkBaseUrl = 'https://thingsboard.io'
            ..enableHelpLinks = true
            ..showNameVersion = false
            ..platformName = 'ThingsBoard'
            ..platformVersion = '3.4.1PE'
            ..pageBackgroundColor = '#eee'
            ..darkForeground = false,
    );
  }

  /// Merges [wlParams] with [defaultWlParams], filling in missing fields from
  /// defaults. Returns a new immutable instance (built_value rebuild).
  static WhiteLabelingParams _mergeDefaults(
    WhiteLabelingParams? wlParams,
    WhiteLabelingParams defaultWlParams,
  ) {
    wlParams ??= WhiteLabelingParams((b) => b);
    return wlParams.rebuild((b) {
      if (_isEmpty(b.logoImageUrl)) {
        b.logoImageUrl = defaultWlParams.logoImageUrl;
      }
      b.logoImageHeight ??= defaultWlParams.logoImageHeight;
      if (_isEmpty(b.appTitle)) b.appTitle = defaultWlParams.appTitle;
      if (b.favicon == null || _isEmpty(b.favicon?.url)) {
        b.favicon =
            defaultWlParams.favicon?.toBuilder() ??
            (FaviconBuilder()..url = '');
      }
      if (b.paletteSettings == null) {
        b.paletteSettings =
            defaultWlParams.paletteSettings?.toBuilder() ??
            PaletteSettingsBuilder();
      } else {
        if (b.paletteSettings!.primaryPalette == null ||
            _isEmpty(b.paletteSettings!.primaryPalette?.type)) {
          b.paletteSettings!.primaryPalette =
              defaultWlParams.paletteSettings?.primaryPalette?.toBuilder() ??
              (PaletteBuilder()..type = '');
        }
        if (b.paletteSettings!.accentPalette == null ||
            _isEmpty(b.paletteSettings!.accentPalette?.type)) {
          b.paletteSettings!.accentPalette =
              defaultWlParams.paletteSettings?.accentPalette?.toBuilder() ??
              (PaletteBuilder()..type = '');
        }
      }
      if (_isEmpty(b.helpLinkBaseUrl) &&
          !_isEmpty(defaultWlParams.helpLinkBaseUrl)) {
        b.helpLinkBaseUrl = defaultWlParams.helpLinkBaseUrl;
      }
      b.enableHelpLinks ??= defaultWlParams.enableHelpLinks;
      b.showNameVersion ??= defaultWlParams.showNameVersion;
      b.platformName ??= defaultWlParams.platformName;
      b.platformVersion ??= defaultWlParams.platformVersion;
    });
  }

  static LoginWhiteLabelingParams _mergeLoginDefaults(
    LoginWhiteLabelingParams? wlParams,
    LoginWhiteLabelingParams defaultWlParams,
  ) {
    wlParams ??= LoginWhiteLabelingParams((b) => b);
    // Convert to WhiteLabelingParams to reuse common merge logic, then copy
    // the login-specific fields back.
    final baseWl = _loginToWlParams(wlParams);
    final defaultBaseWl = _loginToWlParams(defaultWlParams);
    final mergedBase = _mergeDefaults(baseWl, defaultBaseWl);
    return LoginWhiteLabelingParams(
      (b) =>
          b
            ..logoImageUrl = mergedBase.logoImageUrl
            ..logoImageHeight = mergedBase.logoImageHeight
            ..appTitle = mergedBase.appTitle
            ..favicon = mergedBase.favicon?.toBuilder()
            ..paletteSettings = mergedBase.paletteSettings?.toBuilder()
            ..helpLinkBaseUrl = mergedBase.helpLinkBaseUrl
            ..enableHelpLinks = mergedBase.enableHelpLinks
            ..showNameVersion = mergedBase.showNameVersion
            ..platformName = mergedBase.platformName
            ..platformVersion = mergedBase.platformVersion
            ..pageBackgroundColor =
                wlParams!.pageBackgroundColor ??
                defaultWlParams.pageBackgroundColor
            ..darkForeground =
                wlParams.darkForeground ?? defaultWlParams.darkForeground
            ..showNameBottom =
                wlParams.showNameBottom ?? defaultWlParams.showNameBottom
            ..domainId = wlParams.domainId?.toBuilder()
            ..baseUrl = wlParams.baseUrl
            ..prohibitDifferentUrl = wlParams.prohibitDifferentUrl
            ..adminSettingsId = wlParams.adminSettingsId,
    );
  }

  static bool _isEmpty(String? str) {
    return str == null || str.isEmpty;
  }

  static bool _wlIsEqual<T>(T? current, T target) {
    if (current == null) return false;
    return current == target;
  }

  Future<void> updateWhiteLabeling() async {
    final region = await getIt<ILocalDatabaseService>().getSelectedRegion();
    if (region == null && !ThingsboardAppConstants.ignoreRegionSelection) {
      return;
    }
    if (ref.read(loginProvider).isFullyAuthenticated()) {
      await _loadUserWhiteLabelingParams();
    } else {
      await loadLoginWhiteLabelingParams();
    }
  }

  Future<void> loadLoginWhiteLabelingParams({BuildContext? context}) async {
    final response =
        await _tbClient
            .getWhiteLabelingControllerApi()
            .getLoginWhiteLabelParams();
    var loginWlParams = response.data;
    // platformVersion is always on the server side in the new client; no
    // getPlatformVersion() helper.
    var merged = _mergeLoginDefaults(loginWlParams, _defaultLoginWlParams);
    final loginThemeData = TbThemeUtils.createTheme(merged.paletteSettings);
    final loginLogo = await _updateImages(
      context ?? globalNavigatorKey.currentContext!,
      _tbClient,
      _loginToWlParams(merged),
      loginThemeData,
      true,
    );
    state = state.copyWith(
      loginWhiteLabelingParams: merged,
      theme: loginThemeData,
      logo: loginLogo,
      isUserWlMode: false,
    );
  }

  Future<void> _loadUserWhiteLabelingParams() async {
    final response =
        await _tbClient.getWhiteLabelingControllerApi().getWhiteLabelParams();
    var userWlParams = response.data;
    var merged = _mergeDefaults(userWlParams, _defaultWLParams);
    final themeData = TbThemeUtils.createTheme(merged.paletteSettings);
    final logo = await _updateImages(
      globalNavigatorKey.currentContext!,
      _tbClient,
      merged,
      themeData,
      false,
    );

    state = state.copyWith(
      userParams: merged,
      theme: themeData,
      logo: logo,
      isUserWlMode: true,
    );
    state = state.copyWith(isUserWlMode: true);
  }

  Future<Widget> _updateImages(
    BuildContext context,
    ThingsboardClient tbClient,
    WhiteLabelingParams wlParams,
    ThemeData themeData,
    bool isLogin,
  ) async {
    final double height = (wlParams.logoImageHeight ?? 36).toDouble() / 3 * 2;
    if (wlParams.logoImageUrl == defaultLogoUrl) {
      Region? region;
      return SvgPicture.asset(
        region == Region.europe
            ? ThingsboardImage.thingsBoardEUWithTitle
            : ThingsboardImage.thingsBoardWithTitle,
        height: height,
        colorFilter: ColorFilter.mode(themeData.primaryColor, BlendMode.srcIn),
        semanticsLabel: 'ThingsBoard Logo',
      );
    } else {
      return Utils.imageFromTbImage(
        context,
        tbClient,
        wlParams.logoImageUrl,
        height: height,
        semanticLabel: 'ThingsBoard Logo',
        loginLogo: isLogin,
      );
    }
  }
}
