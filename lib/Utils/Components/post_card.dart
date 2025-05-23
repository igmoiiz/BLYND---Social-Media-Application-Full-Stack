// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:social_media/Utils/Navigation/app_custom_route.dart';
import 'package:social_media/View/Interface/Feed/post_detail_page.dart';
import 'package:social_media/Model/post_model.dart';
import 'package:social_media/View/Interface/Profile/profile_page.dart';

class PostCard extends StatelessWidget {
  final String userName;
  final String userImageUrl;
  final String postImageUrl;
  final String description;
  final bool isLiked;
  final bool isSaved;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onSave;
  final DateTime createdAt;
  final int likeCount;
  final List<Map<String, dynamic>>? comments;
  final String postId;
  final String userEmail;
  final String userId;
  final List<String> likedBy;

  const PostCard({
    super.key,
    required this.userName,
    required this.userImageUrl,
    required this.postImageUrl,
    required this.description,
    this.isLiked = false,
    this.isSaved = false,
    required this.onLike,
    required this.onComment,
    required this.onSave,
    required this.createdAt,
    this.likeCount = 0,
    this.comments,
    required this.postId,
    required this.userEmail,
    required this.userId,
    required this.likedBy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            children: [
              // Profile Image with tap handler
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    elegantRoute(ProfilePage(userId: userId)),
                  );
                },
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: userImageUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    useOldImageOnUrlChange: true,
                    fadeInDuration: const Duration(milliseconds: 200),
                    placeholder:
                        (context, url) => Container(
                          color: theme.colorScheme.surface,
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.primary,
                              ),
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                    errorWidget:
                        (context, url, error) => Container(
                          color: theme.colorScheme.surface,
                          child: Icon(
                            Iconsax.user,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Username with tap handler
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      elegantRoute(ProfilePage(userId: userId)),
                    );
                  },
                  child: Text(
                    userName,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                ),
              ),
              IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
            ],
          ),
          const SizedBox(height: 10),

          /// Post Image with tap handler for post details
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                elegantRoute(
                  PostDetailPage(
                    post: PostModel(
                      postId: postId,
                      userEmail: userEmail,
                      userId: userId,
                      userName: userName,
                      userProfileImage: userImageUrl,
                      caption: description,
                      postImage: postImageUrl,
                      likeCount: likeCount,
                      likedBy: likedBy,
                      comments: comments,
                      createdAt: createdAt,
                    ),
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CachedNetworkImage(
                imageUrl: postImageUrl,
                width: double.infinity,
                height: size.width,
                fit: BoxFit.cover,
                useOldImageOnUrlChange: true,
                fadeInDuration: const Duration(milliseconds: 300),
                placeholder:
                    (context, url) => Container(
                      width: double.infinity,
                      height: size.width,
                      color: theme.colorScheme.surface,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      width: double.infinity,
                      height: size.width,
                      color: theme.colorScheme.surface,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Iconsax.image,
                              color: theme.colorScheme.primary,
                              size: 40,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Failed to load image',
                              style: GoogleFonts.poppins(
                                color: theme.colorScheme.primary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          /// Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(
                  color: theme.colorScheme.onBackground,
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: "$userName ",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: description),
                ],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Add timestamp display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              _formatTimestamp(createdAt),
              style: GoogleFonts.poppins(
                color: theme.colorScheme.onBackground.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(height: 6),

          /// Like Count
          if (likeCount > 0)
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 4),
              child: Text(
                '$likeCount ${likeCount == 1 ? 'like' : 'likes'}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onBackground,
                ),
              ),
            ),

          /// Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                onPressed: onLike,
                icon: Icon(
                  isLiked ? Iconsax.heart5 : Iconsax.heart,
                  color: isLiked ? Colors.red : theme.iconTheme.color,
                  size: 26,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: onComment,
                icon: Icon(
                  Iconsax.message,
                  size: 24,
                  color: theme.iconTheme.color,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Iconsax.send_2,
                  size: 24,
                  color: theme.iconTheme.color,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onSave,
                icon: Icon(
                  isSaved ? Iconsax.bookmark5 : Iconsax.bookmark,
                  size: 24,
                  color: theme.iconTheme.color,
                ),
              ),
            ],
          ),

          /// Comments Preview
          if (comments != null && comments!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'View all ${comments!.length} comments',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: theme.colorScheme.onBackground.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Show last 2 comments
                  ...comments!
                      .take(2)
                      .map(
                        (comment) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: theme.colorScheme.onBackground,
                              ),
                              children: [
                                TextSpan(
                                  text: '${comment['userName']} ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(text: comment['comment']),
                              ],
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
