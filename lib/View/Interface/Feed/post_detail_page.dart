// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:social_media/Controller/Services/Database/database_services.dart';
import 'package:social_media/Model/post_model.dart';
import 'package:social_media/Utils/Components/comment_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PostDetailPage extends StatelessWidget {
  final PostModel post;

  const PostDetailPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: theme.colorScheme.onBackground,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Post",
          style: GoogleFonts.poppins(
            color: theme.colorScheme.onBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipOval(
                    child: CachedNetworkImage(
                      imageUrl:
                          post.userProfileImage ??
                          'https://via.placeholder.com/150',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.userName ?? 'Unknown User',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onBackground,
                          ),
                        ),
                        Text(
                          _formatTimestamp(post.createdAt ?? DateTime.now()),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: theme.colorScheme.onBackground.withOpacity(
                              0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Post Image
            CachedNetworkImage(
              imageUrl: post.postImage ?? 'https://via.placeholder.com/150',
              width: double.infinity,
              height: size.width,
              fit: BoxFit.cover,
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

            // Actions and Caption
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Action Buttons
                  Row(
                    children: [
                      Consumer<DatabaseServices>(
                        builder: (context, databaseProvider, child) {
                          return IconButton(
                            onPressed:
                                () => databaseProvider.toggleLike(post.postId!),
                            icon: Icon(
                              databaseProvider.hasUserLikedPost(post.likedBy)
                                  ? Iconsax.heart5
                                  : Iconsax.heart,
                              color:
                                  databaseProvider.hasUserLikedPost(
                                        post.likedBy,
                                      )
                                      ? Colors.red
                                      : theme.iconTheme.color,
                              size: 26,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: () {
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
                        onPressed: () {},
                        icon: Icon(
                          Iconsax.bookmark,
                          size: 24,
                          color: theme.iconTheme.color,
                        ),
                      ),
                    ],
                  ),

                  // Like Count
                  if (post.likeCount != null && post.likeCount! > 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 8),
                      child: Text(
                        '${post.likeCount} ${post.likeCount == 1 ? 'like' : 'likes'}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onBackground,
                        ),
                      ),
                    ),

                  // Caption
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        color: theme.colorScheme.onBackground,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: "${post.userName} ",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: post.caption ?? ''),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Comments Section
                  if (post.comments != null && post.comments!.isNotEmpty) ...[
                    Text(
                      'Comments',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...post.comments!.map(
                      (comment) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipOval(
                              child: CachedNetworkImage(
                                imageUrl:
                                    comment['userProfileImage'] ??
                                    'https://via.placeholder.com/150',
                                width: 32,
                                height: 32,
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
                                        size: 16,
                                      ),
                                    ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
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
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatTimestamp(
                                      DateTime.parse(comment['createdAt']),
                                    ),
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: theme.colorScheme.onBackground
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  hintStyle: GoogleFonts.poppins(
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                onSubmitted: (comment) {
                  if (comment.trim().isNotEmpty) {
                    context.read<DatabaseServices>().addComment(
                      post.postId!,
                      comment.trim(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
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
