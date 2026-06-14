import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: AppTheme.primaryGreen,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: AppTheme.primaryGreen,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 42,
                            backgroundColor: Colors.white24,
                            backgroundImage: user?.avatarUrl != null
                                ? NetworkImage(user!.avatarUrl!)
                                : null,
                            child: user?.avatarUrl == null
                                ? Text(
                                    AppUtils.firstInitial(user?.name),
                                    style: const TextStyle(
                                        fontSize: 32,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  )
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        user?.name ?? 'User',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  _MenuTile(
                    icon: Icons.person_outline,
                    label: 'Edit Profile',
                    onTap: () => context.push('/home/edit-profile'),
                  ),
                  _MenuTile(
                    icon: Icons.favorite_outline,
                    label: 'My Wishlist',
                    onTap: () => context.push('/home/wishlist'),
                  ),
                  _MenuTile(
                    icon: Icons.receipt_long_outlined,
                    label: 'Order History',
                    onTap: () => context.push('/home/orders'),
                  ),
                  if (user?.isAdmin ?? false)
                    _MenuTile(
                      icon: Icons.admin_panel_settings_outlined,
                      label: 'Admin Portal',
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('ADMIN',
                            style: TextStyle(
                                color: Colors.green.shade800,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                      onTap: () => context.push('/home/admin'),
                    ),
                  _MenuTile(
                    icon: Icons.discount_outlined,
                    label: 'Coupons & Offers',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('NEW',
                          style: TextStyle(
                              color: Colors.orange.shade800,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                    onTap: () => AppUtils.showToast('Coupons coming soon!'),
                  ),
                  _MenuTile(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    onTap: () => AppUtils.showToast('Notifications settings'),
                  ),

                  const Divider(height: 24, indent: 16, endIndent: 16),

                  // Dark mode toggle
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      child: SwitchListTile(
                        secondary: Icon(
                          isDark ? Icons.dark_mode : Icons.light_mode,
                          color: AppTheme.primaryGreen,
                        ),
                        title: const Text('Dark Mode'),
                        value: isDark,
                        onChanged: (_) =>
                            ref.read(themeModeProvider.notifier).toggle(),
                        activeThumbColor: AppTheme.primaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  _MenuTile(
                    icon: Icons.help_outline,
                    label: 'Help & Support',
                    onTap: () => AppUtils.showToast('Support coming soon!'),
                  ),
                  _MenuTile(
                    icon: Icons.privacy_tip_outlined,
                    label: 'Privacy Policy',
                    onTap: () {},
                  ),
                  _MenuTile(
                    icon: Icons.info_outline,
                    label: 'About FreshCart',
                    onTap: () => _showAbout(context),
                  ),

                  const Divider(height: 24, indent: 16, endIndent: 16),

                  // Logout — FIX: use context.go('/login') not Navigator
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Card(
                      child: ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text('Sign Out',
                            style: TextStyle(color: Colors.red)),
                        onTap: () => _confirmLogout(context, ref),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text('FreshCart v1.0.0',
                      style:
                          TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authServiceProvider).signOut();
              // FIX: use GoRouter, not Navigator.pushReplacementNamed
              if (context.mounted) context.go('/login');
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'FreshCart',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.shopping_basket,
          color: AppTheme.primaryGreen, size: 40),
      children: const [
        Text('Your daily grocery companion.\nFresh produce delivered fast.'),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: Card(
        child: ListTile(
          leading: Icon(icon, color: AppTheme.primaryGreen),
          title: Text(label, style: const TextStyle(fontSize: 14)),
          trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
          onTap: onTap,
        ),
      ),
    );
  }
}
