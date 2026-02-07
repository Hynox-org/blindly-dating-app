import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_loader.dart';
import '../../events/screens/events_home_screen.dart';
import 'home_screen.dart';

import '../../../core/providers/connection_mode_provider.dart';

class ConnectionTypeScreen extends ConsumerStatefulWidget {
  final String? initialMode;

  const ConnectionTypeScreen({super.key, this.initialMode});

  @override
  ConsumerState<ConnectionTypeScreen> createState() =>
      _ConnectionTypeScreenState();
}

class _ConnectionTypeScreenState extends ConsumerState<ConnectionTypeScreen> {
  late String _selectedMode;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.initialMode ?? 'Date';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Types of Connections',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'What type of connection are you looking for on Blindly?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dates and romances, new friends, or strictly business? You can change this any time.',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildOptionCard(
                      title: 'Date',
                      subtitle:
                          'Find a relationship, something casual, or anything in-between',
                      mode: 'Date',
                    ),
                    const SizedBox(height: 16),
                    _buildOptionCard(
                      title: 'BFF',
                      subtitle: 'Make new friends and find your community',
                      mode: 'BFF',
                    ),
                    const SizedBox(height: 16),
                    _buildOptionCard(
                      title: 'Events',
                      subtitle: 'Find exciting events, book tickets, and more',
                      mode: 'Events',
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? AppLoader(
                          color: theme.colorScheme.onPrimary,
                          size: 24,
                          strokeWidth: 2,
                        )
                      : Text(
                          'Continue with $_selectedMode',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onContinue() async {
    setState(() => _isSaving = true);

    try {
      // ✅ Update the provider state so other screens know
      ref.read(connectionModeProvider.notifier).setMode(_selectedMode);

      if (_selectedMode == 'Events') {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const EventsHomeScreen()),
            (route) => false,
          );
        }
      } else {
        // Mode is already updated via connectionModeProvider
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Failed to update discovery mode: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required String mode,
  }) {
    final isSelected = _selectedMode == mode;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => setState(() => _selectedMode = mode),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.secondary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(subtitle, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
