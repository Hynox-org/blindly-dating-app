import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:blindly_dating_app/l10n/app_localizations.dart';
import 'package:blindly_dating_app/core/providers/connection_mode_provider.dart';
import 'package:blindly_dating_app/features/auth/repositories/Location_repository.dart';
import 'package:blindly_dating_app/features/spotlight/repository/spotlight_repository.dart';

/// Buy a spotlight: pick a window, confirm, done.
///
/// There is no payment provider yet. "Purchase" calls `purchase_spotlight`,
/// which writes a completed purchase — the screen is otherwise the real thing,
/// so wiring a gateway later only changes what happens between the tap and
/// that call.
class SpotlightScreen extends ConsumerStatefulWidget {
  const SpotlightScreen({super.key});

  @override
  ConsumerState<SpotlightScreen> createState() => _SpotlightScreenState();
}

class _SpotlightScreenState extends ConsumerState<SpotlightScreen> {
  late Future<List<SpotlightPackage>> _future;

  String? _selectedPackageId;
  String? _district;
  bool _busy = false;

  /// Drives the countdown on an active spotlight. Cancelled in dispose, or it
  /// keeps calling setState on a dead screen.
  Timer? _ticker;
  ActiveSpotlight? _active;

  String get _mode => ref.read(connectionModeProvider).toLowerCase();
  SpotlightRepository get _repo => ref.read(spotlightRepositoryProvider);

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<List<SpotlightPackage>> _load() async {
    final packages = await _repo.getPackages();

    // Neither of these should take the screen down: without them the user can
    // still read what Spotlight is, and the purchase itself re-checks.
    try {
      _active = await _repo.getActive(_mode);
    } catch (e) {
      debugPrint('⚠️ Spotlight: active lookup failed: $e');
    }
    try {
      _district = await _fetchDistrict();
    } catch (e) {
      debugPrint('⚠️ Spotlight: district lookup failed: $e');
    }

    _startTicker();
    _selectedPackageId ??= packages.isNotEmpty ? packages.first.id : null;
    return packages;
  }

  Future<String?> _fetchDistrict() async {
    final client = Supabase.instance.client;
    final uid = client.auth.currentUser?.id;
    if (uid == null) return null;
    final row = await client
        .from('profiles')
        .select('district')
        .eq('user_id', uid)
        .maybeSingle();
    final district = row?['district'] as String?;
    return (district == null || district.trim().isEmpty) ? null : district;
  }

  /// Takes a fresh fix and stores it, which is what resolves the district.
  /// Returns the district that landed, or null if we still don't know where
  /// they are — permission refused, GPS off, or the geocode failed.
  Future<String?> _resolveDistrictNow() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      // High, not medium: this fix decides which district the user is about
      // to be charged to appear in.
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 12),
      );
      await LocationService(
        Supabase.instance.client,
      ).pushLocation(position.latitude, position.longitude);

      // Awaited, not returned bare: otherwise a failure here escapes the
      // catch below and the caller gets an exception instead of null.
      return await _fetchDistrict();
    } catch (e) {
      debugPrint('⚠️ Spotlight: could not resolve district: $e');
      return null;
    }
  }

  Future<void> _purchase(SpotlightPackage package) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    void fail(String message) {
      if (!mounted) return;
      setState(() => _busy = false);
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }

    void succeed(ActiveSpotlight active) {
      if (!mounted) return;
      setState(() {
        _active = active;
        _district = active.district;
        _busy = false;
      });
      _startTicker();
      messenger.showSnackBar(SnackBar(content: Text(l10n.spotlightSuccess)));
    }

    setState(() => _busy = true);
    try {
      succeed(await _repo.purchase(package: package, mode: _mode));
    } on SpotlightNoDistrict {
      // Nobody has ever resolved a district for this account. Try once to fix
      // that ourselves rather than sending them away to find a setting.
      final district = await _resolveDistrictNow();
      if (!mounted) return;
      if (district == null) {
        fail(l10n.spotlightNoDistrict);
        return;
      }
      setState(() => _district = district);
      try {
        succeed(await _repo.purchase(package: package, mode: _mode));
      } catch (e) {
        debugPrint('❌ Spotlight purchase retry failed: $e');
        fail(l10n.spotlightFailed);
      }
    } catch (e) {
      debugPrint('❌ Spotlight purchase failed: $e');
      fail(l10n.spotlightFailed);
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    if (_active == null) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (!_active!.expiresAt.isAfter(DateTime.now())) {
        _ticker?.cancel();
        setState(() => _active = null);
      } else {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: theme.colorScheme.onSurface,
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.spotlight,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<SpotlightPackage>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final packages = snapshot.data;
          if (snapshot.hasError || packages == null || packages.isEmpty) {
            return Center(child: Text(l10n.spotlightFailed));
          }
          return _body(theme, l10n, packages);
        },
      ),
    );
  }

  Widget _body(
    ThemeData theme,
    AppLocalizations l10n,
    List<SpotlightPackage> packages,
  ) {
    final active = _active;
    SpotlightPackage? selected;
    for (final package in packages) {
      if (package.id == _selectedPackageId) selected = package;
    }

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                if (active != null) _activeBanner(theme, l10n, active),
                Icon(Icons.cyclone, size: 56, color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  l10n.spotlightHeadline,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.spotlightExplainer,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _district == null
                      ? l10n.spotlightDistrictUnknown
                      : l10n.spotlightDistrictLine(_district!),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 28),
                Text(
                  l10n.spotlightChooseDuration,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                for (final package in packages) ...[
                  _packageTile(theme, l10n, package),
                  const SizedBox(height: 10),
                ],

                const SizedBox(height: 20),
                _rule(theme, Icons.tune, l10n.spotlightRuleFilters),
                _rule(theme, Icons.place_outlined, l10n.spotlightRuleAudience),
                _rule(theme, Icons.block, l10n.spotlightRuleSkipped),

                const SizedBox(height: 20),
                Text(
                  l10n.spotlightTestPurchase,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: (_busy || selected == null)
                    ? null
                    : () => _purchase(selected!),
                child: _busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        active == null
                            ? l10n.spotlightBuy
                            : l10n.spotlightExtend,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _activeBanner(
    ThemeData theme,
    AppLocalizations l10n,
    ActiveSpotlight active,
  ) {
    final remaining = active.expiresAt.difference(DateTime.now());
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.bolt, color: theme.colorScheme.onPrimaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.spotlightLiveIn(active.district),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  l10n.spotlightTimeLeft(formatRemaining(remaining)),
                  style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _packageTile(
    ThemeData theme,
    AppLocalizations l10n,
    SpotlightPackage package,
  ) {
    final isSelected = package.id == _selectedPackageId;
    final label = package.durationMinutes == 60
        ? l10n.spotlightOneHour
        : l10n.spotlightMinutes('${package.durationMinutes}');

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => setState(() => _selectedPackageId = package.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.08)
              : theme.colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              l10n.spotlightPrice(package.priceInr.toStringAsFixed(0)),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rule(ThemeData theme, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// `h:mm:ss` past an hour, `m:ss` under it. Never negative — an expired window
/// reads 0:00 rather than counting backwards.
String formatRemaining(Duration d) {
  if (d.isNegative) return '0:00';
  final minutes = d.inMinutes;
  final seconds = d.inSeconds % 60;
  if (minutes >= 60) {
    return '${d.inHours}:${(minutes % 60).toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
