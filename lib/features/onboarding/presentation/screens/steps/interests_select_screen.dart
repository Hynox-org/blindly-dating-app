import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';
import 'base_onboarding_step_screen.dart';

class InterestsSelectScreen extends ConsumerStatefulWidget {
  const InterestsSelectScreen({super.key});
  @override
  ConsumerState<InterestsSelectScreen> createState() => _InterestsSelectScreenState();
}

class _InterestsSelectScreenState extends ConsumerState<InterestsSelectScreen> {
  final List<String> _selectedInterests = [];
  // Interest categories with their items and icons
  final Map<String, List<Map<String, dynamic>>> _interestCategories = {
    'Self care': [
      {'name': 'Astrology', 'icon': 'assests/images/horoscope.png'},
      {'name': 'Nutrition', 'icon': 'assests/images/bok-choy.png'},
      {'name': 'Fitness', 'icon': 'assestes/images/women.png'},
      {'name': 'Yoga', 'icon': 'assests/images/lotus.png'},
      {'name': 'Therapy', 'icon': 'assests/images/therapy.png'},
      {'name': 'Skin care', 'icon': 'assests/images/skincare.png'},
      {'name': 'Sleeping well', 'icon': 'assests/images/zzz.png'},
    ],
    'Sports': [
      {'name': 'Football', 'icon': 'assests/images/football.png'},
      {'name': 'Tennis', 'icon': 'assests/images/tennis.png'},
      {'name': 'Hockey', 'icon': 'assests/images/ice-hockey.png'},
      {'name': 'Yoga', 'icon': 'assests/images/lotus.png'},
      {'name': 'Cricket', 'icon': 'assests/images/cricket.png'},
      {'name': 'Base ball', 'icon': 'assests/images/game.png'},
      {'name': 'Basket ball', 'icon': 'assests/images/basket.png'},
      {'name': 'Boxing', 'icon': 'assests/images/punching.png'},
    ],
    'Creativity': [
      {'name': 'Art', 'icon': 'assests/images/art.png'},
      {'name': 'Dance', 'icon': 'assests/images/couple.png'},
      {'name': 'Fashion', 'icon': 'assests/images/model.png'},
      {'name': 'Design', 'icon': 'assests/images/graphic-designer.png'},
      {'name': 'Nail art', 'icon': 'assests/images/nail.png'},
      {'name': 'Painting', 'icon': 'assests/images/paint-bucket.png'},
      {'name': 'Photography', 'icon': 'assests/images/photographer.png'},
      {'name': 'Singing', 'icon': 'assests/images/music.png'},
      {'name': 'Makeup', 'icon': 'assests/images/makeup-pouch.png'},
    ],
    'Going Out': [
      {'name': 'Movie', 'icon': 'assests/images/film-slate.png'},
      {'name': 'Club', 'icon': 'assests/images/night-club.png'},
      {'name': 'Bar', 'icon': 'assests/images/beer.png'},
      {'name': 'Cafe', 'icon': 'assests/images/cafe.png'},
      {'name': 'Festival', 'icon': 'assests/images/fireworks.png'},
      {'name': 'Theatre', 'icon': 'assests/images/theater.png'},
      {'name': 'Wine tasting', 'icon': 'assests/images/wine-tasting.png'},
      {'name': 'Museum', 'icon': 'assests/images/canvas.png'},
      {'name': 'LGBTQ', 'icon': 'assests/images/makeup-pounch.png'},
    ],
    'Music': [
      {'name': 'Arabic', 'icon': 'assests/images/music.png'},
      {'name': 'Classical', 'icon': 'assests/images/music.png'},
      {'name': 'Desi', 'icon': 'assests/images/music.png'},
      {'name': 'Latin', 'icon': 'assests/images/music.png'},
      {'name': 'Punjabi', 'icon': 'assests/images/music.png'},
      {'name': 'Rock', 'icon': 'assests/images/music.png'},
      {'name': 'Jazz', 'icon': 'assests/images/music.png'},
      {'name': 'K-pop', 'icon': 'assests/images/music.png'},
      {'name': 'Techno', 'icon': 'assests/images/music.png'},
    ],
    'Food and drink': [
      {'name': 'Beer', 'icon': 'assests/images/cheers.png'},
      {'name': 'Cake', 'icon': 'assests/images/cupcake.png'},
      {'name': 'BBQ', 'icon': 'assests/images/grilled.png'},
      {'name': 'Whiskey', 'icon': 'assests/images/whiskey.png'},
      {'name': 'Briyani', 'icon': 'assests/images/biryani.png'},
      {'name': 'Pasta', 'icon': 'assests/images/spaghetti.png'},
      {'name': 'Coffee', 'icon': 'assests/images/tea.png'},
      {'name': 'KFC', 'icon': 'assests/images/nuggets.png'},
      {'name': 'Cocktail', 'icon': 'assests/images/cocktail.png'},
      {'name': 'Pizza', 'icon': 'assests/images/pizza.png'},
    ],
    'Pets': [
      {'name': 'Birds', 'icon': 'assests/images/bunting.png'},
      {'name': 'Cats', 'icon': 'assests/images/cat.png'},
      {'name': 'Fish', 'icon': 'assests/images/goldfish.png'},
      {'name': 'Dogs', 'icon': 'assests/images/shiba.png'},
      {'name': 'Turtle', 'icon': 'assests/images/turtle.png'},
    ],
    'Traveling': [
      {'name': 'Beaches', 'icon': 'assests/images/beach.png'},
      {'name': 'Hiking trips', 'icon': 'assests/images/hiking.png'},
      {'name': 'Spa', 'icon': 'assests/images/spa.png'},
      {'name': 'Solo trips', 'icon': 'assests/images/travel-bag.png'},
      {'name': 'Winter sports', 'icon': 'assests/images/ski.png'},
      {'name': 'City breaks', 'icon': 'assests/images/smart-city.png'},
    ],
  };

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
  }

  Widget _buildCategorySection(String category, List<Map<String, dynamic>> interests) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0, top: 16.0),
          child: Text(
            category,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: interests.map((interest) {
            final isSelected = _selectedInterests.contains(interest['name']);
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // FIXED: Use Image.asset instead of Text to display images
                  Image.asset(
                    interest['icon'],
                    width: 20,
                    height: 20,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback icon if image not found
                      return Icon(
                        Icons.image_not_supported,
                        size: 20,
                        color: isSelected ? Colors.white : Colors.grey,
                      );
                    },
                  ),
                  const SizedBox(width: 6),
                  Text(
                    interest['name'],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) => _toggleInterest(interest['name']),
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF4A5A3E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF4A5A3E) : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              showCheckmark: false,
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseOnboardingStepScreen(
      title: 'Select Your Interests',
      showBackButton: true,
      onNext: () {
        // Validation: Check if at least 3 interests are selected
        if (_selectedInterests.isEmpty) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red[700],
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'No Interests Selected',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                content: const Text(
                  'Please select at least 3 interests to help us find your perfect matches.',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
          return;
        }

        if (_selectedInterests.length < 5) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange[700],
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'More Interests Needed',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                content: Text(
                  'You have selected ${_selectedInterests.length} interest(s). Please select at least 3 interests to help us find better matches for you.',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
          return;
        }

        // All validations passed - proceed to next step
        ref.read(onboardingProvider.notifier).completeStep('interests_select');
      },
      // showSkipButton: true,
      // onSkip: () {
      //   ref.read(onboardingProvider.notifier).skipStep('interests_select');
      // },
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Helper text
            Text(
              'Please select at least 5 interest. This helps us find you potential matches.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search for interest',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4A5A3E)),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 16),
            // Build all category sections
            ..._interestCategories.entries.map(
              (entry) => _buildCategorySection(entry.key, entry.value),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
