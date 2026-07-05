import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/notice_model.dart';
import '../../services/notice_service.dart';

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  final NoticeService _noticeService = NoticeService();
  String _selectedFilter = 'সব';

  final List<String> _categories = [
    'সব',
    'পরীক্ষা',
    'ক্লাস',
    'ইভেন্ট',
    'অন্যান্য',
  ];

  Color _categoryColor(String category) {
    switch (category) {
      case 'পরীক্ষা':
        return const Color(0xFFDC2626);
      case 'ক্লাস':
        return const Color(0xFF2563EB);
      case 'ইভেন্ট':
        return const Color(0xFF16A34A);
      default:
        return const Color(0xFF0891B2);
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'পরীক্ষা':
        return Icons.assignment;
      case 'ক্লাস':
        return Icons.class_;
      case 'ইভেন্ট':
        return Icons.event;
      default:
        return Icons.notifications;
    }
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 0) return '${diff.inDays} দিন আগে';
    if (diff.inHours > 0) return '${diff.inHours} ঘণ্টা আগে';
    if (diff.inMinutes > 0) return '${diff.inMinutes} মিনিট আগে';
    return 'এখনই';
  }

  void _showAddNoticeDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedCategory = 'অন্যান্য';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notice দাও',
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Notice এর বিষয়',
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'বিস্তারিত লেখো',
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    prefixIcon: const Icon(Icons.category),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  items: ['পরীক্ষা', 'ক্লাস', 'ইভেন্ট', 'অন্যান্য']
                      .map((c) =>
                      DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) =>
                      setModalState(() => selectedCategory = val!),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0891B2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      if (titleController.text.isEmpty ||
                          descController.text.isEmpty) return;

                      final userDoc = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .get();
                      final posterName =
                          userDoc.data()?['name'] ?? 'Unknown';

                      final notice = NoticeModel(
                        id: '',
                        title: titleController.text,
                        description: descController.text,
                        category: selectedCategory,
                        userId: FirebaseAuth.instance.currentUser!.uid,
                        posterName: posterName,
                        createdAt: DateTime.now(),
                      );
                      await _noticeService.addNotice(notice);
                      if (mounted) Navigator.pop(context);
                    },
                    child: Text(
                      'Post করো',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0891B2),
        title: Text(
          'Notice Board',
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddNoticeDialog,
        backgroundColor: const Color(0xFF0891B2),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Notice দাও',
            style: GoogleFonts.poppins(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Filter Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedFilter = filter),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF0891B2)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFF0891B2)),
                        ),
                        child: Text(
                          filter,
                          style: GoogleFonts.poppins(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF0891B2),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Notice List
          Expanded(
            child: StreamBuilder<List<NoticeModel>>(
              stream: _selectedFilter == 'সব'
                  ? _noticeService.getNotices()
                  : _noticeService.getNoticesByCategory(_selectedFilter),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.notifications_off,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text('কোনো notice নেই',
                            style:
                            GoogleFonts.poppins(color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text('প্রথম notice দাও!',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final notice = snapshot.data![index];
                    final isOwner = notice.userId == currentUid;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _categoryColor(notice.category)
                                      .withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _categoryIcon(notice.category),
                                  color:
                                  _categoryColor(notice.category),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(notice.title,
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                      _timeAgo(notice.createdAt),
                                      style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _categoryColor(
                                          notice.category)
                                          .withOpacity(0.1),
                                      borderRadius:
                                      BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      notice.category,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: _categoryColor(
                                            notice.category),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (isOwner) ...[
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () async {
                                        await _noticeService
                                            .deleteNotice(notice.id);
                                      },
                                      child: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                          size: 20),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            notice.description,
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Posted by: ${notice.posterName}',
                            style: GoogleFonts.poppins(
                                fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}