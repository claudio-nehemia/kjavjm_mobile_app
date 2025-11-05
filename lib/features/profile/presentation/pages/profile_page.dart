import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../core/utils/image_upload_helper.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/data/models/user_model.dart';
import '../../data/services/profile_service.dart';
import '../widgets/modern_profile_header.dart';
import '../widgets/modern_stats_card.dart';
import '../widgets/modern_menu_section.dart';

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
    _fetchProfileWithStatistics();
  }

  void _fetchProfileWithStatistics() async {
    try {
      print('📊 Fetching profile with statistics...');
      final dio = GetIt.instance<Dio>();
      final response = await dio.get('/profile');
      
      print('✅ Profile response: ${response.data}');
      
      if (response.data != null && response.data['user'] != null) {
        final userModel = UserModel.fromJson(response.data);
        
        // Update AuthBloc dengan data baru (termasuk statistics)
        if (mounted) {
          context.read<AuthBloc>().add(AuthUserUpdated(userModel));
        }
      }
    } catch (e) {
      print('❌ Error fetching profile: $e');
    }
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
      // Pick image using ImageUploadHelper - PASTI WORK DI WEB DAN MOBILE
      final file = await ImageUploadHelper.pickImageFromGallery();

      if (file == null) {
        return; // User cancelled
      }

      // Validate file size (max 5MB)
      final isValid = await ImageUploadHelper.validateFileSize(file, 5);
      if (!isValid) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File terlalu besar! Maksimal 5MB'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

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
          statistics: currentAuthState.user.statistics, // Preserve statistics
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
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/login',
              (route) => false,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Berhasil keluar'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profil berhasil diperbarui'),
                backgroundColor: AppColors.success,
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
                backgroundColor: AppColors.danger,
              ),
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is! AuthAuthenticated) {
              return const Center(child: CircularProgressIndicator());
            }

            // Debug: Print statistics data
            print('=== PROFILE PAGE DEBUG ===');
            print('User: ${state.user.name}');
            print('Statistics: ${state.user.statistics}');
            if (state.user.statistics != null) {
              print('Total Present: ${state.user.statistics!.totalPresent}');
              print('Total Leave: ${state.user.statistics!.totalLeave}');
              print('Total Absent: ${state.user.statistics!.totalAbsent}');
              print('Month: ${state.user.statistics!.month}');
              print('Year: ${state.user.statistics!.year}');
            } else {
              print('⚠️ Statistics is NULL!');
            }
            print('=== END DEBUG ===');

            return CustomScrollView(
              slivers: [
                // Modern App Bar
                SliverAppBar(
                  expandedHeight: 240,
                  floating: false,
                  pinned: true,
                  backgroundColor: AppColors.primary,
                  flexibleSpace: FlexibleSpaceBar(
                    background: ModernProfileHeader(
                      key: ValueKey(state.user.photoUrl), // Force rebuild when photo changes
                      name: state.user.name,
                      photoUrl: state.user.photoUrl,
                      email: state.user.email,
                      department: state.user.department?.name ?? '-',
                      userId: state.user.id.toString(),
                      onEditPhoto: _pickAndUploadPhoto,
                    ),
                  ),
                  actions: [
                    if (_isEditingProfile)
                      TextButton.icon(
                        onPressed: _saveProfile,
                        icon: const Icon(Icons.check, color: Colors.white, size: 20),
                        label: const Text(
                          'Simpan',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),

                // Body Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Statistics Card (Optional - can show attendance stats)
                        if (!_isEditingProfile && !_isChangingPassword)
                          ModernStatsCard(
                            stats: [
                              StatItem(
                                icon: Icons.check_circle_rounded,
                                label: 'Hadir',
                                value: state.user.statistics?.totalPresent ?? 0,
                                color: AppColors.success,
                              ),
                              StatItem(
                                icon: Icons.event_busy_rounded,
                                label: 'Izin',
                                value: state.user.statistics?.totalLeave ?? 0,
                                color: AppColors.warning,
                              ),
                              StatItem(
                                icon: Icons.cancel_rounded,
                                label: 'Tidak Hadir',
                                value: state.user.statistics?.totalAbsent ?? 0,
                                color: AppColors.danger,
                              ),
                            ],
                          ),
                        
                        if (!_isEditingProfile && !_isChangingPassword)
                          const SizedBox(height: 20),

                        // Profile Form or Menu
                        if (_isEditingProfile)
                          _buildProfileForm()
                        else if (_isChangingPassword)
                          _buildChangePasswordSection()
                        else
                          _buildModernMenu(state),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildModernMenu(AuthAuthenticated state) {
    return Column(
      children: [
        // Account Settings Menu
        ModernMenuSection(
          title: 'Pengaturan Akun',
          items: [
            ModernMenuItem(
              icon: Icons.person_rounded,
              iconColor: AppColors.primary,
              title: 'Edit Profil',
              subtitle: 'Perbarui informasi pribadi Anda',
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {
                setState(() {
                  _isEditingProfile = true;
                });
              },
            ),
            ModernMenuItem(
              icon: Icons.lock_rounded,
              iconColor: AppColors.warning,
              title: 'Ubah Password',
              subtitle: 'Tingkatkan keamanan akun Anda',
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {
                setState(() {
                  _isChangingPassword = true;
                });
              },
            ),
          ],
        ),

        const SizedBox(height: 20),

        // System Information Menu
        ModernMenuSection(
          title: 'Informasi Sistem',
          items: [
            ModernMenuItem(
              icon: Icons.email_rounded,
              iconColor: AppColors.info,
              title: 'Email',
              subtitle: state.user.email,
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Verified',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.info,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: () {},
            ),
            ModernMenuItem(
              icon: Icons.badge_rounded,
              iconColor: AppColors.primary,
              title: 'Role',
              subtitle: state.user.role?.name ?? '-',
              onTap: () {},
            ),
            ModernMenuItem(
              icon: Icons.business_rounded,
              iconColor: AppColors.secondary,
              title: 'Departemen',
              subtitle: state.user.department?.name ?? '-',
              onTap: () {},
            ),
            ModernMenuItem(
              icon: Icons.verified_user_rounded,
              iconColor: state.user.status?.toLowerCase() == 'active' || state.user.status == null
                  ? AppColors.success
                  : AppColors.danger,
              title: 'Status',
              subtitle: state.user.status ?? 'Aktif',
              onTap: () {},
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Logout Button
        _buildModernLogoutButton(),
      ],
    );
  }

  Widget _buildModernLogoutButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            AppColors.danger.withOpacity(0.1),
            AppColors.danger.withOpacity(0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.danger.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showLogoutDialog,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: AppColors.danger,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Keluar dari Akun',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.danger,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Cancel Button
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.15),
                        AppColors.primary.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Edit Profil',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isEditingProfile = false;
                      _loadUserData();
                    });
                  },
                  icon: Icon(
                    Icons.close_rounded,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            const Text(
              'Informasi Personal',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nameController,
              label: 'Nama Lengkap',
              icon: Icons.person_rounded,
              enabled: true,
              required: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _phoneController,
              label: 'Nomor Telepon',
              icon: Icons.phone_rounded,
              enabled: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _addressController,
              label: 'Alamat',
              icon: Icons.home_rounded,
              enabled: true,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _cityController,
                    label: 'Kota',
                    icon: Icons.location_city_rounded,
                    enabled: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _postalCodeController,
                    label: 'Kode Pos',
                    icon: Icons.markunread_mailbox_rounded,
                    enabled: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Simpan Perubahan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
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
            // Cek apakah response mengembalikan data user
            final responseUser = result['user'];
            
            // Debug: Print untuk melihat data
            print('=== DEBUG SAVE PROFILE ===');
            print('Response user: $responseUser');
            print('Current profilePicture: ${currentAuthState.user.profilePicture}');
            print('Current photoUrl: ${currentAuthState.user.photoUrl}');
            
            final updatedUser = User(
              id: currentAuthState.user.id,
              name: _nameController.text,
              email: currentAuthState.user.email,
              phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
              address: _addressController.text.isNotEmpty ? _addressController.text : null,
              city: _cityController.text.isNotEmpty ? _cityController.text : null,
              postalCode: _postalCodeController.text.isNotEmpty ? _postalCodeController.text : null,
              status: currentAuthState.user.status,
              // Gunakan foto dari response jika ada, kalau tidak preserve dari state lama
              profilePicture: responseUser != null && responseUser['profile_picture'] != null 
                  ? responseUser['profile_picture'] 
                  : currentAuthState.user.profilePicture,
              photoUrl: responseUser != null && responseUser['photo_url'] != null 
                  ? responseUser['photo_url'] 
                  : currentAuthState.user.photoUrl,
              role: currentAuthState.user.role,
              department: currentAuthState.user.department,
              token: currentAuthState.user.token,
              statistics: currentAuthState.user.statistics, // Preserve statistics
            );
            
            print('Updated profilePicture: ${updatedUser.profilePicture}');
            print('Updated photoUrl: ${updatedUser.photoUrl}');
            print('=== END DEBUG ===');
            
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