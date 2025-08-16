import 'package:flutter/material.dart';

/// Configuration for page/item shadows in the 3D journal.
class JournalShadowsConfiguration {
  /// Whether shadows are enabled.
  final bool enabled;

  /// Base color of the shadow. Opacity will be respected from this color.
  final Color color;

  /// Gaussian blur radius (logical px). Higher = softer shadow.
  final double blurRadius;

  /// Extra spread around the page rect before blurring.
  final double spreadRadius;

  /// Offset applied to the shadow in page-local coordinates
  /// (transformed by the current 3D transform).
  final Offset offset;

  const JournalShadowsConfiguration({
    this.enabled = true,
    this.color = const Color(0x99000000),
    this.blurRadius = 16.0,
    this.spreadRadius = 4.0,
    this.offset = const Offset(0, 8),
  });
}
