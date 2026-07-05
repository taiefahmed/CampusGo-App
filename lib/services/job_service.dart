import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_model.dart';

class JobService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // সব job আনো
  Stream<List<JobModel>> getJobs() {
    return _firestore
        .collection('jobs')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => JobModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  // Type দিয়ে filter করো
  Stream<List<JobModel>> getJobsByType(String type) {
    return _firestore
        .collection('jobs')
        .where('type', isEqualTo: type)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => JobModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  // Job add করো
  Future<void> addJob(JobModel job) async {
    await _firestore.collection('jobs').add(job.toMap());
  }

  // Job delete করো
  Future<void> deleteJob(String jobId) async {
    await _firestore.collection('jobs').doc(jobId).delete();
  }
}