import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ui_showcases/7_Book/3d_journal/journal_controller.dart';
import 'package:ui_showcases/7_Book/3d_journal/journal_fake_page.dart';
import 'package:ui_showcases/7_Book/3d_journal/models/journal_shadows_configuration.dart';
import 'package:ui_showcases/7_Book/3d_journal/swipeable_journal.dart';
import 'package:ui_showcases/constants.dart';

class BookScreen extends HookWidget {
  const BookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pageIndex = useState(0);
    final spreadWidth = MediaQuery.of(context).size.width - 2 * kLPad;
    final pages = List.generate(
      10,
      (index) => JournalFakePage(index: index),
    );

    // Create controller with initial pages
    final controller = useMemoized(
      () => JournalController(
        pages: pages,
        spreadWidth: spreadWidth,
        initialIndex: pages.length - 1,
        perspective: .0005,
        animationDuration: const Duration(milliseconds: 600),
        idleTiltDegrees: 14,
        stackedItemsTranslateFactor: 15,
        onPageChanged: (index) {
          pageIndex.value = index;
          debugPrint('pageIndex: $index');
        },
      ),
      [],
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SwipeableJournal(
              controller: controller,
              shadowsConfiguration: JournalShadowsConfiguration(
                blurRadius: 20,
                spreadRadius: 10,
                color: Colors.black.withValues(alpha: 0.25),
                offset: const Offset(10, 10),
              ),
              onTap: () {
                debugPrint('Journal tapped');
              },
            ),
            const SizedBox(height: kLPad),
            Row(
              children: [
                IconButton(
                  onPressed: () => controller.previousPage(),
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  'Page: ${pageIndex.value}',
                ),
                IconButton(
                  onPressed: () => controller.nextPage(),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const Text('Animate To'),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  controller.totalPages,
                  (index) => TextButton(
                    onPressed: () => controller.animateTo(index),
                    onLongPress: () => controller.jumpTo(index),
                    child: Text('Page $index'),
                  ),
                ),
              ),
            ),
            // Example: Add/Remove/Insert pages
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    controller
                        .addPage(JournalFakePage(index: controller.totalPages));
                  },
                  child: const Text('Add Page'),
                ),
                TextButton(
                  onPressed: () {
                    // Insert a page at the current page index
                    final insertIndex = Random().nextInt(controller.totalPages);
                    debugPrint('insertIndex: $insertIndex');
                    controller.insertPage(
                      insertIndex,
                      JournalFakePage(index: insertIndex),
                    );
                  },
                  child: const Text('Insert Page'),
                ),
                TextButton(
                  onPressed: () {
                    if (controller.totalPages > 0) {
                      controller.removeCurrentPage();
                    }
                  },
                  child: const Text('Remove Page'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
