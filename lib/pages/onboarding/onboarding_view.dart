import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
// import svg package
import 'package:flutter_svg/flutter_svg.dart';
import 'package:monify/constants.dart';
import 'package:monify/pages/onboarding/paywall_screen.dart';
import 'package:monify/pages/onboarding/welcome_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../auth/login_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController();
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.9,
            child: PageView(
              onPageChanged: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              controller: controller,
              children: const [
                WelcomeScreen(),
                // PaywallScreen(),
                // Container(
                //   color: Colors.blue,
                // ),
              ],
            ),
          ),
          // SmoothPageIndicator(
          //   controller: controller,
          //   count: 1,
          //   effect: const WormEffect(
          //     activeDotColor: kPrimaryColor,
          //   ),
          // )
          ElevatedButton(
            onPressed: () => {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginView()),
              )
            },
            child: Text('Get Started'),
          ),
        ],
      ),
    );
  }

  Widget _indicator(bool isActive) {
    return Container(
      height: 10,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        margin: EdgeInsets.symmetric(horizontal: 4.0),
        height: isActive ? 10 : 8.0,
        width: isActive ? 12 : 8.0,
        decoration: BoxDecoration(
          boxShadow: [
            isActive
                ? BoxShadow(
                    color: Color(0XFF2FB7B2).withOpacity(0.72),
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                    offset: Offset(
                      0.0,
                      0.0,
                    ),
                  )
                : BoxShadow(
                    color: Colors.transparent,
                  )
          ],
          shape: BoxShape.circle,
          color: isActive ? Color(0XFF6BC4C9) : Color(0XFFEAEAEA),
        ),
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < 2; i++) {
      list.add(i == _selectedIndex ? _indicator(true) : _indicator(false));
    }
    return list;
  }
}
