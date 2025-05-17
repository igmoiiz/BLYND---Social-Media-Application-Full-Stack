import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(userImageUrl),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  userName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
              ),
              IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
            ],
          ),
          const SizedBox(height: 10),

          /// Post Image
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              postImageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
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

          const SizedBox(height: 6),

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
        ],
      ),
    );
  }
}
