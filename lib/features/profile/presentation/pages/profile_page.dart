import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/domain/entities/user.dart';
import '../../data/services/profile_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isEditingProfile = false;
  bool _isChangingPassword = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    // Load user data from AuthBloc
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _nameController.text = authState.user.name;
      _phoneController.text = authState.user.phone ?? '';
      _addressController.text = authState.user.address ?? '';
      _cityController.text = authState.user.city ?? '';
      _postalCodeController.text = authState.user.postalCode ?? '';
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    try {
      // Pick image file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.first;

      // Show loading
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Upload photo
      final profileService = GetIt.instance<ProfileService>();
      final photoResult = await profileService.updatePhoto(file);

      // Update user data in AuthBloc
      if (!mounted) return;
      final currentAuthState = context.read<AuthBloc>().state;
      if (currentAuthState is AuthAuthenticated) {
        final updatedUser = User(
          id: currentAuthState.user.id,
          name: currentAuthState.user.name,
          email: currentAuthState.user.email,
          phone: currentAuthState.user.phone,
          address: currentAuthState.user.address,
          city: currentAuthState.user.city,
          postalCode: currentAuthState.user.postalCode,
          status: currentAuthState.user.status,
          profilePicture: photoResult['user']['profile_picture'],
          photoUrl: photoResult['user']['photo_url'],
          role: currentAuthState.user.role,
          department: currentAuthState.user.department,
          token: currentAuthState.user.token,
        );
        
        context.read<AuthBloc>().add(AuthUserUpdated(updatedUser));
      }

      // Close loading
      if (!mounted) return;
      Navigator.pop(context);

      // Show success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto profil berhasil diperbarui'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
    } catch (e) {
      // Close loading if open
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Show error message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengupload foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        actions: [
          if (_isEditingProfile)
            TextButton(
              onPressed: _saveProfile,
              child: const Text(
                'Simpan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          if (!_isEditingProfile && !_isChangingPassword)
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditingProfile = true;
                });
              },
              child: const Text(
                'Edit',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            // Navigate to login and clear all previous routes
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/login',
              (route) => false,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Berhasil keluar'),
                backgroundColor: Color(0xFF2E7D32),
              ),
            );
          } else if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profil berhasil diperbarui'),
                backgroundColor: Color(0xFF2E7D32),
              ),
            );
            setState(() {
              _isEditingProfile = false;
              _isChangingPassword = false;
            });
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 20),
              _buildProfileForm(),
              const SizedBox(height: 20),
              _buildChangePasswordSection(),
              const SizedBox(height: 20),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    UserAvatar(
                      photoUrl: state.user.photoUrl,
                      userName: state.user.name,
                      size: 100,
                      showBorder: true,
                      onTap: _pickAndUploadPhoto,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickAndUploadPhoto,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  state.user.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  state.user.email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: (state.user.status?.toLowerCase() == 'active' || state.user.status == null)
                            ? const Color(0xFF2E7D32).withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        state.user.status ?? 'Aktif',
                        style: TextStyle(
                          fontSize: 12,
                          color: (state.user.status?.toLowerCase() == 'active' || state.user.status == null)
                              ? const Color(0xFF2E7D32)
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildProfileForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Personal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nameController,
              label: 'Nama Lengkap',
              icon: Icons.person,
              enabled: _isEditingProfile,
              required: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _phoneController,
              label: 'Nomor Telepon',
              icon: Icons.phone,
              enabled: _isEditingProfile,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _addressController,
              label: 'Alamat',
              icon: Icons.home,
              enabled: _isEditingProfile,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _cityController,
                    label: 'Kota',
                    icon: Icons.location_city,
                    enabled: _isEditingProfile,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _postalCodeController,
                    label: 'Kode Pos',
                    icon: Icons.mail,
                    enabled: _isEditingProfile,
                  ),
                ),
              ],
            ),
            // Read-only fields
            const SizedBox(height: 20),
            const Text(
              'Informasi Sistem',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthAuthenticated) {
                  return Column(
                    children: [
                      _buildReadOnlyField(
                        label: 'Email',
                        value: state.user.email,
                        icon: Icons.email,
                      ),
                      const SizedBox(height: 12),
                      _buildReadOnlyField(
                        label: 'Role',
                        value: state.user.role?.name ?? '-',
                        icon: Icons.badge,
                      ),
                      const SizedBox(height: 12),
                      _buildReadOnlyField(
                        label: 'Departemen',
                        value: state.user.department?.name ?? '-',
                        icon: Icons.business,
                      ),
                    ],
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChangePasswordSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ubah Password',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isChangingPassword = !_isChangingPassword;
                    if (!_isChangingPassword) {
                      _currentPasswordController.clear();
                      _newPasswordController.clear();
                      _confirmPasswordController.clear();
                    }
                  });
                },
                child: Text(
                  _isChangingPassword ? 'Batal' : 'Ubah',
                  style: const TextStyle(color: Color(0xFF2E7D32)),
                ),
              ),
            ],
          ),
          if (_isChangingPassword) ...[
            const SizedBox(height: 16),
            _buildTextField(
              controller: _currentPasswordController,
              label: 'Password Saat Ini',
              icon: Icons.lock_outline,
              obscureText: true,
              enabled: true,
              required: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _newPasswordController,
              label: 'Password Baru',
              icon: Icons.lock,
              obscureText: true,
              enabled: true,
              required: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _confirmPasswordController,
              label: 'Konfirmasi Password Baru',
              icon: Icons.lock,
              obscureText: true,
              enabled: true,
              required: true,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Simpan Password'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    bool required = false,
    bool obscureText = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: enabled ? const Color(0xFF2E7D32) : Colors.grey,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2E7D32)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey[100],
      ),
      validator: required
          ? (value) {
              if (value == null || value.isEmpty) {
                return '$label tidak boleh kosong';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.grey,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _showLogoutDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout),
            SizedBox(width: 8),
            Text('Keluar'),
          ],
        ),
      ),
    );
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final profileService = GetIt.instance<ProfileService>();
        
        final result = await profileService.updateProfile(
          name: _nameController.text,
          phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
          address: _addressController.text.isNotEmpty ? _addressController.text : null,
          city: _cityController.text.isNotEmpty ? _cityController.text : null,
          postalCode: _postalCodeController.text.isNotEmpty ? _postalCodeController.text : null,
        );

        if (mounted) {
          // Update AuthBloc state dengan data baru
          final currentAuthState = context.read<AuthBloc>().state;
          if (currentAuthState is AuthAuthenticated) {
            final updatedUser = User(
              id: currentAuthState.user.id,
              name: _nameController.text,
              email: currentAuthState.user.email,
              phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
              address: _addressController.text.isNotEmpty ? _addressController.text : null,
              city: _cityController.text.isNotEmpty ? _cityController.text : null,
              postalCode: _postalCodeController.text.isNotEmpty ? _postalCodeController.text : null,
              status: currentAuthState.user.status,
              profilePicture: currentAuthState.user.profilePicture,
              role: currentAuthState.user.role,
              department: currentAuthState.user.department,
              token: currentAuthState.user.token,
            );
            
            // Update AuthBloc state dengan user baru
            context.read<AuthBloc>().add(AuthUserUpdated(updatedUser));
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Profile updated successfully'),
              backgroundColor: const Color(0xFF2E7D32),
            ),
          );
          setState(() {
            _isEditingProfile = false;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update profile: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _changePassword() {
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua field password harus diisi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konfirmasi password tidak cocok'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _performChangePassword();
  }

  void _performChangePassword() async {
    try {
      final profileService = GetIt.instance<ProfileService>();
      
      final result = await profileService.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Password changed successfully'),
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );
        
        setState(() {
          _isChangingPassword = false;
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to change password: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Keluar'),
          content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Use the widget's context, not dialog context
                context.read<AuthBloc>().add(LogoutRequested());
              },
              child: const Text(
                'Keluar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}