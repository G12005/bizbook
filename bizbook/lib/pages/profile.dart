import 'package:bizbook/backend/auth.dart';
import 'package:bizbook/widget/appbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  bool isEditing = false;

  // Form controllers
  late TextEditingController nameController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current user data
    nameController = TextEditingController(text: user?.displayName ?? "");
    emailController = TextEditingController(text: user?.email ?? "");
  }

  @override
  void dispose() {
    // Clean up controllers
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  // Toggle edit mode
  void toggleEditMode() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  // Save profile changes
  Future<void> saveProfile() async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Update display name
      if (user != null && nameController.text.isNotEmpty) {
        await user!.updateDisplayName(nameController.text);
      }

      // Update email if changed
      if (user != null &&
          emailController.text.isNotEmpty &&
          emailController.text != user!.email) {
        await user!.verifyBeforeUpdateEmail(emailController.text);
      }

      // Note: Updating phone number typically requires verification
      // You would need to implement phone verification flow

      // Here you would save additional fields like address to your database

      // Refresh user data
      await user?.reload();

      // Close loading dialog
      if (!mounted) return;
      Navigator.pop(context);
      Navigator.pop(context);

      // Exit edit mode
      setState(() {
        isEditing = false;
      });

      // Show success message
      AuthService().showToast(
        context,
        "Profile updated successfully",
        true,
      );
    } catch (e) {
      // Close loading dialog
      if (!mounted) return;
      Navigator.pop(context);

      // Show error message
      if (context.mounted) {
        if (!mounted) return;
        AuthService().showToast(
          context,
          "Error in updating the profile",
          false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: backAppBar("Edit Profile", context, []),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Profile Image
              SizedBox(
                height: 50,
              ),
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(
                        0xFFF2EBE3), // Beige background from screenshots
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null
                        ? const Icon(
                            Icons.person,
                            size: 60,
                            color:
                                Color(0xFF7BA37E), // Green color from app theme
                          )
                        : null,
                  ),
                  if (isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF7BA37E),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon:
                              const Icon(Icons.camera_alt, color: Colors.white),
                          onPressed: () {
                            // Implement image picker functionality
                          },
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 30),

              // Form fields
              ProfileField(
                label: "Name",
                controller: nameController,
                enabled: isEditing,
                icon: Icons.person,
              ),
              const SizedBox(height: 15),

              ProfileField(
                label: "Email",
                controller: emailController,
                enabled: isEditing,
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 30),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isEditing)
                    ElevatedButton(
                      onPressed: toggleEditMode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7BA37E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Edit Profile"),
                    )
                  else
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: toggleEditMode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text("Cancel"),
                        ),
                        const SizedBox(width: 15),
                        ElevatedButton(
                          onPressed: saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7BA37E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text("Save"),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom widget for profile form fields
class ProfileField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final IconData icon;
  final TextInputType keyboardType;
  final int maxLines;

  const ProfileField({
    super.key,
    required this.label,
    required this.controller,
    required this.enabled,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2EBE3), // Beige background from screenshots
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: const Color(0xFF7BA37E),
            size: 24,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              keyboardType: keyboardType,
              maxLines: maxLines,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                labelText: label,
                border: InputBorder.none,
                labelStyle: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
