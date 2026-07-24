import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/study_group_model.dart';
import '../../services/study_group_service.dart';
import 'chat_screen.dart';

class StudyGroupScreen extends StatefulWidget {
  const StudyGroupScreen({super.key});

  @override
  State<StudyGroupScreen> createState() => _StudyGroupScreenState();
}

class _StudyGroupScreenState extends State<StudyGroupScreen> {
  final StudyGroupService _groupService = StudyGroupService();

  void _showCreateGroupDialog() {
    final nameController = TextEditingController();
    final subjectController = TextEditingController();
    final descController = TextEditingController();
    final locationController = TextEditingController();
    final timeController = TextEditingController();
    int maxMembers = 5;

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
            left: 24, right: 24, top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Study Group বানাও',
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildTextField(nameController, 'Group এর নাম', Icons.group),
                const SizedBox(height: 12),
                _buildTextField(subjectController, 'Subject', Icons.book),
                const SizedBox(height: 12),
                _buildTextField(descController, 'Description', Icons.description),
                const SizedBox(height: 12),
                _buildTextField(locationController, 'কোথায় পড়বে?', Icons.location_on),
                const SizedBox(height: 12),
                _buildTextField(timeController, 'কখন পড়বে?', Icons.access_time),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('সর্বোচ্চ সদস্য: ', style: GoogleFonts.poppins()),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        if (maxMembers > 2) setModalState(() => maxMembers--);
                      },
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text('$maxMembers',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    IconButton(
                      onPressed: () {
                        if (maxMembers < 20) setModalState(() => maxMembers++);
                      },
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD97706),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      if (nameController.text.isEmpty ||
                          subjectController.text.isEmpty) return;
                      final userDoc = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .get();
                      final creatorName = userDoc.data()?['name'] ?? 'Unknown';
                      final group = StudyGroupModel(
                        id: '',
                        name: nameController.text,
                        subject: subjectController.text,
                        description: descController.text,
                        location: locationController.text,
                        time: timeController.text,
                        maxMembers: maxMembers,
                        members: [FirebaseAuth.instance.currentUser!.uid],
                        creatorId: FirebaseAuth.instance.currentUser!.uid,
                        creatorName: creatorName,
                      );
                      await _groupService.createGroup(group);
                      if (mounted) Navigator.pop(context);
                    },
                    child: Text('Create Group',
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontWeight: FontWeight.w600)),
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

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD97706),
        title: Text('Study Group',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateGroupDialog,
        backgroundColor: const Color(0xFFD97706),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Group Create',
            style: GoogleFonts.poppins(color: Colors.white)),
      ),
      body: StreamBuilder<List<StudyGroupModel>>(
        stream: _groupService.getGroups(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.group, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('No Group',
                      style: GoogleFonts.poppins(color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final group = snapshot.data![index];
              final isMember = group.members.contains(currentUid);
              final isFull = group.members.length >= group.maxMembers;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD97706).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.group,
                              color: Color(0xFFD97706)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(group.name,
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold)),
                              Text(group.subject,
                                  style: GoogleFonts.poppins(
                                      color: const Color(0xFFD97706),
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isFull
                                ? Colors.red.withOpacity(0.1)
                                : const Color(0xFF16A34A).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${group.members.length}/${group.maxMembers}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isFull
                                  ? Colors.red
                                  : const Color(0xFF16A34A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (group.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(group.description,
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.grey)),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(group.location,
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.grey)),
                        const SizedBox(width: 12),
                        const Icon(Icons.access_time,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(group.time,
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text('Creator: ${group.creatorName}',
                            style: GoogleFonts.poppins(
                                fontSize: 11, color: Colors.grey)),
                        const Spacer(),

                        // ✅ Chat Button — শুধু members দেখতে পাবে
                        if (isMember) ...[
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(group: group),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD97706).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.chat_bubble_outline,
                                      color: Color(0xFFD97706), size: 16),
                                  const SizedBox(width: 4),
                                  Text('Chat',
                                      style: GoogleFonts.poppins(
                                          color: const Color(0xFFD97706),
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],

                        // Join/Leave Button
                        if (group.creatorId != currentUid)
                          ElevatedButton(
                            onPressed: isFull && !isMember
                                ? null
                                : () async {
                              if (isMember) {
                                await _groupService.leaveGroup(group.id);
                              } else {
                                await _groupService.joinGroup(group.id);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              isMember ? Colors.red : const Color(0xFFD97706),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                            ),
                            child: Text(
                              isMember ? 'Leave' : 'Join',
                              style: GoogleFonts.poppins(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ),

                        if (group.creatorId == currentUid)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD97706).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('Your Group',
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: const Color(0xFFD97706))),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}