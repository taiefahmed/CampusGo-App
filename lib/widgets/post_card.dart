import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/feed_post.dart';
import '../services/post_service.dart';
import '../theme/app_theme.dart'; // path na mille bolo, thik kore dibo

class PostCard extends StatelessWidget {
  final FeedPost post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final isLiked = uid != null && post.likedBy.contains(uid);
    final isSaved = uid != null && post.savedBy.contains(uid);
    final postService = PostService();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.primary.withOpacity(0.1),
                  backgroundImage: post.authorPhotoUrl != null
                      ? NetworkImage(post.authorPhotoUrl!)
                      : null,
                  child: post.authorPhotoUrl == null
                      ? const Icon(Icons.person, color: AppTheme.primary, size: 20)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.authorName,
                          style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A1A))),
                      Text(post.authorHandle,
                          style: GoogleFonts.poppins(fontSize: 11.5, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                Icon(Icons.more_horiz, color: Colors.grey.shade400),
              ],
            ),
          ),

          if (post.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(post.caption,
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade800)),
            ),
          const SizedBox(height: 10),

          // Image + bottom overlay action bar (like the reference image)
          if (post.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1.4,
                    child: Image.network(post.imageUrl!, fit: BoxFit.cover),
                  ),
                  Positioned(
                    left: 10,
                    right: 10,
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.mode_comment_outlined, color: Colors.white, size: 18),
                          const SizedBox(width: 4),
                          Text('${post.commentCount}',
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () => postService.toggleLike(post.id, isLiked),
                            child: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked ? AppTheme.primary : Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text('${post.likedBy.length}',
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
                          const Spacer(),
                          const Icon(Icons.send_outlined, color: Colors.white, size: 18),
                          const SizedBox(width: 14),
                          GestureDetector(
                            onTap: () => postService.toggleSave(post.id, isSaved),
                            child: Icon(
                              isSaved ? Icons.bookmark : Icons.bookmark_border,
                              color: isSaved ? AppTheme.primary : Colors.white,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
          // Text-only post: actions row without image
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: () => postService.toggleLike(post.id, isLiked),
                    icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 18, color: isLiked ? AppTheme.primary : Colors.grey.shade500),
                    label: Text('${post.likedBy.length}',
                        style: GoogleFonts.poppins(fontSize: 12.5, color: Colors.grey.shade600)),
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.mode_comment_outlined, size: 17, color: Colors.grey.shade500),
                    label: Text('${post.commentCount}',
                        style: GoogleFonts.poppins(fontSize: 12.5, color: Colors.grey.shade600)),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => postService.toggleSave(post.id, isSaved),
                    child: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border,
                        size: 18, color: isSaved ? AppTheme.primary : Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}