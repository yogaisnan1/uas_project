import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  File? _profileImage;
  String? _profileImageUrl;
  String? _username;
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    final user = Supabase.instance.client.auth.currentUser;
    setState(() {
      _username =
          user?.userMetadata?['username'] ??
          user?.email?.split('@').first ??
          'Unknown';
      _email = user?.email ?? 'Unknown';
      // Load profile image URL from user metadata
      if (user?.userMetadata?['avatar_url'] != null) {
        _profileImageUrl = user!.userMetadata!['avatar_url'] as String;
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    PermissionStatus status;
    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
    } else {
      if (Platform.isIOS) {
        status = await Permission.photos.request();
      } else {
        status = await Permission.storage.request();
      }
    }

    if (status.isGranted) {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source);
      if (picked != null) {
        try {
          // Upload to Supabase storage
          final user = Supabase.instance.client.auth.currentUser;
          if (user == null) return;
          
          final bytes = await picked.readAsBytes();
          final fileExt = picked.path.split('.').last;
          final fileName = '${user.id}_profile.${fileExt}';
          final filePath = 'profile/$fileName';

          await Supabase.instance.client.storage
              .from('avatars')
              .uploadBinary(filePath, bytes,
                  fileOptions: FileOptions(upsert: true));

          // Get public URL
          final imageUrl = Supabase.instance.client.storage
              .from('avatars')
              .getPublicUrl(filePath);

          // Update user metadata
          await Supabase.instance.client.auth.updateUser(
            UserAttributes(
              data: {'avatar_url': imageUrl},
            ),
          );

          setState(() {
            _profileImage = File(picked.path);
            _profileImageUrl = imageUrl;
          });
          
        } catch (e) {
          if (kDebugMode) {
            print('Upload failed: $e');
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload profile picture'),
            ),
          );
        }
      } else {
        if (kDebugMode) {
          print('Error: No image picked');
        }
      }
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    } else {
      if (kDebugMode) {
        print('Error: Permission not granted');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permission not granted. Please enable access in settings.'),
        ),
      );
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: const BoxDecoration(
                color: Color(0xFF5B5FE9),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _showImageSourceActionSheet,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          backgroundImage: _profileImageUrl != null
                              ? NetworkImage(_profileImageUrl!)
                              : (_profileImage != null
                                  ? FileImage(_profileImage!)
                                  : const AssetImage(
                                      'assets/profile_placeholder.png',
                                    ) as ImageProvider),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: const Icon(Icons.edit, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _username ?? 'Username',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _ProfileButton(
              icon: Icons.person,
              label: 'Akun',
              onTap: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Account Details'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Username: ${_username ?? ''}'),
                            const SizedBox(height: 8),
                            Text('Email: ${_email ?? ''}'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                );
              },
            ),
            _ProfileButton(
              icon: Icons.settings,
              label: 'Settings',
              onTap: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Settings'),
                        content: const Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('App Version: 1.0.0'),
                            SizedBox(height: 8),
                            Text('Theme: Light'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                );
              },
            ),
            _ProfileButton(
              icon: Icons.logout,
              label: 'Log out',
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ProfileButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Material(
        color: const Color(0xFF5B5FE9),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
