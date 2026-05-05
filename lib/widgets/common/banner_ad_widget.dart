import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/constants/app_constants.dart';

/// Reserves 50dp height even when the ad fails to load, so the layout
/// doesn't visibly jump on "no fill" responses.
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  static const double reservedHeight = 50;

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  bool get _isMobile {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  String? get _unitId {
    if (kIsWeb) return null;
    if (Platform.isAndroid) return AppConstants.effectiveAdmobBannerAndroid;
    if (Platform.isIOS) return AppConstants.effectiveAdmobBanneriOS;
    return null;
  }

  void _load() {
    if (!_isMobile) return;
    final unitId = _unitId;
    if (unitId == null) return;
    final ad = BannerAd(
      adUnitId: unitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    ad.load();
    _ad = ad;
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    final showAd = _isMobile && _loaded && ad != null;
    return SizedBox(
      width: double.infinity,
      height: BannerAdWidget.reservedHeight,
      child: showAd
          ? Center(
              child: SizedBox(
                width: ad.size.width.toDouble(),
                height: ad.size.height.toDouble(),
                child: AdWidget(ad: ad),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
