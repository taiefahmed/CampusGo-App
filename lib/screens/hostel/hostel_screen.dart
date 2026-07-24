import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/hostel_model.dart';
import '../../services/hostel_service.dart';
class HostelScreen extends StatefulWidget {
  const HostelScreen({super.key});

  @override
  State<HostelScreen> createState() => _HostelScreenState();
}

class _HostelScreenState extends State<HostelScreen> {
  final HostelService _hostelService = HostelService();
  String _selectedFilter = 'All';

  void _showAddHostelDialog() {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final rentController = TextEditingController();
    final facilitiesController = TextEditingController();
    final phoneController = TextEditingController();
    String selectedType = 'Hostel';
    String selectedGender = 'Any';

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
                  'Hostel/Mess Add',
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                    nameController, 'Hostel/Mess Name', Icons.home),
                const SizedBox(height: 12),
                _buildTextField(
                    locationController, 'Address', Icons.location_on),
                const SizedBox(height: 12),
                _buildTextField(
                  rentController,
                  'মMonthly Cost (Taka)',
                  Icons.attach_money,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _buildTextField(facilitiesController,
                    'Facilities(Wi-Fi, AC, food...)', Icons.list),
                const SizedBox(height: 12),
                _buildTextField(
                  phoneController,
                  'Phone Number',
                  Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                // Type Dropdown
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(
                    labelText: 'Type',
                    prefixIcon: const Icon(Icons.home_work),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  items: ['Hostel', 'Mess']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (val) =>
                      setModalState(() => selectedType = val!),
                ),
                const SizedBox(height: 12),
                // Gender Dropdown
                DropdownButtonFormField<String>(
                  value: selectedGender,
                  decoration: InputDecoration(
                    labelText: 'কার জন্য?',
                    prefixIcon: const Icon(Icons.people),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  items: ['Any', 'Boy', 'Girl']
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (val) =>
                      setModalState(() => selectedGender = val!),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9333EA),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      if (nameController.text.isEmpty ||
                          locationController.text.isEmpty) return;

                      final userDoc = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .get();
                      final ownerName =
                          userDoc.data()?['name'] ?? 'Unknown';

                      final hostel = HostelModel(
                        id: '',
                        name: nameController.text,
                        type: selectedType,
                        location: locationController.text,
                        rent: double.tryParse(rentController.text) ?? 0,
                        facilities: facilitiesController.text,
                        phone: phoneController.text,
                        userId: FirebaseAuth.instance.currentUser!.uid,
                        ownerName: ownerName,
                        gender: selectedGender,
                      );
                      await _hostelService.addHostel(hostel);
                      if (mounted) Navigator.pop(context);
                    },
                    child: Text(
                      'Post Now',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF9333EA),
        title: Text(
          'Hostel/Mess Finder',
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddHostelDialog,
        backgroundColor: const Color(0xFF9333EA),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add',
            style: GoogleFonts.poppins(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Filter Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: ['All', 'Hostel', 'Mess'].map((filter) {
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
                            ? const Color(0xFF9333EA)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF9333EA),
                        ),
                      ),
                      child: Text(
                        filter,
                        style: GoogleFonts.poppins(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF9333EA),
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
          // Hostel List
          Expanded(
            child: StreamBuilder<List<HostelModel>>(
              stream: _selectedFilter == 'All'
                  ? _hostelService.getHostels()
                  : _hostelService.getHostelsByType(_selectedFilter),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.home_work,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text('There is no mess.',
                            style:
                            GoogleFonts.poppins(color: Colors.grey)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final hostel = snapshot.data![index];
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
                                  color: const Color(0xFF9333EA)
                                      .withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.home_work,
                                    color: Color(0xFF9333EA)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(hostel.name,
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold)),
                                    Row(
                                      children: [
                                        Container(
                                          padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF9333EA)
                                                .withOpacity(0.1),
                                            borderRadius:
                                            BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            hostel.type,
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              color:
                                              const Color(0xFF9333EA),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.blue
                                                .withOpacity(0.1),
                                            borderRadius:
                                            BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            hostel.gender,
                                            style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                color: Colors.blue),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '৳${hostel.rent.toInt()}/Month',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF9333EA),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(hostel.location,
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey)),
                              ),
                            ],
                          ),
                          if (hostel.facilities.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(hostel.facilities,
                                      style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey)),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text('Owner: ${hostel.ownerName}',
                                  style: GoogleFonts.poppins(
                                      fontSize: 11, color: Colors.grey)),
                              const Spacer(),
                              GestureDetector(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF9333EA),
                                    borderRadius:
                                    BorderRadius.circular(8),
                                  ),
                                  child: Text('Contact',
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