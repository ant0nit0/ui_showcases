import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TravelAppHomeScreen extends StatelessWidget {
  const TravelAppHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        backgroundColor: Color(0xFFF4F6F8),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                _AppBar(),
                SizedBox(height: 24),
                _SearchBar(),
                SizedBox(height: 24),
                _SelectTrip(),
                SizedBox(height: 24),
                _Cards(),
                Spacer(),
                _BottomBar(),
              ],
            ),
          ),
        ));
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, John',
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            Text(
              'Welcome to TripGuide',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const Spacer(),
        const CircleAvatar(
          radius: 24,
          backgroundImage: AssetImage('assets/images/user_avatar.png'),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
      ),
      width: double.infinity,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
                .copyWith(right: 6),
            child: const Icon(Icons.search, size: 32),
          ),
          Text('Search',
              style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey)),
          const Spacer(),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF212528),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.filter_list, size: 26, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _SelectTrip extends StatelessWidget {
  const _SelectTrip();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select your next Trip',
            style: GoogleFonts.montserrat(
                fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 12,
            children: [
              _makeDestinationTile('Asia'),
              _makeDestinationTile('Europe'),
              _makeDestinationTile('South America', isSelected: true),
              _makeDestinationTile('Africa'),
              _makeDestinationTile('Australia'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _makeDestinationTile(String title, {bool isSelected = false}) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF212528) : Colors.white,
        borderRadius: BorderRadius.circular(100),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Text(title,
          style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: isSelected ? Colors.white : Colors.grey)),
    );
  }
}

class _Cards extends StatelessWidget {
  const _Cards();

  @override
  Widget build(BuildContext context) {
    const jungleUrl =
        "https://th.bing.com/th/id/R.b7816ba374fbfc59478e2b14ed1c9f78?rik=YWoH3H9CyuCCdA&riu=http%3a%2f%2fwallpapercave.com%2fwp%2fOxZ3YGU.jpg&ehk=9SySYHUiNRqISjAAwA49LMgqtdtBgCIO7my615nrxh4%3d&risl=&pid=ImgRaw&r=0.png";
    const mountainsUrl =
        "https://th.bing.com/th/id/R.f7530fdef06d86245c8cd739f2a5cf76?rik=EUjOSc4UjUYVCQ&riu=http%3a%2f%2fwww.pixelstalk.net%2fwp-content%2fuploads%2f2016%2f04%2fMountain-wallpaper-HD-pictures-images-photos.jpg&ehk=vq8nbZerNFD2C1EvsPq8%2fibw03iCbvqKJ%2bMAVqR4YRk%3d&risl=&pid=ImgRaw&r=0";

    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 24,
          bottom: 24,
          right: 24,
          child: Container(
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: NetworkImage(jungleUrl),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 24,
          left: 24,
          bottom: 24,
          child: Container(
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: NetworkImage(mountainsUrl),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        _makeMainCard(context),
      ],
    );
  }

  Widget _makeMainCard(BuildContext context) {
    const rioUrl =
        "https://a.cdn-hotels.com/gdcs/production90/d1313/e413c950-c31d-11e8-9739-0242ac110006.jpg";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 400,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: NetworkImage(rioUrl),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .2),
                  borderRadius: BorderRadius.circular(100),
                ),
                padding: const EdgeInsets.all(14),
                child:
                    const Icon(Icons.favorite, size: 24, color: Colors.white),
              ),
            ),
            Positioned(
              bottom: 16,
              top: 0,
              left: 12,
              right: 12,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Brazil',
                      style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white)),
                  Text('Rio de Janeiro',
                      style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          child: Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 14, color: Colors.white),
                              const SizedBox(width: 2),
                              Text('4.8',
                                  style: GoogleFonts.montserrat(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                            ],
                          )),
                      const SizedBox(width: 8),
                      Text('143 reviews',
                          style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: .75))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .5),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(100)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 30),
                        Text('See more',
                            style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                        Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(14),
                            child:
                                const Icon(Icons.arrow_forward_ios, size: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff212528),
        borderRadius: BorderRadius.circular(100),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(14),
            child: const Icon(Icons.house_outlined,
                size: 24, color: Color(0xff212528)),
          ),
          const Icon(Icons.search, size: 24, color: Colors.white),
          const Icon(Icons.person_outline, size: 24, color: Colors.white),
          const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Icon(Icons.favorite_border_rounded,
                size: 24, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
