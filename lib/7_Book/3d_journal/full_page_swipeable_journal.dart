import 'package:flutter/material.dart';
import 'package:ui_showcases/7_Book/3d_journal/journal_controller.dart';
import 'package:ui_showcases/7_Book/3d_journal/models/journal_shadows_configuration.dart';
import 'package:ui_showcases/7_Book/3d_journal/swipeable_journal.dart';

/// A wrapper around [SwipeableJournal] that sets up full-page mode.
///
/// This widget configures the controller for full-page mode and provides
/// the spread width. The controller handles the page doubling internally.
class FullPageSwipeableJournal extends StatelessWidget {
  final JournalController controller;
  final double spreadWidth;
  final JournalShadowsConfiguration shadowsConfiguration;
  final VoidCallback? onTap;

  const FullPageSwipeableJournal({
    super.key,
    required this.controller,
    required this.spreadWidth,
    this.shadowsConfiguration = const JournalShadowsConfiguration(),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Set the view mode and spread width on the controller
    controller.setViewMode(JournalViewMode.fullPage, spreadWidth: spreadWidth);

    return SwipeableJournal(
      controller: controller,
      shadowsConfiguration: shadowsConfiguration,
      onTap: onTap,
    );
  }
}
