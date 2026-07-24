import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart'; // path na mille bolo, thik kore dibo
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../services/post_service.dart'; // path na mille bolo, thik kore dibo

enum PostType { general, job, notice }

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _postService = PostService();

  PostType _selectedType = PostType.general;
  bool _notifyMembers = true;
  bool _allowComments = true;
  DateTime? _scheduledAt;
  bool _isPosting = false;
  File? _pickedImage;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked =
    await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<void> _pickScheduleDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;
    setState(() {
      _scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _submitPost() async {
    if (_bodyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('কিছু লিখো post করার জন্য'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.red.shade400,
        ),
      );
      return;
    }

    setState(() => _isPosting = true);
    try {
      await _postService.createPost(
        caption: _bodyController.text.trim(),
        type: _selectedType.name,
        imageFile: _pickedImage,
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Post করতে সমস্যা হয়েছে: $e'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.red.shade400,
        ),
      );
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7FB),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
              ],
            ),
            child: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A), size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Post',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.info_outline, color: Colors.white, size: 18),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: Text('Posting Tips',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    content: Text(
                      'General post সবার feed এ দেখাবে। Job select করলে Job board এ, '
                          'Notice select করলে Notice board এ post টা যাবে।',
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('বুঝেছি'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Post type selector (General / Job / Notice) ----
              Text(
                'Post as',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _typeChip(
                      type: PostType.general,
                      icon: Icons.grid_view_rounded,
                      label: 'General',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _typeChip(
                      type: PostType.job,
                      icon: Icons.work_outline,
                      label: 'Job',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _typeChip(
                      type: PostType.notice,
                      icon: Icons.campaign_outlined,
                      label: 'Notice',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // ---- Title field ----
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: TextField(
                  controller: _titleController,
                  maxLength: 100,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Post Title (Optional)',
                    hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade400),
                    border: InputBorder.none,
                    counterStyle: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade400),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(height: 14),

              // ---- Body editor ----
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          _toolbarIcon(Icons.format_bold),
                          _toolbarIcon(Icons.format_italic),
                          _toolbarIcon(Icons.format_underline),
                          const SizedBox(width: 4),
                          _toolbarIcon(Icons.format_list_bulleted),
                          _toolbarIcon(Icons.format_list_numbered),
                          const SizedBox(width: 4),
                          _toolbarIcon(Icons.link),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey.shade100),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: TextField(
                        controller: _bodyController,
                        maxLength: 2000,
                        maxLines: 8,
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Write something...',
                          hintStyle:
                          GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade400),
                          border: InputBorder.none,
                          counterStyle:
                          GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade400),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ---- Image picker / preview ----
              if (_pickedImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      Image.file(
                        _pickedImage!,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () => setState(() => _pickedImage = null),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image_outlined, color: AppTheme.primary),
                  label: Text('Add Photo',
                      style: GoogleFonts.poppins(color: AppTheme.primary)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    minimumSize: const Size(double.infinity, 46),
                  ),
                ),
              const SizedBox(height: 16),

              // ---- Options list ----
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
                  ],
                ),
                child: Column(
                  children: [
                    _optionTile(
                      icon: Icons.notifications_none,
                      title: 'Notify Members',
                      subtitle: 'Send notification to all members',
                      trailing: Switch(
                        value: _notifyMembers,
                        activeColor: AppTheme.primary,
                        onChanged: (v) => setState(() => _notifyMembers = v),
                      ),
                    ),
                    Divider(height: 1, indent: 60, color: Colors.grey.shade100),
                    _optionTile(
                      icon: Icons.calendar_today_outlined,
                      title: 'Schedule Post',
                      subtitle: _scheduledAt == null
                          ? 'Choose date and time'
                          : '${_scheduledAt!.day}/${_scheduledAt!.month}/${_scheduledAt!.year} · ${TimeOfDay.fromDateTime(_scheduledAt!).format(context)}',
                      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
                      onTap: _pickScheduleDate,
                    ),
                    Divider(height: 1, indent: 60, color: Colors.grey.shade100),
                    _optionTile(
                      icon: Icons.lock_outline,
                      title: 'Allow Comments',
                      subtitle: 'Members can comment on this post',
                      trailing: Switch(
                        value: _allowComments,
                        activeColor: AppTheme.primary,
                        onChanged: (v) => setState(() => _allowComments = v),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              Center(
                child: Text(
                  'Be respectful and share helpful content',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
                ),
              ),
              const SizedBox(height: 18),

              // ---- Post button ----
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _isPosting ? null : _submitPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: _isPosting
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.2,
                    ),
                  )
                      : const Icon(Icons.send, size: 18),
                  label: Text(
                    _isPosting ? 'Posting...' : 'Post',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeChip({
    required PostType type,
    required IconData icon,
    required String label,
  }) {
    final selected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppTheme.primary : Colors.grey.shade200,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: selected ? Colors.white : Colors.grey.shade600),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolbarIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Container(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 18, color: const Color(0xFF1E293B)),
      ),
    );
  }

  Widget _optionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(fontSize: 11.5, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}