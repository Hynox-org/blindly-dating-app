import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'domain/models/profile_user_model.dart';
import 'provider/profile_provider.dart';
import '../../core/widgets/voice_playback_widget.dart';
import 'package:audioplayers/audioplayers.dart';
import 'presentation/screens/setup_steps/voice_intro_screen.dart';
import '../media/providers/media_provider.dart';
import '../../core/providers/connection_mode_provider.dart';
import 'profile_looking_for_screen.dart'; // Added looking for screen import
import '../onboarding/presentation/screens/steps/photo_upload_screen.dart';
import 'presentation/screens/setup_steps/profile_prompts_screen.dart';
import 'presentation/screens/causes_communities_screen.dart';
import 'presentation/screens/qualities_selection_screen.dart';
import '../onboarding/presentation/screens/steps/gender_select_screen.dart';

import 'presentation/screens/setup_steps/interests_select_screen.dart';
import 'presentation/screens/setup_steps/bio_entry_screen.dart';
import 'presentation/screens/setup_steps/lifestyle_prefs_screen.dart';
import '../onboarding/domain/models/lifestyle_chip_model.dart';
import 'presentation/screens/educated_at_screen.dart';
import 'presentation/screens/hometown_screen.dart';
import '../onboarding/domain/models/profile_prompt_model.dart';
import 'presentation/screens/pronouns_screen.dart';
import 'presentation/screens/profession_screen.dart';
import 'presentation/screens/height_screen.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'presentation/screens/exercise_screen.dart';
import 'presentation/screens/education_level_screen.dart';
import 'presentation/screens/drinking_screen.dart';
import 'presentation/screens/smoking_screen.dart';
import 'presentation/screens/kids_preference_screen.dart';
import 'presentation/screens/have_kids_screen.dart';
import 'presentation/screens/political_view_screen.dart';
import 'presentation/screens/relationship_type_screen.dart';
import 'presentation/screens/sexual_orientation_screen.dart';
import 'presentation/screens/language_selection_screen.dart';
import 'presentation/screens/religion_screen.dart';
import 'presentation/screens/zodiac_screen.dart';
import '../../core/widgets/app_loader.dart';

// ============================================================
// PROFILE EDIT SCREEN (Complete Redesign)
// ============================================================

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final Set<int> _expandedPromptIndices = {};
  late final AudioPlayer _audioPlayer;
  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) => _buildBody(profile),
        loading: () => const Center(child: AppLoader()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildBody(ProfileUser profile) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildProfileStrength(profile),
          const SizedBox(height: 16),
          _buildPhotosSection(profile),
          const SizedBox(height: 16),
          _buildVoiceIntroSection(profile),
          const SizedBox(height: 16),
          _buildInterestsSection(profile),
          const SizedBox(height: 16),
          _buildLifestyleSection(profile),
          const SizedBox(height: 16),
          _buildCausesAndCommunitiesSection(profile),
          const SizedBox(height: 16),
          _buildQualitiesSection(profile),
          const SizedBox(height: 16),
          _buildLookingForSection(profile),
          const SizedBox(height: 16),
          _buildPromptsSection(profile),
          const SizedBox(height: 16),
          _buildBioSection(profile),
          const SizedBox(height: 16),
          _buildAboutYouSection(profile),
          const SizedBox(height: 16),
          _buildMoreAboutYouSection(profile),
          const SizedBox(height: 16),
          _buildPronounsSection(profile),
          const SizedBox(height: 16),
          _buildLanguagesSection(profile),
          const SizedBox(height: 16),
          _buildConnectedAccountsSection(profile),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCausesAndCommunitiesSection(ProfileUser profile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My causes and communities',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Add up to 3 causes close to your heart.',
            style: TextStyle(fontSize: 12, color: Colors.black),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const CausesCommunitiesScreen(isEditMode: true),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: profile.causesCommunities.isEmpty
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Add your causes and communities',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.black,
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: profile.causesCommunities.map((cause) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Text(
                                  cause,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.black,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualitiesSection(ProfileUser profile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Qualities i value',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Choose up to 3 qualities you value in a person',
            style: TextStyle(fontSize: 12, color: Colors.black),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const QualitiesSelectionScreen(isEditMode: true),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5), // Light grey bg as per design
                borderRadius: BorderRadius.circular(16),
              ),
              child: profile.qualities.isEmpty
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Add qualities you value',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.black,
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: profile.qualities.map((quality) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8D595), // Gold/Yellow
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  quality,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.black,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLookingForSection(ProfileUser profile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'I am looking for',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Let others know what you want to find',
            style: TextStyle(fontSize: 12, color: Colors.black),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const ProfileLookingForScreen(isEditMode: true),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: profile.lookingForModes.isEmpty
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Add what you are looking for',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.black,
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: profile.lookingForModes.map((option) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Text(
                                  option,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.black,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptsSection(ProfileUser profile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Prompts',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Let people know what it\'s like to date you.',
            style: TextStyle(fontSize: 12, color: Colors.black),
          ),
          const SizedBox(height: 16),
          // List of Prompt Cards
          if (profile.prompts.isNotEmpty)
            ...profile.prompts.asMap().entries.map((entry) {
              return _buildSinglePromptCard(entry.value, entry.key);
            }),

          // Placeholder "Add Prompt" card if < 3
          if (profile.prompts.length < 3)
            GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const ProfilePromptsScreen(isEditMode: true),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Add a prompt',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSinglePromptCard(ProfilePrompt prompt, int index) {
    final response = prompt.userResponse;
    final isLong = response.length > 100; // Heuristic for "Big" prompt
    final isExpanded = _expandedPromptIndices.contains(index);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePromptsScreen(
                    isEditMode: true,
                    initialTemplateId: prompt.promptTemplateId,
                  ),
                ),
              );
            },
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    prompt.promptQuestion ?? 'Prompt',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.black,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePromptsScreen(
                    isEditMode: true,
                    initialTemplateId: prompt.promptTemplateId,
                  ),
                ),
              );
            },
            child: Text(
              '"$response"',
              style: const TextStyle(fontSize: 13, color: Colors.black),
              maxLines: isExpanded ? null : 3,
              overflow: isExpanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
            ),
          ),
          if (isLong) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  if (isExpanded) {
                    _expandedPromptIndices.remove(index);
                  } else {
                    _expandedPromptIndices.add(index);
                  }
                });
              },
              child: Center(
                child: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPronounsSection(ProfileUser profile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pronouns',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pick your pronouns',
            style: TextStyle(fontSize: 12, color: Colors.black),
          ),
          const SizedBox(height: 16),
          _buildGenericAddRow(
            title: profile.pronouns != null && profile.pronouns!.isNotEmpty
                ? _formatPronouns(profile.pronouns!)
                : 'Add your pronouns',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PronounsScreen(isEditMode: true),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedAccountsSection(ProfileUser profile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Connected accounts',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Show your favorite music',
            style: TextStyle(fontSize: 12, color: Colors.black),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.music_note,
                      color: Colors.green,
                      size: 24,
                    ), // Placeholder for Spotify Icon
                    const SizedBox(width: 8),
                    const Text(
                      'Connect my spotify',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Show your top spotify artists on your profile and allow blindly to highlight who have in common with others.',
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                // Placeholder circles for artists
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    5,
                    (index) => Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStrength(ProfileUser profile) {
    final percent = (profile.completionPercentage * 100).toInt();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile strength',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$percent% complete',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceIntroSection(ProfileUser profile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Voice Intro',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Let people hear your voice.',
            style: TextStyle(fontSize: 12, color: Colors.black),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: profile.voiceIntroUrl == null
                ? GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VoiceIntroScreen(isEditMode: true),
                      ),
                    );
                    await ref.refresh(currentUserProfileProvider);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Add a voice intro',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Icon(
                        Icons.add_circle_outline,
                        size: 20,
                        color: Colors.black,
                      ),
                    ],
                  ),
                )
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: VoicePlaybackWidget(
                            url: profile.voiceIntroUrl!,
                            durationSeconds: profile.voiceIntroDuration,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Voice Intro?'),
                                content: const Text('This will remove your voice intro from your profile.'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                ],
                              ),
                            );
                            
                            if (confirm == true) {
                              final repo = ref.read(mediaRepositoryProvider);
                              final mode = ref.read(connectionModeProvider);
                              final modeId = mode == 'date' ? profile.dateModeId : profile.bffModeId;
                              
                              if (modeId != null) {
                                await repo.deleteUserVoiceIntro(modeId);
                                // ignore: unused_result
            // ignore: unused_result
                    ref.refresh(currentUserProfileProvider);
                              }
                            }
                          },
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    TextButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VoiceIntroScreen(isEditMode: true),
                          ),
                        );
    // ignore: unused_result
                    ref.refresh(currentUserProfileProvider);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Re-record intro'),
                    ),
                  ],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosSection(ProfileUser profile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Photos and videos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pick some that show the true you.',
            style: TextStyle(fontSize: 12, color: Colors.black),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: List.generate(6, (index) {
              if (index < profile.imageUrls.length) {
                return GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const PhotoUploadScreen(isEditMode: true),
                      ),
                    );
// ignore: unused_result
                    ref.refresh(currentUserProfileProvider);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(profile.imageUrls[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              }
              return GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const PhotoUploadScreen(isEditMode: true),
                    ),
                  );
                  await ref.refresh(currentUserProfileProvider);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, size: 32, color: Colors.grey),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          const Text(
            'Hold and drag media to reorder',
            style: TextStyle(fontSize: 11, color: Colors.black),
          ),
          const SizedBox(height: 16),
          // Best photo row in white bg
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Icon(
                  Icons.verified, // blue tick
                  size: 20,
                  color: Colors.blue,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Best photo',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text('On', style: TextStyle(fontSize: 13, color: Colors.black)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Verification row in white bg
          GestureDetector(
            onTap: () {
              // Only navigate if NOT fully verified
              if (!(profile.isVerified &&
                  profile.verificationLevel == 'full_verified')) {
                // TODO: Navigate to Verification Screen
                // Navigator.push(context, MaterialPageRoute(builder: (context) => const GovernmentIdVerificationScreen()));
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.verified_user,
                    size: 20,
                    color:
                        (profile.isVerified &&
                            profile.verificationLevel == 'full_verified')
                        ? Colors.blue
                        : Colors.black,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Verification',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    (profile.isVerified &&
                            profile.verificationLevel == 'full_verified')
                        ? 'Verified'
                        : 'Not Verified',
                    style: TextStyle(
                      fontSize: 13,
                      color:
                          (profile.isVerified &&
                              profile.verificationLevel == 'full_verified')
                          ? Colors.blue
                          : Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!(profile.isVerified &&
                      profile.verificationLevel == 'full_verified'))
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.black,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLifestyleSection(ProfileUser profile) {
    // Group chips by category
    final Map<String, List<LifestyleChip>> groupedItems = {};
    for (var item in profile.lifestyleItems) {
      final key = item.categoryKey ?? item.categoryName ?? 'Other';
      if (!groupedItems.containsKey(key)) {
        groupedItems[key] = [];
      }
      groupedItems[key]!.add(item);
    }

    // Icon map
    IconData getIconForCategory(String? key) {
      if (key == null) return Icons.star_outline;
      switch (key.toLowerCase()) {
        case 'drinking':
          return Icons.local_bar;
        case 'smoking':
          return Icons.smoking_rooms;
        case 'workout':
        case 'exercise':
          return Icons.fitness_center;
        case 'food':
        case 'diet':
          return Icons.restaurant;
        case 'social':
        case 'social_media':
          return Icons.alternate_email;
        case 'sleep':
        case 'sleeping_habits':
          return Icons.bedtime;
        case 'pets':
          return Icons.pets;
        case 'zodiac':
          return Icons.nightlight_round;
        case 'education':
          return Icons.school_outlined;
        case 'kids':
          return Icons.child_care;
        case 'religion':
          return Icons.church;
        case 'politics':
          return Icons.account_balance;
        default:
          return Icons.star_outline;
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lifestyle',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your habits and preferences.',
            style: TextStyle(fontSize: 12, color: Colors.black),
          ),
          const SizedBox(height: 16),
          if (profile.lifestyleItems.isEmpty)
            _buildGenericAddRow(
              title: 'Add your lifestyle preferences',
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const LifestylePrefsScreen(isEditMode: true),
                  ),
                );
                // Removed immediate refresh to allow optimistic update to persist
              },
            )
          else
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ...groupedItems.entries.map((entry) {
                    final key = entry.key;
                    final items = entry.value;
                    final categoryName = items.first.categoryName ?? key;
                    final icon = getIconForCategory(
                      items.first.categoryKey ?? key,
                    );
                    final valueText = items.map((e) => e.label).join(', ');

                    return _buildListTile(
                      icon,
                      categoryName,
                      valueText,
                      true,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const LifestylePrefsScreen(isEditMode: true),
                          ),
                        );
                        // Removed immediate refresh
                      },
                    );
                  }),
                  // Add generic "Edit" row at bottom or allow tapping any row to edit all?
                  // Tapping any row goes to the full screen.
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInterestsSection(ProfileUser profile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Interests',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Get specific about the things you love.',
            style: TextStyle(fontSize: 12, color: Colors.black),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5), // Light grey background
              borderRadius: BorderRadius.circular(16),
            ),
            child: profile.interests.isEmpty
                ? GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const InterestsSelectScreen(isEditMode: true),
                        ),
                      );
  // ignore: unused_result
                    ref.refresh(currentUserProfileProvider);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Add your favorite interests',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Icon(Icons.add, color: Colors.black, size: 20),
                      ],
                    ),
                  )
                : GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const InterestsSelectScreen(isEditMode: true),
                        ),
                      );
  // ignore: unused_result
                    ref.refresh(currentUserProfileProvider);
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 8, // Reduced spacing
                            runSpacing: 8,
                            children: profile.interests.map((interest) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8, // Slightly more vertical padding
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    8,
                                  ), // Rectangular with slight round
                                ),
                                child: Text(
                                  interest,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioSection(ProfileUser profile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bio',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Write a fun intro.',
            style: TextStyle(fontSize: 12, color: Colors.black),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BioEntryScreen(
                    isEditMode: true,
                    initialBio: profile.bio, // Pass existing bio
                  ),
                ),
              );
              await ref.refresh(currentUserProfileProvider);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              constraints: const BoxConstraints(
                minHeight: 100,
              ), // Fixed height removed to allow dynamic expansion
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                profile.bio.isNotEmpty ? profile.bio : 'About you...',
                style: TextStyle(
                  color: profile.bio.isNotEmpty ? Colors.black : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutYouSection(ProfileUser profile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About you',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          // _buildListTile(
          //   Icons.cake_outlined,
          //   'Age',
          //   '${profile.age}',
          //   true,
          //   onTap: () async {
          //     await Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) =>
          //             const NameBirthEntryScreen(isEditMode: true),
          //       ),
          //     );
          //     ref.refresh(currentUserProfileProvider);
          //   },
          // ),
          _buildListTile(
            Icons.work_outline,
            'Work',
            profile.workTitle ?? 'Designer', // Placeholder default as per image
            true,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const ProfessionScreen(isEditMode: true),
                ),
              );
              ref.refresh(currentUserProfileProvider);
            },
          ),
          _buildListTile(
            Icons.school_outlined,
            'Educated at',
            [
                  if (profile.educatedAt != null &&
                      profile.educatedAt!.isNotEmpty)
                    profile.educatedAt!,
                  if (profile.graduationYear != null)
                    profile.graduationYear!.toString(),
                ].join(', ').isEmpty
                ? 'Add'
                : [
                    if (profile.educatedAt != null &&
                        profile.educatedAt!.isNotEmpty)
                      profile.educatedAt!,
                    if (profile.graduationYear != null)
                      profile.graduationYear!.toString(),
                  ].join(', '),
            true,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const EducatedAtScreen(isEditMode: true),
                ),
              );
              // ignore: unused_result
              ref.refresh(currentUserProfileProvider);
            },
          ),
          _buildListTile(
            Icons.person_outline,
            'Gender',
            profile.gender,
            true,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const GenderSelectScreen(isEditMode: true),
                ),
              );
              ref.refresh(currentUserProfileProvider);
            },
          ),
          // Location Tile with Reverse Geocoding
          if (profile.passportLocationGeom != null)
            FutureBuilder<String>(
              future: _resolveDistrictFromGeom(profile.passportLocationGeom!),
              builder: (context, snapshot) {
                final locationText = snapshot.hasData
                    ? snapshot.data!
                    : (profile.city.isNotEmpty ? profile.city : 'Loading...');

                return _buildListTile(
                  Icons.location_on_outlined,
                  'Location',
                  locationText, // Display resolved District
                  false, // Disable arrow if we don't want them editing this manually?
                  // User said "current location will check latitude and longitude".
                  // Usually this implies READ ONLY or "Refresh".
                  // For now, I'll keep it read-only or just show it.
                  // If user wants to EDIT, they might expect to pick a city manually.
                  // But the requirement says "display he is at which district".
                  // I'll disable the arrow for now as it's auto-detected.
                  onTap: () {
                    // specific tap action if needed, e.g. refresh
                  },
                );
              },
            )
          else
            _buildListTile(
              Icons.location_on_outlined,
              'Location',
              profile.city.isNotEmpty ? profile.city : 'Nearby',
              false,
              onTap: () {},
            ),
          _buildListTile(
            Icons.home_outlined,
            'Hometown',
            profile.hometown ?? 'Add',
            true,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HometownScreen()),
              );
              // ignore: unused_result
              ref.refresh(currentUserProfileProvider);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMoreAboutYouSection(ProfileUser profile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'More about you',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          _buildListTile(
            Icons.height,
            'Height',
            profile.height != null ? '${profile.height} cm' : 'Add',
            true,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HeightScreen(isEditMode: true),
                ),
              );
              ref.refresh(currentUserProfileProvider);
            },
          ),
          _buildListTile(
            Icons.fitness_center,
            'Exercise',
            profile.exercise ?? 'Add',
            true,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExerciseScreen(isEditMode: true),
                ),
              );
              ref.refresh(currentUserProfileProvider);
            },
          ),
          _buildListTile(
            Icons.school_outlined,
            'Education level',
            profile.educationLevel ?? 'Add',
            true,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const EducationLevelScreen(isEditMode: true),
                ),
              );
              ref.refresh(currentUserProfileProvider);
            },
          ),
          _buildListTile(
            Icons.local_bar,
            'Drinking',
            profile.drinking ?? 'Add',
            true,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DrinkingScreen(isEditMode: true),
                ),
              );
              ref.refresh(currentUserProfileProvider);
            },
          ),
          _buildListTile(
            Icons.smoking_rooms,
            'Smoking',
            profile.smoking ?? 'Add',
            true,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SmokingScreen(isEditMode: true),
                ),
              );
              ref.refresh(currentUserProfileProvider);
            },
          ),
          _buildListTile(
            Icons.baby_changing_station,
            'Have kids',
            profile.haveKids == null
                ? 'Add'
                : (profile.haveKids! ? 'Yes' : 'No'),
            true,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HaveKidsScreen(isEditMode: true),
                ),
              );
              ref.refresh(currentUserProfileProvider);
            },
          ),
          _buildListTile(
            Icons.child_care,
            'Kids', // Keep label simple or 'Kids Preference' as per design
            profile.kidsPreference ?? 'Add',
            true,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const KidsPreferenceScreen(isEditMode: true),
                ),
              );
              ref.refresh(currentUserProfileProvider);
            },
          ),

          _buildListTile(
            Icons.nightlight_round,
            'Zodiac',
            profile.zodiac ?? 'Taurus',
            true,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ZodiacScreen(isEditMode: true),
                ),
              );
              ref.refresh(currentUserProfileProvider);
            },
          ),
          _buildListTile(
            Icons.account_balance,
            'Politics',
            profile.politics ?? 'Add',
            true,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const PoliticalViewScreen(isEditMode: true),
                ),
              );
              ref.refresh(currentUserProfileProvider);
            },
          ),
          _buildListTile(
            Icons.favorite_border,
            'Relationship Type',
            profile.relationshipType ?? 'Add',
            true,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const RelationshipTypeScreen(isEditMode: true),
                ),
              );
              ref.refresh(currentUserProfileProvider);
            },
          ),
          _buildListTile(
            Icons.transgender, // Or another suitable icon
            'Sexual Orientation',
            profile.sexualOrientation ?? 'Add',
            true,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const SexualOrientationScreen(isEditMode: true),
                ),
              );
              ref.refresh(currentUserProfileProvider);
            },
          ),
          _buildListTile(
            Icons.self_improvement, // Updated icon to match
            'Religion',
            profile.religion ?? 'Hindu',
            true,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReligionScreen(isEditMode: true),
                ),
              );
              ref.refresh(currentUserProfileProvider);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagesSection(ProfileUser profile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Languages',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const LanguageSelectionScreen(isEditMode: true),
                ),
              );
              ref.refresh(currentUserProfileProvider);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: profile.languages.isEmpty
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Add Languages you know', // Updated text
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color:
                                Colors.black, // Or Colors.grey if placeholder
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.black,
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: profile.languages.map((lang) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.translate,
                                      size: 14,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      lang,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.black,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenericAddRow({
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
          ],
        ),
      ),
    );
  }

  Future<String> _resolveDistrictFromGeom(String ewkbHex) async {
    try {
      if (ewkbHex.length < 50) return "Invalid Location";
      final hex = ewkbHex;
      double hexToDouble(String hexString) {
        var bytes = <int>[];
        for (var i = 0; i < hexString.length; i += 2) {
          var byte = int.parse(hexString.substring(i, i + 2), radix: 16);
          bytes.add(byte);
        }
        var byteData = ByteData.sublistView(Uint8List.fromList(bytes));
        return byteData.getFloat64(0, Endian.little);
      }

      final xHex = hex.substring(18, 34);
      final yHex = hex.substring(34, 50);
      final lng = hexToDouble(xHex);
      final lat = hexToDouble(yHex);

      final mapboxToken = dotenv.env['MAPBOX_ACCESS_TOKEN'];
      if (mapboxToken == null) return "Location Found";

      final url = Uri.parse(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$lng,$lat.json?access_token=$mapboxToken&types=district,place&limit=1',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List;
        if (features.isNotEmpty) {
          return features[0]['text'] as String;
        }
      }
      return "Nearby";
    } catch (e) {
      return "Error";
    }
  }

  Widget _buildListTile(
    IconData icon,
    String title,
    String trailing,
    bool showArrow, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.black),
            const SizedBox(width: 12),
            SizedBox(
              width: 100,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              child: Text(
                trailing,
                textAlign: TextAlign.end,
                style: const TextStyle(fontSize: 14, color: Colors.black),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showArrow) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.black,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatPronouns(String pronouns) {
    if (pronouns.isEmpty) return '';
    // Replace underscores with slashes
    final formatted = pronouns.replaceAll('_', '/');
    // Capitalize first letter (optional, but good for UI)
    if (formatted.isNotEmpty) {
      return formatted[0].toUpperCase() + formatted.substring(1);
    }
    return formatted;
  }
}
