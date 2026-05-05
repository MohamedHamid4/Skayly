import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/errors/failures.dart';
import '../../localization/app_localizations.dart';
import 'glass_card.dart';

class ErrorView extends StatelessWidget {
  final AppFailure failure;
  final VoidCallback onRetry;
  final VoidCallback onSearchCity;

  const ErrorView({
    super.key,
    required this.failure,
    required this.onRetry,
    required this.onSearchCity,
  });

  bool get _isLocationIssue =>
      failure is LocationFailure || failure is PermissionFailure;

  IconData get _icon =>
      _isLocationIssue ? Icons.location_off_outlined : Icons.cloud_off_rounded;

  ({String title, String body}) _copy(AppLocalizations t) {
    final f = failure;
    if (f is LocationFailure) {
      return (
        title: t.t('loc_disabled_title'),
        body: t.t('loc_disabled_body'),
      );
    }
    if (f is PermissionFailure) {
      return (
        title: t.t('loc_permission_title'),
        body: t.t('loc_permission_body'),
      );
    }
    final key = switch (f) {
      NetworkFailure() => 'err_network',
      ApiFailure() => 'err_api',
      UnknownFailure() => 'err_unknown',
      _ => 'err_unknown',
    };
    return (title: t.t(key), body: '');
  }

  Future<void> _openSystemSettings() async {
    final f = failure;
    // Permission denied → app permission settings let the user grant access.
    // Services off → location-services settings let the user enable GPS.
    if (f is PermissionFailure) {
      await openAppSettings();
    } else if (f is LocationFailure) {
      await Geolocator.openLocationSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final copy = _copy(t);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _icon,
                size: 56,
                color: Colors.white.withValues(alpha: 0.85),
              ),
              const SizedBox(height: 16),
              Text(
                copy.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              if (copy.body.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  copy.body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  if (_isLocationIssue)
                    FilledButton.tonalIcon(
                      onPressed: _openSystemSettings,
                      icon: const Icon(Icons.settings_outlined),
                      label: Text(t.t('open_settings')),
                    )
                  else
                    FilledButton.tonalIcon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: Text(t.t('retry')),
                    ),
                  TextButton.icon(
                    onPressed: onSearchCity,
                    icon: const Icon(Icons.search, color: Colors.white),
                    label: Text(
                      t.t('err_search_city_cta'),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
