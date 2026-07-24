import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/feed_post.dart';
import '../../services/post_service.dart';
import '../../widgets/post_card.dart';
import '../../theme/app_theme.dart'; // path na mille bolo, thik kore dibo

class SavedPostsScreen extends StatelessWidget {
  const SavedPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7FB),
        elevation: 0,
        title: Text(
          'Saved Posts',
          style: GoogleFonts.poppins(
            color: const Color(0xFF1A1A1A),
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
      ),
      body: StreamBuilder<List<FeedPost>>(
        stream: PostService().savedPostsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          final savedPosts = snapshot.data ?? [];

          if (savedPosts.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bookmark_border, size: 60, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text(
                    'কোনো post save করা নেই',
                    style: GoogleFonts.poppins(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 20),
            itemCount: savedPosts.length,
            itemBuilder: (context, index) => PostCard(post: savedPosts[index]),
          );
        },
      ),
    );
  }
}