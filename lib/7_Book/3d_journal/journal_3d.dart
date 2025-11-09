import 'package:flutter/material.dart';
import 'package:ui_showcases/7_Book/3d_journal/full_page_swipeable_journal.dart';
import 'package:ui_showcases/7_Book/3d_journal/journal_controller.dart';
import 'package:ui_showcases/7_Book/3d_journal/models/journal_shadows_configuration.dart';
import 'package:ui_showcases/7_Book/3d_journal/swipeable_journal.dart';
import 'package:ui_showcases/constants.dart';

class Journal3D extends StatelessWidget {
  final JournalController controller;
  final double? spreadWidth;
  final JournalViewMode viewMode;
  final JournalShadowsConfiguration shadowsConfiguration;
  final VoidCallback? onTap;

  const Journal3D({
    super.key,
    required this.controller,
    this.viewMode = JournalViewMode.fullPage,
    this.spreadWidth,
    this.shadowsConfiguration = const JournalShadowsConfiguration(),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final spreadWidth =
        this.spreadWidth ?? MediaQuery.of(context).size.width - 2 * kLPad;

    if (viewMode == JournalViewMode.fullPage) {
      return SizedBox(
        width: spreadWidth,
        child: FullPageSwipeableJournal(
          key: key,
          controller: controller,
          spreadWidth: spreadWidth,
          shadowsConfiguration: shadowsConfiguration,
          onTap: onTap,
        ),
      );
    } else {
      // Set two-page mode
      controller.setViewMode(JournalViewMode.twoPages);
      return SwipeableJournal(
        key: key,
        controller: controller,
        shadowsConfiguration: shadowsConfiguration,
        onTap: onTap,
      );
    }
  }
}
