import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:resqare_app/models/login_model.dart';
import 'package:resqare_app/models/user_model_firebase.dart';

class UserRepositoryFirebase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register New User
  Future<bool> registerUser(UserModelFirebase pengguna) async {
    try {
      final docRef = pengguna.id != null
          ? _firestore.collection('users').doc(pengguna.id)
          : _firestore.collection('users').doc();

      final userToSave = pengguna.id != null
          ? pengguna
          : pengguna.copyWith(id: docRef.id);
      await docRef.set(userToSave.toMap());
      return true;
    } catch (e) {
      log("Error registering user: ${e.toString()}");
      return false;
    }
  }

  // Check Existing Email
  Future<bool> checkEmailExists(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      log("Error checking email: ${e.toString()}");
      return false;
    }
  }

  // Check Existing Phone
  Future<bool> checkPhoneExists(String phone) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      log("Error checking phone: ${e.toString()}");
      return false;
    }
  }

  // Login User
  Future<UserModelFirebase?> loginUser(LoginModel pengguna) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: pengguna.email)
          .where('password', isEqualTo: pengguna.password)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return UserModelFirebase.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      log("Error logging in: ${e.toString()}");
      return null;
    }
  }

  // Sign in with Google
  Future<UserModelFirebase?> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn.instance.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) return null;

      // Check if user exists in Firestore
      final doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
      if (doc.exists) {
        return UserModelFirebase.fromFirestore(doc);
      } else {
        // Create new user in Firestore
        final newUser = UserModelFirebase(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? "",
          password: "", // No password for Google Sign-In users
          fullName: firebaseUser.displayName ?? "Pengguna Google",
          phone: firebaseUser.phoneNumber,
          role: "reporter", // Default role
          isVerified: 0,
          imgProfile: firebaseUser.photoURL,
        );

        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(newUser.toMap());
        return newUser;
      }
    } catch (e) {
      log("Error signing in with Google: ${e.toString()}");
      return null;
    }
  }

  // Update User
  Future<bool> updateUser({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update(data);
      return true;
    } catch (e) {
      log("Error updating user: ${e.toString()}");
      return false;
    }
  }

  // Get User by ID
  Future<UserModelFirebase?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModelFirebase.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      log("Error getting user by id: ${e.toString()}");
      return null;
    }
  }

  // Legacy name for Get User by ID
  Future<UserModelFirebase?> getReport({required String reportId}) async {
    return getUserById(reportId);
  }

  // Get user contribution and rescue stats
  Future<Map<String, int>> getUserStats(String userId) async {
    try {
      // Get reports count where createdBy == userId
      final reportsQuery = await _firestore
          .collection('reports')
          .where('createdBy', isEqualTo: userId)
          .get();
      final reportsCreated = reportsQuery.docs.length;

      // Get rescue count from volunteers collection
      final volunteerDoc = await _firestore
          .collection('volunteers')
          .doc(userId)
          .get();
      int rescueCount = 0;
      if (volunteerDoc.exists) {
        final data = volunteerDoc.data();
        rescueCount = data?['rescueCount'] as int? ?? 0;
      }

      return {'reportsCreated': reportsCreated, 'rescueCount': rescueCount};
    } catch (e) {
      log("Error getting user stats: ${e.toString()}");
      return {'reportsCreated': 0, 'rescueCount': 0};
    }
  }

  // Get volunteer status
  Future<String?> getVolunteerStatus(String userId) async {
    try {
      final doc = await _firestore.collection('volunteers').doc(userId).get();
      if (doc.exists) {
        return doc.data()?['status'] as String?;
      }
      return null;
    } catch (e) {
      log("Error getting volunteer status: ${e.toString()}");
      return null;
    }
  }

  // Update volunteer status
  Future<bool> updateVolunteerStatus(String userId, String status) async {
    try {
      await _firestore.collection('volunteers').doc(userId).update({
        'status': status,
      });
      return true;
    } catch (e) {
      log("Error updating volunteer status: ${e.toString()}");
      return false;
    }
  }

  // Increment volunteer rescue count
  Future<bool> incrementVolunteerRescueCount(String userId) async {
    try {
      await _firestore.collection('volunteers').doc(userId).update({
        'rescueCount': FieldValue.increment(1),
      });
      return true;
    } catch (e) {
      log("Error incrementing volunteer rescue count: ${e.toString()}");
      return false;
    }
  }

  // Register Volunteer User with Application
  Future<bool> registerVolunteerWithApplication({
    required UserModelFirebase user,
    required String experience,
    required String reason,
    required List<String> certificateImages,
  }) async {
    try {
      final batch = _firestore.batch();

      final userDocRef = user.id != null
          ? _firestore.collection('users').doc(user.id)
          : _firestore.collection('users').doc();
      final userToSave = user.id != null
          ? user
          : user.copyWith(id: userDocRef.id);

      batch.set(userDocRef, userToSave.toMap());

      final String? img1 = certificateImages.isNotEmpty
          ? certificateImages[0]
          : null;
      final String? img2 = certificateImages.length > 1
          ? certificateImages[1]
          : null;
      final String? img3 = certificateImages.length > 2
          ? certificateImages[2]
          : null;

      final now = DateTime.now().toIso8601String();
      final appDocRef = _firestore
          .collection('volunteer_applications')
          .doc(userToSave.id);

      batch.set(appDocRef, {
        'userId': userToSave.id,
        'experience': experience,
        'reason': reason,
        'image1': img1,
        'image2': img2,
        'image3': img3,
        'status': 'pending',
        'createdAt': now,
        'updatedAt': now,
      });

      await batch.commit();
      return true;
    } catch (e) {
      log("Error registering volunteer: ${e.toString()}");
      return false;
    }
  }

  // Check if a volunteer is active
  Future<bool> isVolunteerActive(String userId) async {
    try {
      final doc = await _firestore.collection('volunteers').doc(userId).get();
      if (doc.exists) {
        final data = doc.data();
        final isActiveVal = data?['isActive'];
        if (isActiveVal is bool) {
          return isActiveVal;
        } else if (isActiveVal is num) {
          return isActiveVal == 1;
        }
      }
      return false;
    } catch (e) {
      log("Error checking volunteer active state: ${e.toString()}");
      return false;
    }
  }

  // Update volunteer active state
  Future<bool> updateVolunteerActive(String userId, bool isActive) async {
    try {
      await _firestore.collection('volunteers').doc(userId).update({
        'isActive': isActive,
      });
      return true;
    } catch (e) {
      log("Error updating volunteer active state: ${e.toString()}");
      return false;
    }
  }

  // Get volunteer application by userId
  Future<Map<String, dynamic>?> getVolunteerApplication(String userId) async {
    try {
      final doc = await _firestore
          .collection('volunteer_applications')
          .doc(userId)
          .get();
      if (doc.exists) {
        return doc.data();
      }
      // Fallback query in case the document ID is not the userId
      final query = await _firestore
          .collection('volunteer_applications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first.data();
      }
      return null;
    } catch (e) {
      log("Error getting volunteer application: ${e.toString()}");
      return null;
    }
  }

  // Submit new volunteer application for existing user
  Future<bool> submitVolunteerApplication({
    required String userId,
    required String experience,
    required String reason,
    required List<String> certificateImages,
    String? newPhone,
  }) async {
    try {
      final batch = _firestore.batch();

      if (newPhone != null && newPhone.trim().isNotEmpty) {
        batch.update(_firestore.collection('users').doc(userId), {
          'phone': newPhone.trim(),
        });
      }

      final String? img1 = certificateImages.isNotEmpty
          ? certificateImages[0]
          : null;
      final String? img2 = certificateImages.length > 1
          ? certificateImages[1]
          : null;
      final String? img3 = certificateImages.length > 2
          ? certificateImages[2]
          : null;

      final now = DateTime.now().toIso8601String();
      final appDocRef = _firestore
          .collection('volunteer_applications')
          .doc(userId);

      batch.set(appDocRef, {
        'userId': userId,
        'experience': experience,
        'reason': reason,
        'image1': img1,
        'image2': img2,
        'image3': img3,
        'status': 'pending',
        'createdAt': now,
        'updatedAt': now,
      });

      await batch.commit();
      return true;
    } catch (e) {
      log("Error submitting volunteer application: ${e.toString()}");
      return false;
    }
  }

  // Update volunteer application for existing user
  Future<bool> updateVolunteerApplicationWithTxn({
    required String userId,
    required String experience,
    required String reason,
    required List<String> certificateImages,
    String? newPhone,
  }) async {
    try {
      final batch = _firestore.batch();

      if (newPhone != null && newPhone.trim().isNotEmpty) {
        batch.update(_firestore.collection('users').doc(userId), {
          'phone': newPhone.trim(),
        });
      }

      final String? img1 = certificateImages.isNotEmpty
          ? certificateImages[0]
          : null;
      final String? img2 = certificateImages.length > 1
          ? certificateImages[1]
          : null;
      final String? img3 = certificateImages.length > 2
          ? certificateImages[2]
          : null;

      final now = DateTime.now().toIso8601String();
      final appDocRef = _firestore
          .collection('volunteer_applications')
          .doc(userId);

      batch.set(appDocRef, {
        'experience': experience,
        'reason': reason,
        'image1': img1,
        'image2': img2,
        'image3': img3,
        'updatedAt': now,
      }, SetOptions(merge: true));

      await batch.commit();
      return true;
    } catch (e) {
      log("Error updating volunteer application: ${e.toString()}");
      return false;
    }
  }
}
