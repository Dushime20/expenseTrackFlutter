import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:untitled/common/color_extension.dart';

class AuthenticationService {

  //for storing data in cloud firestore
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //for authentication
  final FirebaseAuth auth = FirebaseAuth.instance;


  final box = GetStorage();

//for signup

  Future<String> signUpUser({
    required String email,
    required String name,
    required String password,
    required String phone,
    required String confirmPassword,
  }) async
  {
    String res = "Some error occurred";

    try {
      // Check if password and confirmPassword match
      if (password != confirmPassword) {
        return "Passwords do not match";
      }

      // Register the user with Firebase Auth
      UserCredential credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Print user creation status
      print("User created successfully with UID: ${credential.user!.uid}");

      // Add the user to Firestore
      await firestore.collection("users").doc(credential.user!.uid).set({
        "name": name,
        "email": email,
        "phone": phone,
        "uid": credential.user!.uid,
      });
      Get.snackbar("Success", "Signup successfully", colorText: TColor.line);
      res = "success";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        res = 'Email is already in use';
      } else if (e.code == 'invalid-email') {
        res = 'Invalid email address';
      } else if (e.code == 'weak-password') {
        res = 'Password is too weak';
      } else {
        res = e.message ?? 'An unknown error occurred';
      }

    } catch (e) {
      res = e.toString();
    }
    print("The response is: $res");
    return res;
  }


  Future<Map<String, dynamic>> loginUser({  // ✅ Changed return type from String to Map
    required String email,
    required String password,
  }) async {
    Map<String, dynamic> res = {
      'status': 'error',
      'message': 'Some error occurred',
    };

    try {
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user?.uid;
      final userEmail = userCredential.user?.email;

      //  return user info on success
      res = {
        'status': 'success',
        'uid': uid,
        'email': userEmail,
      };
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        res['message'] = "No user found for that email.";
      } else if (e.code == 'wrong-password') {
        res['message'] = "Incorrect password.";
      } else if (e.code == 'invalid-email') {
        res['message'] = "Invalid email address.";
      } else {
        res['message'] = e.message ?? "An unknown error occurred";
      }
    } catch (e) {
      res['message'] = e.toString();
    }

    return res; // Now returning a Map with user data or error
  }


  //for logout
  Future<void> signOut() async {
    await auth.signOut(); // Sign out from Fire

    // Clear saved user info from GetStorage
    box.remove('uid');
    box.remove('email');
    box.remove('isLoggedIn');
 // Replace LoginPage with your actual login screen
  }


}