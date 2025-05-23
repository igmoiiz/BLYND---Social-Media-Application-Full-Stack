import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:social_media/Controller/Services/Database/database_services.dart';
import 'package:social_media/Utils/Components/post_card.dart';
import 'package:social_media/Model/post_model.dart';
import 'package:social_media/Utils/Components/comment_sheet.dart';

class InterfacePage extends StatelessWidget {
  const InterfacePage({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    // final size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: ScrollPhysics(parent: BouncingScrollPhysics()),
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

            Consumer<DatabaseServices>(
              builder: (context, databaseProvider, child) {
                return StreamBuilder(
                  stream:
                      databaseProvider.fireStore
                          .collection("Posts")
                          .snapshots(),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SliverToBoxAdapter(
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.8,
                          color: Theme.of(context).colorScheme.surface,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    color.primary,
                                  ),
                                  strokeWidth: 2,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "Loading posts...",
                                  style: GoogleFonts.poppins(
                                    color: color.primary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return SliverToBoxAdapter(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 10,
                          children: [
                            Icon(Icons.error_outline_rounded),
                            Text("Something went wrong: ${snapshot.error}"),
                          ],
                        ),
                      );
                    }
                    final data = snapshot.data!.docs;
                    return SliverList.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final post = PostModel.fromJson(data[index].data());
                        return PostCard(
                          userName: post.userName ?? 'Unknown User',
                          userImageUrl:
                              post.userProfileImage ??
                              'https://via.placeholder.com/150',
                          postImageUrl:
                              post.postImage ??
                              'https://via.placeholder.com/150',
                          description: post.caption ?? '',
                          isLiked: databaseProvider.hasUserLikedPost(
                            post.likedBy,
                          ),
                          onLike:
                              () => databaseProvider.toggleLike(post.postId!),
                          onComment: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder:
                                  (context) => CommentSheet(
                                    postId: post.postId!,
                                    comments: post.comments ?? [],
                                  ),
                            );
                          },
                          onSave: () {},
                          createdAt: post.createdAt ?? DateTime.now(),
                          likeCount: post.likeCount ?? 0,
                          comments: post.comments,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
