import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:social_media/Controller/Services/Database/database_services.dart';
import 'package:social_media/Utils/Components/post_card.dart';
import 'package:social_media/Model/post_model.dart';
import 'package:social_media/Utils/Components/comment_sheet.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class InterfacePage extends StatelessWidget {
  const InterfacePage({super.key});

  Future<void> _onRefresh(BuildContext context) async {
    // Trigger a rebuild of the StreamBuilder
    context.read<DatabaseServices>().refreshPosts();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: LiquidPullToRefresh(
          onRefresh: () => _onRefresh(context),
          color: color.primary,
          backgroundColor: color.surface,
          height: 80,
          animSpeedFactor: 2,
          showChildOpacityTransition: true,
          child: CustomScrollView(
            physics: const ScrollPhysics(parent: BouncingScrollPhysics()),
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
                  return StreamBuilder<List<PostModel>>(
                    stream: databaseProvider.getPostsStream(),
                    builder: (
                      context,
                      AsyncSnapshot<List<PostModel>> snapshot,
                    ) {
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
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.8,
                            color: Theme.of(context).colorScheme.surface,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline_rounded,
                                    color: color.error,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "Something went wrong: ${snapshot.error}",
                                    style: GoogleFonts.poppins(
                                      color: color.error,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      final posts = snapshot.data;
                      if (posts == null || posts.isEmpty) {
                        return SliverToBoxAdapter(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.8,
                            color: Theme.of(context).colorScheme.surface,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Iconsax.image,
                                    color: color.primary,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "No posts yet",
                                    style: GoogleFonts.poppins(
                                      color: color.primary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      // Ensure posts are sorted by createdAt in descending order
                      final sortedPosts = List<PostModel>.from(posts)..sort(
                        (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
                          a.createdAt ?? DateTime.now(),
                        ),
                      );

                      return SliverList.builder(
                        itemCount: sortedPosts.length,
                        itemBuilder: (context, index) {
                          final post = sortedPosts[index];
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
                              post.likedBy ?? [],
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
                            postId: post.postId!,
                            userEmail: post.userEmail ?? '',
                            userId: post.userId ?? '',
                            likedBy: post.likedBy ?? [],
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
      ),
    );
  }
}
