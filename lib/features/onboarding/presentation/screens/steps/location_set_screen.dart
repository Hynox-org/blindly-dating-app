import 'dart:async'; // For debounce
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart'; // To access .env
import 'package:uuid/uuid.dart'; // For session token if needed (not strictly for geocoding, but good practice)

import '../../providers/onboarding_provider.dart';
import '../../../../auth/providers/auth_providers.dart';
import '../../../data/repositories/onboarding_repository.dart';
import 'base_onboarding_step_screen.dart';

class LocationSetScreen extends ConsumerStatefulWidget {
  const LocationSetScreen({super.key});

  @override
  ConsumerState<LocationSetScreen> createState() => _LocationSetScreenState();
}

class _LocationSetScreenState extends ConsumerState<LocationSetScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredCities = [];
  bool _isSaving = false;
  Timer? _debounce;
  final _uuid = const Uuid();
  String? _sessionToken;

  // Static list of ~50 major Indian cities as fallback
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
    _sessionToken = _uuid.v4();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchExistingData());
  }

  Future<void> _fetchExistingData() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user != null) {
      final profile = await ref
          .read(onboardingRepositoryProvider)
          .getProfileRaw(user.id);
      if (profile != null) {
        final city = profile['city'];
        final country = profile['country'];
        // final state = profile['state']; // optional to show
        if (city != null && city.isNotEmpty) {
          final locationStr = "$city, $country";
          _searchController.text = locationStr;
          // If we want it to look "selected", we might populate filtered list with it
          setState(() {
            _filteredCities = [locationStr];
          });
        }
      }
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

    // 1. If no token, use local fallback
    if (mapboxToken == null || mapboxToken.isEmpty) {
      debugPrint('Mapbox token missing, using fallback list.');
      _filterLocal(query);
      return;
    }

    try {
      // 2. Use Mapbox Geocoding API (types=place implies city/municipality level)
      // We restrict to 'place' to get cities.
      // Optionally add '&country=in' if we want to restrict to India. User didn't strictly say only India, but implied.
      // I'll leave it global for now, user can add country=in if they want STRICT India.
      final url = Uri.parse(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/${Uri.encodeComponent(query)}.json?access_token=$mapboxToken&types=place&language=en',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List features = data['features'] as List;

        final List<String> suggestions = features.map((f) {
          // Parse feature to construct "City, State, Country" string
          // Mapbox returns:
          // text: "CityName"
          // place_name: "CityName, State, Country" (usually)
          // We can use place_name directly as it's formatted well usually.
          return f['place_name'] as String;
        }).toList();

        setState(() {
          _filteredCities = suggestions;
        });
      } else {
        debugPrint(
          'Mapbox API failed: ${response.statusCode}, using fallback.',
        );
        _filterLocal(query);
      }
    } catch (e) {
      debugPrint('Mapbox Error: $e, using fallback.');
      _filterLocal(query);
    }
  }

  void _filterLocal(String query) {
    setState(() {
      _filteredCities = _allCitiesCallback
          .where((city) => city.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _handleCitySelection(String locationString) async {
    setState(() => _isSaving = true);

    try {
      // Parse "City, State, Country"
      // Mapbox 'place_name' usually comes as "City, State, Country" or "City, Country"
      final parts = locationString.split(',').map((e) => e.trim()).toList();
      String city = parts.isNotEmpty ? parts[0] : '';

      // Heuristic parsing:
      // If 3 parts: City, State, Country
      // If 2 parts: City, Country (State might be missing or same as city)
      String state = '';
      String country = '';

      if (parts.length >= 3) {
        state = parts[parts.length - 2]; // Second last
        country = parts.last;
      } else if (parts.length == 2) {
        country = parts.last;
        // Leave state empty or maybe 'N/A'
      } else {
        country = parts.isNotEmpty ? parts.last : '';
      }

      final user = ref.read(authRepositoryProvider).currentUser;
      if (user != null) {
        await ref.read(onboardingRepositoryProvider).updateProfileData(
          user.id,
          {'city': city, 'state': state, 'country': country},
        );
      }

      await ref.read(onboardingProvider.notifier).completeStep('location_set');
    } catch (e) {
      debugPrint('Error saving location: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save location: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseOnboardingStepScreen(
      title: 'Find your current city',
      showBackButton: true,
      // We hide the button because selection happens on tap of a list item
      nextLabel: '',
      isNextEnabled: false,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search city',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          const SizedBox(height: 16),
          if (_isSaving)
            const Center(child: CircularProgressIndicator())
          else
            Expanded(
              child: ListView.separated(
                itemCount: _filteredCities.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, color: Colors.grey.shade200),
                itemBuilder: (context, index) {
                  final city = _filteredCities[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      city,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    onTap: () => _handleCitySelection(city),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
