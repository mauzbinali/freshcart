import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _loading = false;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider).value;
    if (user != null) {
      _nameCtrl.text = user.name;
      _phoneCtrl.text = user.phone;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final user = ref.read(currentUserProvider).value;
      if (user == null) return;

      String? avatarUrl = user.avatarUrl;

      // Upload new avatar if selected
      if (_imageFile != null) {
        avatarUrl = await ref.read(firestoreServiceProvider).uploadImage(
              _imageFile!,
              'user_avatars/${user.id}.jpg',
            );
      }

      await ref.read(firestoreServiceProvider).updateUser(user.id, {
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      });

      if (!mounted) return;
      AppUtils.showToast('Profile updated!');
      if (mounted) context.pop();
    } catch (e) {
      if (!mounted) return;
      AppUtils.showSnackBar(context, 'Update failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: _loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save',
                    style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 12),

              // Avatar
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundColor: Colors.green.shade100,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!) as ImageProvider
                          : (user?.avatarUrl != null
                              ? NetworkImage(user!.avatarUrl!)
                              : null),
                      child: (_imageFile == null && user?.avatarUrl == null)
                          ? Text(
                              AppUtils.firstInitial(user?.name),
                              style: const TextStyle(
                                  fontSize: 36,
                                  color: AppTheme.primaryGreen,
                                  fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outlined),
                ),
                validator: (v) => v!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (v) => v!.isEmpty ? 'Phone is required' : null,
              ),
              const SizedBox(height: 16),

              // Email (read-only)
              TextFormField(
                initialValue: user?.email,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Email (cannot be changed)',
                  prefixIcon: const Icon(Icons.email_outlined),
                  fillColor: Colors.grey.shade100,
                  filled: true,
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: _loading ? null : _save,
                icon: const Icon(Icons.save),
                label: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
