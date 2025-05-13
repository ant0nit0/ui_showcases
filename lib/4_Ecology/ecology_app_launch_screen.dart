import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

const _primaryColor = Color(0xffFD7D39);
const _secondaryColor = Color(0xff0C272F);
const _blueColor = Color(0xff67D9F2);

class EcologyAppLaunchScreen extends StatelessWidget {
  const EcologyAppLaunchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24, width: double.infinity),
            Image.asset('assets/images/ecology/logo_dark.png', width: 100),
            const SizedBox(height: 32),
            Text(
              'Learn how to\ncare for the\nenvironment',
              style: GoogleFonts.fredoka(
                fontSize: 48,
                fontWeight: FontWeight.w600,
                height: 1,
                color: _secondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EcologyAppOnboarding(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Start now',
                  style: GoogleFonts.fredoka(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _secondaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Skip',
              style: GoogleFonts.fredoka(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _secondaryColor,
              ),
            ),
            Image.asset('assets/images/ecology/1.png', width: double.infinity),
          ],
        ),
      ),
    );
  }
}

class EcologyAppOnboarding extends HookWidget {
  const EcologyAppOnboarding({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = usePageController();

    final currentPage = useState(0);

    return Scaffold(
      body: AnimatedContainer(
        color: currentPage.value == 0
            ? _secondaryColor
            : currentPage.value == 1
                ? Colors.white
                : currentPage.value == 2
                    ? _blueColor
                    : Colors.white,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Stack(
          children: [
            Positioned.fill(
              child: PageView(
                onPageChanged: (value) {
                  currentPage.value = value;
                },
                controller: controller,
                children: const [
                  EcologyAppOnboardingPage(
                    darkLogo: false,
                    imageName: '2',
                    title: 'Grow your own garden in your own backyard',
                  ),
                  EcologyAppOnboardingPage(
                    darkLogo: true,
                    imageName: '3',
                    title: 'Cook healthy, green foods for you and your family',
                  ),
                  EcologyAppLastOnboardingPage(),
                ],
              ),
            ),
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    SmoothPageIndicator(
                      controller: controller,
                      count: 3,
                      effect: ExpandingDotsEffect(
                        dotColor: _primaryColor.withValues(alpha: .25),
                        activeDotColor: _primaryColor,
                        paintStyle: PaintingStyle.fill,
                        strokeWidth: 1,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: SizedBox(
                        width: currentPage.value == 2 ? double.infinity : null,
                        child: ElevatedButton(
                          onPressed: () {
                            controller.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            'Next',
                            style: GoogleFonts.fredoka(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _secondaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EcologyAppOnboardingPage extends StatelessWidget {
  final bool darkLogo;
  final String imageName;
  final String title;
  const EcologyAppOnboardingPage({
    super.key,
    this.darkLogo = false,
    required this.imageName,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 60),
        Image.asset(
          'assets/images/ecology/logo_${darkLogo ? 'dark' : 'light'}.png',
          width: 120,
        ),
        Image.asset('assets/images/ecology/$imageName.png',
            width: double.infinity),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            title,
            style: GoogleFonts.fredoka(
              fontSize: 36,
              fontWeight: FontWeight.w600,
              height: 1,
              color: darkLogo ? _secondaryColor : Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class EcologyAppLastOnboardingPage extends StatelessWidget {
  const EcologyAppLastOnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 60),
        Image.asset(
          'assets/images/ecology/logo_dark.png',
          width: 120,
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Take care of the earth today',
            style: GoogleFonts.fredoka(
              fontSize: 36,
              fontWeight: FontWeight.w600,
              height: 1,
              color: _secondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
            child: Transform.translate(
          offset: const Offset(0, 100),
          child: Transform.scale(
            scale: 1.3,
            child: Image.asset('assets/images/ecology/4.png',
                width: double.infinity, fit: BoxFit.cover),
          ),
        )),
      ],
    );
  }
}
