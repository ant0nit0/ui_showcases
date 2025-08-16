import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ui_showcases/7_Book/3d_journal/journal_3d.dart';
import 'package:ui_showcases/7_Book/3d_journal/journal_controller.dart';
import 'package:ui_showcases/7_Book/3d_journal/journal_fake_page.dart';
import 'package:ui_showcases/7_Book/3d_journal/models/journal_shadows_configuration.dart';
import 'package:ui_showcases/constants.dart';

class BookScreen extends HookWidget {
  const BookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pageIndex = useState(0);
    final spreadWidth = MediaQuery.of(context).size.width - 2 * kLPad;
    final controller = useMemoized(() => JournalController(), []);
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Journal3D(
              shadowsConfiguration: JournalShadowsConfiguration(
                blurRadius: 20,
                spreadRadius: 10,
                color: Colors.black.withValues(alpha: 0.25),
                offset: const Offset(10, 10),
              ),
              controller: controller,
              spreadWidth: spreadWidth,
              viewMode: JournalViewMode.fullPage,
              perspective: .0005,
              animationDuration: const Duration(milliseconds: 600),
              idleTiltDegrees: 14,
              stackedItemsTranslateFactor: 15,
              onPageChanged: (index) {
                pageIndex.value = index;
                debugPrint('pageIndex: $index');
              },
              pages:
                  List.generate(10, (index) => JournalFakePage(index: index)),
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
          ],
        ),
      ),
    );
  }
}
