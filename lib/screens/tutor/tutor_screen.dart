import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/tutor_model.dart';
import '../../services/tutor_service.dart';
import '../../utils/call_helper.dart';

class TutorScreen extends StatefulWidget {
  const TutorScreen({super.key});

  @override
  State<TutorScreen> createState() => _TutorScreenState();
}

class _TutorScreenState extends State<TutorScreen> {
  final TutorService _tutorService = TutorService();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  void _showAddTutorDialog() {
    final nameController = TextEditingController();
    final subjectController = TextEditingController();
    final locationController = TextEditingController();
    final rateController = TextEditingController();
    final phoneController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24, right: 24, top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tutor হিসেবে যোগ দাও',
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildTextField(nameController, 'তোমার নাম', Icons.person),
            const SizedBox(height: 12),
            _buildTextField(subjectController, 'Subject', Icons.book),
            const SizedBox(height: 12),
            _buildTextField(locationController, 'Location', Icons.location_on),
            const SizedBox(height: 12),
            _buildTextField(rateController, 'ঘণ্টায় কত টাকা?',
                Icons.attach_money,
                keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _buildTextField(
                phoneController, 'Phone Number', Icons.phone,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  if (nameController.text.isEmpty ||
                      subjectController.text.isEmpty) return;
                  final tutor = TutorModel(
                    id: '',
                    name: nameController.text,
                    subject: subjectController.text,
                    location: locationController.text,
                    hourlyRate: double.tryParse(rateController.text) ?? 0,
                    rating: 0,
                    phone: phoneController.text,
                    userId: FirebaseAuth.instance.currentUser!.uid,
                  );
                  await _tutorService.addTutor(tutor);
                  if (mounted) Navigator.pop(context);
                },
                child: Text('Submit',
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
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
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        title: Text('Tutor খোঁজো',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTutorDialog,
        backgroundColor: const Color(0xFF2563EB),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Tutor হও',
            style: GoogleFonts.poppins(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Subject দিয়ে খোঁজো...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          // Tutor List
          Expanded(
            child: StreamBuilder<List<TutorModel>>(
              stream: _searchQuery.isEmpty
                  ? _tutorService.getTutors()
                  : _tutorService.searchTutors(_searchQuery),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_search,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text('কোনো tutor পাওয়া যায়নি',
                            style: GoogleFonts.poppins(color: Colors.grey)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final tutor = snapshot.data![index];
                    return _TutorCard(tutor: tutor);
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

class _TutorCard extends StatelessWidget {
  final TutorModel tutor;
  const _TutorCard({required this.tutor});

  @override
  Widget build(BuildContext context) {
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
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
            child: Text(
              tutor.name.isNotEmpty ? tutor.name[0].toUpperCase() : 'T',
              style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2563EB)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tutor.name,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                Text(tutor.subject,
                    style: GoogleFonts.poppins(
                        color: const Color(0xFF2563EB), fontSize: 13)),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 14, color: Colors.grey),
                    Text(tutor.location,
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('৳${tutor.hourlyRate.toInt()}/hr',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF16A34A))),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => CallHelper.makeCall(context, tutor.phone),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Contact',
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}