import 'dart:convert';

import 'package:hiddify/core/prefs/general_prefs.dart';
import 'package:hiddify/core/prefs/prefs_state.dart';
import 'package:hiddify/data/data_providers.dart';
import 'package:hiddify/domain/clash/clash.dart';
import 'package:hiddify/domain/connectivity/connectivity.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'prefs_controller.g.dart';

@Riverpod(keepAlive: true)
class PrefsController extends _$PrefsController with AppLogger {
  @override
  PrefsState build() {
    return PrefsState(
      general: _getGeneralPrefs(),
      clash: _getClashPrefs(),
      network: _getNetworkPrefs(),
    );
  }

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  static const _generalKey = "general_prefs";
  static const _overridesKey = "clash_overrides";
  static const _networkKey = "network_prefs";

  GeneralPrefs _getGeneralPrefs() {
    final persisted = _prefs.getString(_generalKey);
    if (persisted == null) return const GeneralPrefs();
    return GeneralPrefs.fromJson(jsonDecode(persisted) as Map<String, dynamic>);
  }

  ClashConfig _getClashPrefs() {
    final persisted = _prefs.getString(_overridesKey);
    if (persisted == null) return const ClashConfig();
    return ClashConfig.fromJson(jsonDecode(persisted) as Map<String, dynamic>);
  }

  NetworkPrefs _getNetworkPrefs() {
    final persisted = _prefs.getString(_networkKey);
    if (persisted == null) return const NetworkPrefs();
    return NetworkPrefs.fromJson(jsonDecode(persisted) as Map<String, dynamic>);
  }

  Future<void> patchGeneralPrefs({bool? silentStart}) async {
    final newPrefs = state.general.copyWith(
      silentStart: silentStart ?? state.general.silentStart,
    );
    await _prefs.setString(_generalKey, jsonEncode(newPrefs.toJson()));
    state = state.copyWith(general: newPrefs);
  }

  Future<void> patchClashOverrides(ClashConfigPatch overrides) async {
    final newPrefs = state.clash.patch(overrides);
    await _prefs.setString(_overridesKey, jsonEncode(newPrefs.toJson()));
    state = state.copyWith(clash: newPrefs);
  }

  Future<void> patchNetworkPrefs({
    bool? systemProxy,
    bool? bypassPrivateNetworks,
  }) async {
    final newPrefs = state.network.copyWith(
      systemProxy: systemProxy ?? state.network.systemProxy,
      bypassPrivateNetworks:
          bypassPrivateNetworks ?? state.network.bypassPrivateNetworks,
    );
    await _prefs.setString(_networkKey, jsonEncode(newPrefs.toJson()));
    state = state.copyWith(network: newPrefs);
  }
}
