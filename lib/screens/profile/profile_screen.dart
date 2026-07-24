import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/theme_service.dart';
import '../auth/login_screen.dart'; // <-- আপনার Login Screen এর সঠিক পাথ দিন

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    setState(() {
      _userData = doc.data();
      _isLoading = false;
    });
  }

  // ✅ প্রোফাইল পিকচার আপলোড ফাংশন
  Future<void> _pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 800,
      );

      if (pickedFile == null) return;

      setState(() => _isUploadingImage = true);

      final uid = FirebaseAuth.instance.currentUser!.uid;
      final file = File(pickedFile.path);

      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('$uid.jpg');

      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'photoUrl': downloadUrl});

      setState(() {
        _userData?['photoUrl'] = downloadUrl;
        _isUploadingImage = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated ✅')),
        );
      }
    } catch (e) {
      setState(() => _isUploadingImage = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image upload failed: $e')),
        );
      }
    }
  }

  // ✅ নাম এডিট করার ডায়ালগ
  Future<void> _editNameDialog() async {
    final controller =
    TextEditingController(text: _userData?['name'] ?? '');

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text('Change name',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter your name',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
            ),
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'name': result});

      setState(() {
        _userData?['name'] = result;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Name successfully updated ✅')),
        );
      }
    }
  }

  // ✅ লগআউট করলে সরাসরি লগইন পেজে যাবে
  Future<void> _handleLogout(AuthService auth) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text('Logout', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await auth.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final themeService = Provider.of<ThemeService>(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // ✅ Profile Avatar with image + edit button
            Stack(
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withOpacity(0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    image: _userData?['photoUrl'] != null
                        ? DecorationImage(
                      image: NetworkImage(_userData!['photoUrl']),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: _isUploadingImage
                      ? const Center(
                    child: CircularProgressIndicator(
                        color: Colors.white),
                  )
                      : (_userData?['photoUrl'] == null
                      ? Center(
                    child: Text(
                      _userData?['name'] != null &&
                          _userData!['name']
                              .toString()
                              .isNotEmpty
                          ? _userData!['name'][0]
                          .toUpperCase()
                          : 'U',
                      style: GoogleFonts.poppins(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                      : null),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _isUploadingImage ? null : _pickAndUploadImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt,
                          size: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ✅ নাম + এডিট আইকন
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _userData?['name'] ?? 'Student',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: _editNameDialog,
                  child: Icon(Icons.edit,
                      size: 18, color: Colors.grey.shade600),
                ),
              ],
            ),
            Text(
              user?.email ?? '',
              style: GoogleFonts.poppins(
                  fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            // User Type Badge
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: _userData?['userType'] == 'guardian'
                    ? const Color(0xFF9333EA).withOpacity(0.1)
                    : const Color(0xFF2563EB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _userData?['userType'] == 'guardian'
                    ? '👤 Guardian'
                    : '🎓 Student',
                style: GoogleFonts.poppins(
                  color: _userData?['userType'] == 'guardian'
                      ? const Color(0xFF9333EA)
                      : const Color(0xFF2563EB),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Info Cards
            _buildInfoCard(
              context,
              icon: Icons.badge_outlined,
              title: 'Student ID',
              value: _userData?['studentId'] ?? 'N/A',
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              context,
              icon: Icons.account_balance_outlined,
              title: 'University',
              value: _userData?['university'] ?? 'BUBT',
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              context,
              icon: Icons.email_outlined,
              title: 'Email',
              value: user?.email ?? 'N/A',
            ),
            const SizedBox(height: 12),

            // ✅ Dark Mode Toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color ??
                    Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color:
                      const Color(0xFF2563EB).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      themeService.isDarkMode
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Dark Mode',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Switch(
                    value: themeService.isDarkMode,
                    onChanged: (_) => themeService.toggleTheme(),
                    activeColor: const Color(0xFF2563EB),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ✅ Logout Button - সরাসরি Login Page এ যাবে
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => _handleLogout(auth),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: Text(
                  'Logout',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String value,
      }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF2563EB)),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.grey)),
              Text(value,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}