import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../services/theme_service.dart';
import '../../services/post_service.dart';
import '../../models/feed_post.dart';
import '../../theme/app_theme.dart'; // path na mille bolo, thik kore dibo
import '../tutor/tutor_screen.dart';
import '../books/book_screen.dart';
import '../study_group/study_group_screen.dart';
import '../hostel/hostel_screen.dart';
import '../jobs/job_screen.dart';
import '../notice/notice_screen.dart';
import '../profile/profile_screen.dart';
import '../post/create_post_screen.dart';
import '../saved/saved_posts_screen.dart';
import '../../widgets/post_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = 'Student';
  String _userDept = '';
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc =
    await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!mounted) return;
    setState(() {
      _userName = doc.data()?['name'] ?? 'Student';
      _userDept = doc.data()?['department'] ?? '';
      _photoUrl = doc.data()?['photoUrl'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Column(
          children: [
            // ---- Fixed top section ----
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppTheme.primary.withOpacity(0.1),
                        backgroundImage:
                        _photoUrl != null ? NetworkImage(_photoUrl!) : null,
                        child: _photoUrl == null
                            ? const Icon(Icons.person, color: AppTheme.primary)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_userName,
                                style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1A1A1A))),
                            Text('Dept of $_userDept',
                                style: GoogleFonts.poppins(
                                    fontSize: 12, color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_none,
                            color: Color(0xFF1A1A1A)),
                        onPressed: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const NoticeScreen())),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      style: GoogleFonts.poppins(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search class, subject',
                        hintStyle: GoogleFonts.poppins(
                            fontSize: 14, color: Colors.grey.shade400),
                        prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Quick access circles
                  SizedBox(
                    height: 84,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _quickAccess(Icons.person_search, 'Tuition',
                                () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const TutorScreen()))),
                        _quickAccess(Icons.menu_book, 'Books',
                                () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const BookScreen()))),
                        _quickAccess(Icons.group, 'Study group',
                                () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const StudyGroupScreen()))),
                        _quickAccess(Icons.home_work, 'Hostel',
                                () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const HostelScreen()))),
                        _quickAccess(Icons.work_outline, 'Job',
                                () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const JobScreen()))),
                        _quickAccess(Icons.error_outline, 'Notice',
                                () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const NoticeScreen()))),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ---- Scrollable feed (real Firestore data) ----
            Expanded(
              child: StreamBuilder<List<FeedPost>>(
                stream: PostService().postsStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Post লোড করতে সমস্যা হয়েছে:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(color: Colors.red, fontSize: 12),
                      ),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    );
                  }
                  final posts = snapshot.data ?? [];
                  if (posts.isEmpty) {
                    return Center(
                      child: Text(
                        'এখনো কোনো post নেই।\nউপরের + button দিয়ে প্রথম post করো!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(color: Colors.grey.shade500),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 90, top: 4),
                    itemCount: posts.length,
                    itemBuilder: (context, index) => PostCard(post: posts[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        elevation: 2,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatePostScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Bottom nav bar
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.home, color: AppTheme.primary),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.chat_bubble_outline, color: Colors.grey.shade400),
                onPressed: () {
                  // TODO: message screen navigate korano
                },
              ),
              const SizedBox(width: 40), // FAB এর জন্য জায়গা
              IconButton(
                icon: Icon(Icons.bookmark_border, color: Colors.grey.shade400),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SavedPostsScreen()),
                ),
              ),
              IconButton(
                icon: Icon(Icons.person_outline, color: Colors.grey.shade400),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen())),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickAccess(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}