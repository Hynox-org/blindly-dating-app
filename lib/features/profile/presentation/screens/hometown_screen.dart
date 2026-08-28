import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:blindly_dating_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:blindly_dating_app/features/auth/providers/auth_providers.dart';
import 'package:blindly_dating_app/features/onboarding/data/repositories/onboarding_repository.dart';
import 'package:blindly_dating_app/features/profile/provider/profile_provider.dart';
import 'package:blindly_dating_app/core/widgets/app_loader.dart';

class HometownScreen extends ConsumerStatefulWidget {
  final bool isEditMode;

  const HometownScreen({super.key, this.isEditMode = true});

  @override
  ConsumerState<HometownScreen> createState() => _HometownScreenState();
}

class _HometownScreenState extends ConsumerState<HometownScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context);


  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredCities = [];
  bool _isSaving = false;
  Timer? _debounce;

  // Static list of major Indian cities as fallback
  final List<String> _allCitiesCallback = [
    "New Delhi, DL, India",
    "Mumbai, MH, India",
    "Bengaluru, KA, India",
    "Chennai, TN, India",
    "Kolkata, WB, India",
    "Hyderabad, TG, India",
    "Ahmedabad, GJ, India",
    "Pune, MH, India",
    "Surat, GJ, India",
    "Jaipur, RJ, India",
    "Lucknow, UP, India",
    "Kanpur, UP, India",
    "Nagpur, MH, India",
    "Indore, MP, India",
    "Thane, MH, India",
    "Bhopal, MP, India",
    "Visakhapatnam, AP, India",
    "Pimpri-Chinchwad, MH, India",
    "Patna, BR, India",
    "Vadodara, GJ, India",
    "Ghaziabad, UP, India",
    "Ludhiana, PB, India",
    "Agra, UP, India",
    "Nashik, MH, India",
    "Faridabad, HR, India",
    "Meerut, UP, India",
    "Rajkot, GJ, India",
    "Kalyan-Dombivli, MH, India",
    "Vasai-Virar, MH, India",
    "Varanasi, UP, India",
    "Srinagar, JK, India",
    "Aurangabad, MH, India",
    "Dhanbad, JH, India",
    "Amritsar, PB, India",
    "Navi Mumbai, MH, India",
    "Allahabad, UP, India",
    "Ranchi, JH, India",
    "Howrah, WB, India",
    "Coimbatore, TN, India",
    "Jabalpur, MP, India",
    "Gwalior, MP, India",
    "Vijayawada, AP, India",
    "Jodhpur, RJ, India",
    "Madurai, TN, India",
    "Raipur, CG, India",
    "Kota, RJ, India",
    "Guwahati, AS, India",
    "Chandigarh, CH, India",
    "Solapur, MH, India",
    "Hubli-Dharwad, KA, India",
    "Mysore, KA, India",
    "Gurugram, HR, India",
    "Noida, UP, India",
    "Kochi, KL, India",
  ];

  @override
  void initState() {
    super.initState();
    _filteredCities = _allCitiesCallback;
    _searchController.addListener(_onSearchChanged);
    _loadCurrentHometown();
  }

  void _loadCurrentHometown() {
    final profile = ref.read(currentUserProfileProvider).value;
    if (profile != null &&
        profile.hometown != null &&
        profile.hometown!.isNotEmpty) {
      _searchController.text = profile.hometown!;
      // Optionally filter list to show current
      _filteredCities = [profile.hometown!];
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      if (query.isEmpty) {
        setState(() => _filteredCities = _allCitiesCallback);
        return;
      }

      _fetchCities(query);
    });
  }

  Future<void> _fetchCities(String query) async {
    final mapboxToken = dotenv.env['MAPBOX_ACCESS_TOKEN'];

    if (mapboxToken == null || mapboxToken.isEmpty) {
      _filterLocal(query);
      return;
    }

    try {
      final url = Uri.parse(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/${Uri.encodeComponent(query)}.json?access_token=$mapboxToken&types=place&language=en',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List features = data['features'] as List;

        final List<String> suggestions = features.map((f) {
          return f['place_name'] as String;
        }).toList();

        if (mounted) {
          setState(() {
            _filteredCities = suggestions;
          });
        }
      } else {
        _filterLocal(query);
      }
    } catch (e) {
      _filterLocal(query);
    }
  }

  void _filterLocal(String query) {
    if (!mounted) return;
    setState(() {
      _filteredCities = _allCitiesCallback
          .where((city) => city.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _handleSave(String city) async {
    setState(() => _isSaving = true);

    try {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user != null) {
        // Refine: "City, State, Country" -> "City, State"
        // Logic: Take first 2 parts if > 2 parts.
        final parts = city.split(',').map((e) => e.trim()).toList();
        String refinedCity = city;
        if (parts.length > 2) {
          refinedCity = "${parts[0]}, ${parts[1]}";
        } else if (parts.length == 2) {
          // If "City, Country" or "Region, City" (unlikely from Mapbox which is usually specific)
          // Check if 2nd part contains "India" maybe?
          // User wants "City, State". If only 2 parts, keep both usually or just first.
          // Mapbox often gives "City, Postcode" or "City, Country".
          // Let's stick strictly to: If 3 or more, take first 2. If 2, keep as is unless 2nd is country?
          // Safest: Just keep first 2 parts always if >= 2.
          refinedCity = "${parts[0]}, ${parts[1]}";
        }

        await ref.read(onboardingRepositoryProvider).updateProfileData(
          user.id,
          {'hometown_city': refinedCity},
        );

        if (mounted) {
          final currentProfile = ref.read(currentUserProfileProvider).value;
          if (currentProfile != null) {
            final updatedProfile = currentProfile.copyWith(
              hometown: refinedCity,
            );
            ref
                .read(currentUserProfileProvider.notifier)
                .updateProfile(updatedProfile);

            // Trigger trust calculation
            await ref
                .read(currentUserProfileProvider.notifier)
                .triggerTrustCalculation();
          }
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorSavingHometown('$e'))));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF4A503D);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Hometown',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Skip',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchCity,
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
            const SizedBox(height: 16),
            if (_isSaving)
              const Center(child: AppLoader())
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _filteredCities.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.12),
                  ),
                  itemBuilder: (context, index) {
                    final city = _filteredCities[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        city,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.87),
                        ),
                      ),
                      onTap: () {
                        _searchController.text = city; // Update text logic
                        // We don't save immediately on tap, user should tap "Save" button usually?
                        // Screenshot shows "Save" button at bottom.
                        // But LocationSetScreen saves on tap.
                        // User provided Screenshot shows "Save" button.
                        // So I should UPDATE SELECTION and enable Save button?
                        // Or just populate text and let user click Save.
                        // I will populate text and let user click Save at bottom.
                      },
                    );
                  },
                ),
              ),

            // Save Button
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving
                    ? null
                    : () => _handleSave(_searchController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const AppLoader(color: Colors.white)
                    : const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
