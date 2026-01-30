import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/providers/auth_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors
          .white, // User rule: "For backgrounds always use the white" - checking if this applies to scaffold or just containers. Usually scaffold.
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Connections'),
              _buildSectionContainer(
                children: [
                  _buildSettingsTile(
                    icon: Icons
                        .hub_outlined, // Placeholder for "Type of connection" icon
                    title: 'Type of connection',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Icons.favorite_border,
                    title: 'Date mode',
                    trailing: Switch(
                      value: true,
                      onChanged: (val) {},
                      activeColor: const Color(
                        0xFFE9C46A,
                      ), // Match the goldish color in image
                    ),
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Icons.airplanemode_active,
                    title: 'Travel',
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _buildSectionHeader('Account Settings'),
              _buildSectionContainer(
                children: [
                  _buildSettingsTile(
                    icon: Icons.person_outline,
                    title: 'Profile & Verification',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Icons
                        .contact_mail_outlined, // Placeholder for Contact/Login
                    title: 'Contact & Login info',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Icons.stars_outlined, // Placeholder for Subscription
                    title: 'Subscription Management',
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _buildSectionHeader('App Preference'),
              _buildSectionContainer(
                children: [
                  _buildSettingsTile(
                    icon: Icons.notifications_none,
                    title: 'Notifications setting',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy controls',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Icons.translate,
                    title: 'Language',
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _buildSectionHeader('Security & Privacy'),
              _buildSectionContainer(
                children: [
                  _buildSettingsTile(
                    icon: Icons.security,
                    title: 'Account Management',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Icons.block,
                    title: 'Blocked accounts',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Icons.location_on_outlined,
                    title: 'Location service',
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _buildSectionHeader('Support & Legal'),
              _buildSectionContainer(
                children: [
                  _buildSettingsTile(
                    icon: Icons.help_outline,
                    title: 'Help center',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Icons.description_outlined,
                    title: 'Privacy policy',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Icons.article_outlined,
                    title: 'Terms & Conditions',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Icons.info_outline,
                    title: 'About',
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 32),
              _buildLogoutButton(context, ref),
              const SizedBox(height: 16),
              _buildDeleteAccountButton(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildSectionContainer({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5), // Light grey background for sections
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Color(0xFF4A4A3A), // Dark olive green matching icons in image
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: const Color(0xFFE9C46A),
          size: 20,
        ), // Gold icon color
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      trailing:
          trailing ??
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 60,
      endIndent: 16,
      color: Colors.grey,
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          // Implement logout
          await ref.read(authRepositoryProvider).signOut();
          // Assuming the auth state listener will handle navigation to login screen
          // But we might need to pop everything if the listener doesn't automatically redirect
          // In many Riverpod setups, the router watches the auth state.
          // If not, we might need to navigate manually.
          // For now, let's assume the root widget catches the auth state change.
        },
        icon: const Icon(Icons.logout, color: Colors.white),
        label: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // UI only as requested
        },
        icon: const Icon(Icons.delete_outline, color: Colors.white),
        label: const Text(
          'Delete account',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD30000), // Red color
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
