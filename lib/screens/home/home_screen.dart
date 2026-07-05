import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../services/theme_service.dart';
import '../tutor/tutor_screen.dart';
import '../books/book_screen.dart';
import '../study_group/study_group_screen.dart';
import '../hostel/hostel_screen.dart';
import '../jobs/job_screen.dart';
import '../notice/notice_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = 'Student';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    setState(() => _userName = doc.data()?['name'] ?? 'Student');
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'CampusGo',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Dark Mode Toggle
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: () => themeService.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('স্বাগতম! 👋',
                            style: GoogleFonts.poppins(
                                color: Colors.white70, fontSize: 13)),
                        Text(
                          _userName,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '🎓 BUBT Student',
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.school,
                      color: Colors.white54, size: 60),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'সেবাসমূহ',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Service Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildServiceCard(
                  context,
                  icon: Icons.person_search,
                  title: 'Tutor খোঁজো',
                  subtitle: 'বিষয়ভিত্তিক tutor',
                  gradient: const [Color(0xFF2563EB), Color(0xFF3B82F6)],
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const TutorScreen())),
                ),
                _buildServiceCard(
                  context,
                  icon: Icons.menu_book,
                  title: 'Books',
                  subtitle: 'কিনো ও বেচো',
                  gradient: const [Color(0xFF16A34A), Color(0xFF22C55E)],
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const BookScreen())),
                ),
                _buildServiceCard(
                  context,
                  icon: Icons.group,
                  title: 'Study Group',
                  subtitle: 'একসাথে পড়ো',
                  gradient: const [Color(0xFFD97706), Color(0xFFF59E0B)],
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const StudyGroupScreen())),
                ),
                _buildServiceCard(
                  context,
                  icon: Icons.home_work,
                  title: 'Hostel/Mess',
                  subtitle: 'থাকার জায়গা',
                  gradient: const [Color(0xFF7C3AED), Color(0xFF9333EA)],
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const HostelScreen())),
                ),
                _buildServiceCard(
                  context,
                  icon: Icons.work_outline,
                  title: 'Part-time Job',
                  subtitle: 'কাজ খোঁজো',
                  gradient: const [Color(0xFFDC2626), Color(0xFFEF4444)],
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const JobScreen())),
                ),
                _buildServiceCard(
                  context,
                  icon: Icons.notifications,
                  title: 'Notice Board',
                  subtitle: 'সব নোটিশ',
                  gradient: const [Color(0xFF0891B2), Color(0xFF06B6D4)],
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const NoticeScreen())),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required List<Color> gradient,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}