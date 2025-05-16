import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_media/Utils/Components/custom_button.dart';
import 'package:social_media/Utils/size.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        handleTitle(context),
                        verticalSpace(33),
                        Theme.of(context).brightness == Brightness.light
                            ? Image.asset(
                              'assets/icons/icon_blynd_light.png',
                              height: 199,
                              width: 280,
                            )
                            : Image.asset(
                              'assets/icons/icon_blynd_dark.png',
                              height: 199,
                              width: 280,
                            ),
                        Center(
                          child: Text(
                            "BLYND sees what others don't!",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: size.height * 0.022,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        verticalSpace(size.height * 0.22),
                        CustomButton(
                          text: "Login",
                          isLoading: false,
                          onTap:
                              () => Navigator.of(context).pushNamed('/login'),
                        ),
                        verticalSpace(14),
                        CustomButton(
                          text: "Register",
                          isLoading: false,
                          onTap:
                              () => Navigator.of(context).pushNamed('/sign_up'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SizedBox handleTitle(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return SizedBox(
      height: 141,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 1,
            child: Text(
              'Welcome to',
              style: GoogleFonts.jomhuria(
                fontSize: screenWidth(context) * (2.6 / 15),
                // fontSize: 64,
                color: color.primary,
              ),
            ),
          ),
          Positioned(
            bottom: 1,
            child: Text(
              "BLYND",
              style: GoogleFonts.jomhuria(
                fontSize: screenWidth(context) * (2.5 / 15),
                // fontSize: 60,
                color: color.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
