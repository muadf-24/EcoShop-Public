import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/color_schemes.dart';
import '../../../../core/widgets/animated_widgets.dart';
import '../../../../core/services/theme_service.dart';
import '../../../../injection_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/avatar_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isUploading = false;


  Future<void> _pickAndUploadAvatar(BuildContext context, String userId) async {
    final avatarService = sl<AvatarService>();
    final authBloc = context.read<AuthBloc>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Show source picker
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final image = await avatarService.pickImage(source);
    if (image == null) return;

    final authState = authBloc.state;
    if (authState is! AuthAuthenticated) return;
    
    final user = authState.user;

    if (!mounted) return;
    setState(() => _isUploading = true);

    try {
      final downloadUrl = await avatarService.uploadAvatar(
        userId: userId,
        imageFile: image,
      );

      if (mounted) {
        authBloc.add(AuthProfileUpdateRequested(
          name: user.name,
          email: user.email,
          avatarUrl: downloadUrl,
        ));
        
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Upload failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About EcoShop'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🌿 EcoShop',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Version 1.0.0'),
              SizedBox(height: 16),
              Text(
                'Our Mission',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Making sustainable shopping accessible to everyone. We believe in a greener future, one purchase at a time.',
              ),
              SizedBox(height: 16),
              Text(
                '🌍 Join us in reducing our carbon footprint and supporting eco-friendly products.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings feature coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = state is AuthAuthenticated ? state.user : null;
          final userName = user?.name ?? 'Alex Green';
          final userEmail = user?.email ?? 'alex@ecoshop.com';
          final userInitials = userName.isNotEmpty ? userName.split(' ').map((n) => n[0]).join('').toUpperCase() : 'U';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              children: [
                // Profile Header
                FadeInWidget(
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.spacingLg),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                              child: ClipOval(
                                child: _isUploading 
                                  ? const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: user.avatarUrl!,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                                        errorWidget: (context, url, error) => Center(
                                          child: Text(
                                            userInitials,
                                            style: textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: Text(
                                          userInitials,
                                          style: textTheme.titleLarge?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: user != null ? () => _pickAndUploadAvatar(context, user.id) : null,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: AppTheme.spacingMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                userEmail,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                ),
                                child: Text(
                                  '🌿 Eco Champion',
                                  style: textTheme.labelSmall?.copyWith(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Colors.white),
                          onPressed: () => context.push('/edit-profile'),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppTheme.spacingLg),

                // Stats Row
                FadeInWidget(
                  delay: const Duration(milliseconds: 100),
                  child: Row(
                    children: [
                      _StatCard(icon: Icons.shopping_bag_outlined, value: '12', label: 'Orders', colorScheme: colorScheme, textTheme: textTheme),
                      const SizedBox(width: AppTheme.spacingMd),
                      _StatCard(icon: Icons.favorite_outline, value: '8', label: 'Wishlist', colorScheme: colorScheme, textTheme: textTheme),
                      const SizedBox(width: AppTheme.spacingMd),
                      _StatCard(icon: Icons.eco_outlined, value: '24kg', label: 'CO₂ Saved', colorScheme: colorScheme, textTheme: textTheme),
                    ],
                  ),
                ),

                const SizedBox(height: AppTheme.spacingLg),

                // Menu Items
                ...[
                  (Icons.shopping_bag_outlined, 'My Orders', 'Track your orders', 200),
                  (Icons.favorite_outline, 'Wishlist', 'Products you love', 250),
                  (Icons.location_on_outlined, 'Addresses', 'Manage delivery addresses', 300),
                  (Icons.payment_outlined, 'Payment Methods', 'Cards and payment options', 350),
                  (Icons.notifications_outlined, 'Notifications', 'Manage your alerts', 400),
                  (Icons.help_outline_rounded, 'Help & Support', 'Get help with your orders', 450),
                  (Icons.dark_mode_outlined, 'Theme Mode', 'Switch between light and dark', 475),
                  (Icons.info_outline_rounded, 'About EcoShop', 'Our mission & values', 500),
                ].map((item) {
                  return FadeInWidget(
                    delay: Duration(milliseconds: item.$4),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          ),
                          child: Icon(item.$1, color: colorScheme.primary, size: 20),
                        ),
                        title: Text(item.$2, style: textTheme.titleSmall),
                        subtitle: Text(item.$3, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                        trailing: Icon(Icons.chevron_right_rounded, color: colorScheme.onSurfaceVariant),
                        onTap: () {
                          switch (item.$2) {
                            case 'Wishlist':
                              context.push('/wishlist');
                              break;
                            case 'My Orders':
                              context.push('/orders');
                              break;
                            case 'Addresses':
                              context.push('/addresses');
                              break;
                            case 'Payment Methods':
                              context.push('/payment-methods');
                              break;
                            case 'Notifications':
                              context.push('/notifications');
                              break;
                            case 'Help & Support':
                              context.push('/help-support');
                              break;
                            case 'Theme Mode':
                              _showThemePicker(context);
                              break;
                            case 'About EcoShop':
                              _showAboutDialog(context);
                              break;
                          }
                        },
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: AppTheme.spacingLg),

                // Logout Button
                FadeInWidget(
                  delay: const Duration(milliseconds: 550),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.read<AuthBloc>().add(AuthLogoutRequested());
                      },
                      icon: Icon(Icons.logout_rounded, color: colorScheme.error),
                      label: Text('Sign Out', style: TextStyle(color: colorScheme.error)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colorScheme.error.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppTheme.spacingXl),

                // Version
                Text('EcoShop v1.0.0', style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                const SizedBox(height: AppTheme.spacingLg),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showThemePicker(BuildContext context) {
    final themeService = sl<ThemeService>();
    showModalBottomSheet(
      context: context,
      builder: (context) => ValueListenableBuilder<ThemeMode>(
        valueListenable: themeService.themeModeNotifier,
        builder: (context, currentMode, _) {
          return Container(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Theme Mode',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppTheme.spacingMd),
                _buildThemeOption(context, 'Light', Icons.light_mode_outlined, ThemeMode.light, currentMode),
                _buildThemeOption(context, 'Dark', Icons.dark_mode_outlined, ThemeMode.dark, currentMode),
                _buildThemeOption(context, 'System Default', Icons.settings_brightness_outlined, ThemeMode.system, currentMode),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, 
    String label, 
    IconData icon, 
    ThemeMode mode, 
    ThemeMode currentMode
  ) {
    final isSelected = currentMode == mode;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon, color: isSelected ? colorScheme.primary : null),
      title: Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : null)),
      trailing: isSelected ? Icon(Icons.check_circle, color: colorScheme.primary) : null,
      onTap: () {
        sl<ThemeService>().setThemeMode(mode);
        Navigator.pop(context);
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: colorScheme.primary, size: 24),
            const SizedBox(height: 8),
            Text(value, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            Text(label, style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
