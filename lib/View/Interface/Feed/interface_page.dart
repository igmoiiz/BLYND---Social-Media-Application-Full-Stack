import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_media/Utils/Components/post_card.dart';

class InterfacePage extends StatelessWidget {
  const InterfacePage({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            elevation: 0.0,
            pinned: false,
            floating: true,
            title: Text(
              "BLYND",
              style: TextStyle(
                color: color.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                fontFamily: GoogleFonts.montserrat().fontFamily,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: Icon(FontAwesomeIcons.facebookMessenger),
              ),
            ],
          ),
          SliverList.builder(
            itemCount: 10000,
            itemBuilder: (context, index) {
              return PostCard(
                userName: "Moiz Baloch",
                userImageUrl: " ",
                postImageUrl: " ",
                description: "Hello",
                onLike: () {},
                onComment: () {},
                onSave: () {},
              );
            },
          ),
        ],
      ),
    );
  }
}
