import 'package:hiddify/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesMigration with InfraLogger {
  PreferencesMigration({required this.sharedPreferences});

  final SharedPreferences sharedPreferences;

  static const versionKey = "preferences_version";

  Future<void> migrate() async {
    final currentVersion = sharedPreferences.getInt(versionKey) ?? 0;

    final List<PreferencesMigrationStep> migrationSteps = [
      PreferencesVersion1Migration(sharedPreferences),
      PreferencesVersion2Migration(sharedPreferences),
      PreferencesVersion3Migration(sharedPreferences),
      PreferencesVersion4Migration(sharedPreferences),
    ];

    if (currentVersion == migrationSteps.length) {
      loggy.debug("already using the latest version (v$currentVersion)");
      return;
    }

    final stopWatch = Stopwatch()..start();
    loggy.debug(
      "migrating from v[$currentVersion] to v[${migrationSteps.length}]",
    );
    for (int i = currentVersion; i < migrationSteps.length; i++) {
      loggy.debug("step [$i](v${i + 1})");
      await migrationSteps[i].migrate();
      await sharedPreferences.setInt(versionKey, i + 1);
    }
    stopWatch.stop();
    loggy.debug("migration took [${stopWatch.elapsedMilliseconds}]ms");
  }
}

abstract interface class PreferencesMigrationStep {
  PreferencesMigrationStep(this.sharedPreferences);

  final SharedPreferences sharedPreferences;

  Future<void> migrate();
}

class PreferencesVersion1Migration extends PreferencesMigrationStep
    with InfraLogger {
  PreferencesVersion1Migration(super.sharedPreferences);

  @override
  Future<void> migrate() async {
    if (sharedPreferences.getString("service-mode")
        case final String serviceMode) {
      final newMode = switch (serviceMode) {
        "proxy" || "system-proxy" || "vpn" => serviceMode,
        "systemProxy" => "system-proxy",
        "tun" => "vpn",
        _ => PlatformUtils.isDesktop ? "system-proxy" : "proxy",
      };
      loggy.debug(
        "changing service-mode from [$serviceMode] to [$newMode]",
      );
      await sharedPreferences.setString("service-mode", newMode);
    }

    if (sharedPreferences.getString("ipv6-mode") case final String ipv6Mode) {
      loggy.debug(
        "changing ipv6-mode from [$ipv6Mode] to [${_ipv6Mapper(ipv6Mode)}]",
      );
      await sharedPreferences.setString("ipv6-mode", _ipv6Mapper(ipv6Mode));
    }

    if (sharedPreferences.getString("remote-domain-dns-strategy")
        case final String remoteDomainStrategy) {
      loggy.debug(
        "changing [remote-domain-dns-strategy] = [$remoteDomainStrategy] to [remote-dns-domain-strategy] = [${_domainStrategyMapper(remoteDomainStrategy)}]",
      );
      await sharedPreferences.remove("remote-domain-dns-strategy");
      await sharedPreferences.setString(
        "remote-dns-domain-strategy",
        _domainStrategyMapper(remoteDomainStrategy),
      );
    }

    if (sharedPreferences.getString("direct-domain-dns-strategy")
        case final String directDomainStrategy) {
      loggy.debug(
        "changing [direct-domain-dns-strategy] = [$directDomainStrategy] to [direct-dns-domain-strategy] = [${_domainStrategyMapper(directDomainStrategy)}]",
      );
      await sharedPreferences.remove("direct-domain-dns-strategy");
      await sharedPreferences.setString(
        "direct-dns-domain-strategy",
        _domainStrategyMapper(directDomainStrategy),
      );
    }

    if (sharedPreferences.getInt("localDns-port") case final int localDnsPort) {
      loggy.debug("changing [localDns-port] to [local-dns-port]");
      await sharedPreferences.remove("localDns-port");
      await sharedPreferences.setInt("local-dns-port", localDnsPort);
    }

    await sharedPreferences.remove("execute-config-as-is");
    await sharedPreferences.remove("enable-tun");
    await sharedPreferences.remove("set-system-proxy");

    await sharedPreferences.remove("cron_profiles_update");
  }

  String _ipv6Mapper(String persisted) => switch (persisted) {
        "ipv4_only" ||
        "prefer_ipv4" ||
        "prefer_ipv4" ||
        "ipv6_only" =>
          persisted,
        "disable" => "ipv4_only",
        "enable" => "prefer_ipv4",
        "prefer" => "prefer_ipv6",
        "only" => "ipv6_only",
        _ => "ipv4_only",
      };

  String _domainStrategyMapper(String persisted) => switch (persisted) {
        "ipv4_only" ||
        "prefer_ipv4" ||
        "prefer_ipv4" ||
        "ipv6_only" =>
          persisted,
        "auto" => "",
        "preferIpv6" => "prefer_ipv6",
        "preferIpv4" => "prefer_ipv4",
        "ipv4Only" => "ipv4_only",
        "ipv6Only" => "ipv6_only",
        _ => "",
      };
}

/// Go Bull: switch default DNS from UDP to DNS-over-TLS (DoT) for users that
/// never changed the defaults.
class PreferencesVersion4Migration extends PreferencesMigrationStep
    with InfraLogger {
  PreferencesVersion4Migration(super.sharedPreferences);

  static const _remoteDotDefault = "tls://77.88.8.8";
  static const _directDotDefault = "tls://77.88.8.1";

  @override
  Future<void> migrate() async {
    final remote = sharedPreferences.getString("remote-dns-address");
    if (remote == null || remote == "udp://77.88.8.8") {
      loggy.debug(
        "changing [remote-dns-address] from [${remote ?? "(null)"}] to [$_remoteDotDefault]",
      );
      await sharedPreferences.setString("remote-dns-address", _remoteDotDefault);
    }

    final direct = sharedPreferences.getString("direct-dns-address");
    if (direct == null || direct == "udp://77.88.8.1") {
      loggy.debug(
        "changing [direct-dns-address] from [${direct ?? "(null)"}] to [$_directDotDefault]",
      );
      await sharedPreferences.setString("direct-dns-address", _directDotDefault);
    }
  }
}

/// Go Bull: полностью отключаем VPN/TUN routing на мобильных, даже если он был включен ранее.
class PreferencesVersion2Migration extends PreferencesMigrationStep with InfraLogger {
  PreferencesVersion2Migration(super.sharedPreferences);

  @override
  Future<void> migrate() async {
    if (PlatformUtils.isDesktop) return;

    // Go Bull: не даём выставлять RU как регион по умолчанию, чтобы .ru не уходили в обход напрямую.
    // Любые правила/обходы для RU должны быть отключены -> используем "other".
    final region = sharedPreferences.getString("region");
    if (region == "ru") {
      loggy.debug("forcing region to [other] on mobile (was [ru])");
      await sharedPreferences.setString("region", "other");
    }
  }
}

/// Go Bull: introduce first-time "subscription gate" without locking existing users out.
/// If user already passed the old intro, consider first-setup completed.
class PreferencesVersion3Migration extends PreferencesMigrationStep with InfraLogger {
  PreferencesVersion3Migration(super.sharedPreferences);

  @override
  Future<void> migrate() async {
    final introCompleted = sharedPreferences.getBool("intro_completed");
    if (introCompleted == true) {
      loggy.debug("setting [first_setup_completed]=true based on [intro_completed]=true");
      await sharedPreferences.setBool("first_setup_completed", true);
    }
  }
}
