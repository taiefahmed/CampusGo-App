import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class CallHelper {
  /// Phone dialer খোলে দেওয়া নাম্বারে
  static Future<void> makeCall(BuildContext context, String phone) async {
    if (phone.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone নাম্বার পাওয়া যায়নি')),
      );
      return;
    }
    final uri = Uri(scheme: 'tel', path: phone.trim());
    final canCall = await canLaunchUrl(uri);
    if (canCall) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Call করা যাচ্ছে না')),
      );
    }
  }

  /// Card/list এ বসানোর জন্য ছোট "Call" বাটন
  static Widget callButton({
    required BuildContext context,
    required String phone,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => makeCall(context, phone),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.call, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(
              'Call',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}