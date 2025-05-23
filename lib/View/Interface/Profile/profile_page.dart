import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:social_media/Controller/Services/Database/database_services.dart';
import 'package:social_media/Model/post_model.dart';
import 'package:social_media/Utils/Components/post_card.dart';
import 'package:social_media/Utils/Navigation/app_custom_route.dart';
import 'package:social_media/View/Interface/Settings/settings_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfilePage extends StatefulWidget {
  final String? userId;

  const ProfilePage({super.key, this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = false;

  Future<void> _toggleFollow() async {
    if (widget.userId == null) return;

    setState(() => _isLoading = true);
    try {
      await context.read<DatabaseServices>().toggleFollow(widget.userId!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showFollowers() {
    if (widget.userId == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.9,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            builder:
                (context, scrollController) => Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Followers',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<List<Map<String, dynamic>>>(
                        stream: context
                            .read<DatabaseServices>()
                            .getUserFollowers(widget.userId!),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final followers = snapshot.data ?? [];
                          if (followers.isEmpty) {
                            return Center(
                              child: Text(
                                'No followers yet',
                                style: GoogleFonts.poppins(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            controller: scrollController,
                            itemCount: followers.length,
                            itemBuilder: (context, index) {
                              final follower = followers[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(
                                    follower['profileImage'] ??
                                        'https://via.placeholder.com/150',
                                  ),
                                ),
                                title: Text(follower['name'] ?? 'Unknown User'),
                                trailing:
                                    follower['userId'] !=
                                            context
                                                .read<DatabaseServices>()
                                                .auth
                                                .currentUser
                                                ?.uid
                                        ? FutureBuilder<bool>(
                                          future: context
                                              .read<DatabaseServices>()
                                              .isFollowingUser(
                                                follower['userId'],
                                              ),
                                          builder: (context, snapshot) {
                                            final isFollowing =
                                                snapshot.data ?? false;
                                            return TextButton(
                                              onPressed:
                                                  () => context
                                                      .read<DatabaseServices>()
                                                      .toggleFollow(
                                                        follower['userId'],
                                                      ),
                                              child: Text(
                                                isFollowing
                                                    ? 'Unfollow'
                                                    : 'Follow',
                                              ),
                                            );
                                          },
                                        )
                                        : null,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showFollowing() {
    if (widget.userId == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.9,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            builder:
                (context, scrollController) => Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Following',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<List<Map<String, dynamic>>>(
                        stream: context
                            .read<DatabaseServices>()
                            .getUserFollowing(widget.userId!),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final following = snapshot.data ?? [];
                          if (following.isEmpty) {
                            return Center(
                              child: Text(
                                'Not following anyone',
                                style: GoogleFonts.poppins(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            controller: scrollController,
                            itemCount: following.length,
                            itemBuilder: (context, index) {
                              final user = following[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(
                                    user['profileImage'] ??
                                        'https://via.placeholder.com/150',
                                  ),
                                ),
                                title: Text(user['name'] ?? 'Unknown User'),
                                trailing:
                                    user['userId'] !=
                                            context
                                                .read<DatabaseServices>()
                                                .auth
                                                .currentUser
                                                ?.uid
                                        ? FutureBuilder<bool>(
                                          future: context
                                              .read<DatabaseServices>()
                                              .isFollowingUser(user['userId']),
                                          builder: (context, snapshot) {
                                            final isFollowing =
                                                snapshot.data ?? false;
                                            return TextButton(
                                              onPressed:
                                                  () => context
                                                      .read<DatabaseServices>()
                                                      .toggleFollow(
                                                        user['userId'],
                                                      ),
                                              child: Text(
                                                isFollowing
                                                    ? 'Unfollow'
                                                    : 'Follow',
                                              ),
                                            );
                                          },
                                        )
                                        : null,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Profile Header
            SliverAppBar(
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: theme.scaffoldBackgroundColor,
              actions: [
                if (widget.userId == null) // Only show settings for own profile
                  IconButton(
                    icon: Icon(
                      Iconsax.setting_2,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        elegantRoute(const SettingsPage()),
                      );
                    },
                  ),
              ],
            ),

            // Profile Content
            SliverToBoxAdapter(
              child: FutureBuilder<Map<String, dynamic>>(
                future: context.read<DatabaseServices>().getUserProfile(
                  userId: widget.userId,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading profile',
                        style: GoogleFonts.poppins(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    );
                  }

                  final userData = snapshot.data ?? {};
                  final name = userData['name'] as String? ?? 'User';
                  final bio = userData['bio'] as String? ?? 'No bio yet';
                  final profileImage = userData['profileImage'] as String?;
                  final followersCount =
                      userData['followersCount'] as int? ?? 0;
                  final followingCount =
                      userData['followingCount'] as int? ?? 0;
                  final postsCount = userData['postsCount'] as int? ?? 0;
                  final isFollowing = userData['isFollowing'] as bool? ?? false;
                  final isOwnProfile = widget.userId == null;

                  return Column(
                    children: [
                      // Profile Image and Stats
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Profile Image
                            Hero(
                              tag: 'profile_image_${widget.userId ?? 'own'}',
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                                child: ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        profileImage ??
                                        'https://via.placeholder.com/150',
                                    fit: BoxFit.cover,
                                    placeholder:
                                        (context, url) => Container(
                                          color: theme.colorScheme.surface,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    theme.colorScheme.primary,
                                                  ),
                                            ),
                                          ),
                                        ),
                                    errorWidget:
                                        (context, url, error) => Container(
                                          color: theme.colorScheme.surface,
                                          child: Icon(
                                            Iconsax.user,
                                            color: theme.colorScheme.primary,
                                            size: 40,
                                          ),
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            // Stats
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    onTap: _showFollowers,
                                    child: _buildStatColumn(
                                      'Posts',
                                      postsCount.toString(),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _showFollowers,
                                    child: _buildStatColumn(
                                      'Followers',
                                      followersCount.toString(),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _showFollowing,
                                    child: _buildStatColumn(
                                      'Following',
                                      followingCount.toString(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bio and Follow Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onBackground,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              bio,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: theme.colorScheme.onBackground
                                    .withOpacity(0.7),
                              ),
                            ),
                            if (!isOwnProfile) ...[
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _toggleFollow,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        isFollowing
                                            ? theme.colorScheme.surface
                                            : theme.colorScheme.primary,
                                    foregroundColor:
                                        isFollowing
                                            ? theme.colorScheme.primary
                                            : Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side:
                                          isFollowing
                                              ? BorderSide(
                                                color:
                                                    theme.colorScheme.primary,
                                              )
                                              : BorderSide.none,
                                    ),
                                  ),
                                  child:
                                      _isLoading
                                          ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                          : Text(
                                            isFollowing ? 'Unfollow' : 'Follow',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
            ),

            // User Posts
            StreamBuilder<List<PostModel>>(
              stream: context.read<DatabaseServices>().getUserPosts(
                userId: widget.userId,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Text(
                        'Error loading posts',
                        style: GoogleFonts.poppins(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  );
                }

                final posts = snapshot.data ?? [];

                if (posts.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Iconsax.image,
                            color: theme.colorScheme.primary,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No posts yet',
                            style: GoogleFonts.poppins(
                              color: theme.colorScheme.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 2,
                          crossAxisSpacing: 2,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final post = posts[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => Scaffold(
                                    appBar: AppBar(
                                      elevation: 0,
                                      backgroundColor:
                                          theme.scaffoldBackgroundColor,
                                      leading: IconButton(
                                        icon: Icon(
                                          Icons.arrow_back_ios_new,
                                          color: theme.colorScheme.onBackground,
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ),
                                    body: PostCard(
                                      userName: post.userName ?? 'Unknown User',
                                      userImageUrl:
                                          post.userProfileImage ??
                                          'https://via.placeholder.com/150',
                                      postImageUrl:
                                          post.postImage ??
                                          'https://via.placeholder.com/150',
                                      description: post.caption ?? '',
                                      isLiked: context
                                          .read<DatabaseServices>()
                                          .hasUserLikedPost(post.likedBy ?? []),
                                      onLike:
                                          () => context
                                              .read<DatabaseServices>()
                                              .toggleLike(post.postId!),
                                      onComment: () {
                                        // Handle comment
                                      },
                                      onSave: () {},
                                      createdAt:
                                          post.createdAt ?? DateTime.now(),
                                      likeCount: post.likeCount ?? 0,
                                      comments: post.comments,
                                      postId: post.postId!,
                                      userEmail: post.userEmail ?? '',
                                      userId: post.userId ?? '',
                                      likedBy: post.likedBy ?? [],
                                    ),
                                  ),
                            ),
                          );
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl:
                                  post.postImage ??
                                  'https://via.placeholder.com/150',
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => Container(
                                    color: theme.colorScheme.surface,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              theme.colorScheme.primary,
                                            ),
                                      ),
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) => Container(
                                    color: theme.colorScheme.surface,
                                    child: Icon(
                                      Iconsax.image,
                                      color: theme.colorScheme.primary,
                                      size: 24,
                                    ),
                                  ),
                            ),
                            if (post.likeCount != null && post.likeCount! > 0)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Row(
                                  children: [
                                    Icon(
                                      Iconsax.heart5,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      post.likeCount.toString(),
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (post.comments != null &&
                                post.comments!.isNotEmpty)
                              Positioned(
                                right: 8,
                                bottom: 8,
                                child: Row(
                                  children: [
                                    Icon(
                                      Iconsax.message5,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      post.comments!.length.toString(),
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    }, childCount: posts.length),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
