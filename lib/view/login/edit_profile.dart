import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common_widget/primary_button.dart';

import 'package:untitled/view/main_tab/main_tab_view.dart';

import '../../common/color_extension.dart';
import '../../service/AuthenticationService.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final AuthenticationService authService = AuthenticationService();

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController currentPasswordCtrl = TextEditingController(); // 👈 NEW

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final userData = await authService.getCurrentUserData();
    if (userData != null) {
      nameCtrl.text = userData['name'] ?? '';
      emailCtrl.text = userData['email'] ?? '';
      phoneCtrl.text = userData['phone'] ?? '';
    }
  }

  Future<void> saveProfile() async {
    setState(() => isLoading = true);

    final isSuccess = await authService.updateCurrentUserData(
      name: nameCtrl.text.trim(),
      email: emailCtrl.text.trim(),
      phone: phoneCtrl.text.trim(),
      currentPassword: currentPasswordCtrl.text.trim(), // 👈 Pass password
    );

    setState(() => isLoading = false);

    if (isSuccess == true) {


      final updatedUser = await authService.getCurrentUserData();
      print("updated user, ${updatedUser}");
      Get.snackbar("Success", "Profile updated successfully", colorText: TColor.line);
      Get.to(()=> const MainTabView());
    } else {
      print("Profile update failed. Check logs for more details.");
      Get.snackbar("Error", "Failed to update profile", colorText: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.back,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: TColor.gray60),
        title: const Text("Edit Profile", style: TextStyle(fontSize: 18, color: Colors.black)),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneCtrl,
                decoration: InputDecoration(
                  labelText: "Phone",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: currentPasswordCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "enter new password",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 30),
              PrimaryButton(title: "Save", onPress: saveProfile, color: TColor.white),
            ],
          ),
        ),
      ),
    );
  }
}
