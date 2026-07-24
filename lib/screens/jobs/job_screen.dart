import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/job_model.dart';
import '../../services/job_service.dart';

class JobScreen extends StatefulWidget {
  const JobScreen({super.key});

  @override
  State<JobScreen> createState() => _JobScreenState();
}

class _JobScreenState extends State<JobScreen> {
  final JobService _jobService = JobService();
  String _selectedFilter = 'All';

  void _showAddJobDialog() {
    final titleController = TextEditingController();
    final companyController = TextEditingController();
    final locationController = TextEditingController();
    final salaryController = TextEditingController();
    final descController = TextEditingController();
    final phoneController = TextEditingController();
    String selectedType = 'Part-time';

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
                  'Job Post',
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                    titleController, 'Job Title', Icons.work),
                const SizedBox(height: 12),
                _buildTextField(
                    companyController, 'Company/Shop Name', Icons.business),
                const SizedBox(height: 12),
                _buildTextField(
                    locationController, 'Location', Icons.location_on),
                const SizedBox(height: 12),
                _buildTextField(
                    salaryController, 'Salary (money/month)', Icons.attach_money,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                _buildTextField(
                    descController, 'Job Description', Icons.description),
                const SizedBox(height: 12),
                _buildTextField(
                    phoneController, 'Phone Number', Icons.phone,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(
                    labelText: 'Job Type',
                    prefixIcon: const Icon(Icons.category),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  items: ['Part-time', 'Freelance', 'Internship']
                      .map((t) =>
                      DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (val) =>
                      setModalState(() => selectedType = val!),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      if (titleController.text.isEmpty ||
                          companyController.text.isEmpty) return;

                      final userDoc = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .get();
                      final posterName =
                          userDoc.data()?['name'] ?? 'Unknown';

                      final job = JobModel(
                        id: '',
                        title: titleController.text,
                        company: companyController.text,
                        location: locationController.text,
                        salary: salaryController.text,
                        type: selectedType,
                        description: descController.text,
                        phone: phoneController.text,
                        userId: FirebaseAuth.instance.currentUser!.uid,
                        posterName: posterName,
                      );
                      await _jobService.addJob(job);
                      if (mounted) Navigator.pop(context);
                    },
                    child: Text(
                      'Post ',
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

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border:
        OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'Part-time':
        return const Color(0xFFDC2626);
      case 'Freelance':
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFF16A34A);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDC2626),
        title: Text(
          'Part-time Jobs',
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddJobDialog,
        backgroundColor: const Color(0xFFDC2626),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Job Post',
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
                children:
                ['All', 'Part-time', 'Freelance', 'Internship']
                    .map((filter) {
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
                              ? const Color(0xFFDC2626)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFFDC2626)),
                        ),
                        child: Text(
                          filter,
                          style: GoogleFonts.poppins(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFFDC2626),
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
          // Job List
          Expanded(
            child: StreamBuilder<List<JobModel>>(
              stream: _selectedFilter == 'All'
                  ? _jobService.getJobs()
                  : _jobService.getJobsByType(_selectedFilter),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.work_off,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text('No Job',
                            style:
                            GoogleFonts.poppins(color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text('Post the first job!',
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
                    final job = snapshot.data![index];
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
                                  color: _typeColor(job.type)
                                      .withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.work,
                                    color: _typeColor(job.type)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(job.title,
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold)),
                                    Text(job.company,
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color:
                                            _typeColor(job.type))),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _typeColor(job.type)
                                      .withOpacity(0.1),
                                  borderRadius:
                                  BorderRadius.circular(20),
                                ),
                                child: Text(
                                  job.type,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: _typeColor(job.type),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (job.description.isNotEmpty)
                            Text(job.description,
                                style: GoogleFonts.poppins(
                                    fontSize: 12, color: Colors.grey),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(job.location,
                                  style: GoogleFonts.poppins(
                                      fontSize: 12, color: Colors.grey)),
                              const Spacer(),
                              const Icon(Icons.attach_money,
                                  size: 14,
                                  color: Color(0xFF16A34A)),
                              Text(
                                '৳${job.salary}/Month',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFF16A34A),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text('Posted by: ${job.posterName}',
                                  style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.grey)),
                              const Spacer(),
                              GestureDetector(
                                child: Container(
                                  child: Text('Apply',
                                      style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 12)),
                                ),
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
          ),
        ],
      ),
    );
  }
}