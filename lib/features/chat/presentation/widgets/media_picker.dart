import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';

class MediaPicker extends StatefulWidget {
  final Function(String url, String previewUrl, int width, int height, String type) onSelect;

  const MediaPicker({super.key, required this.onSelect});

  @override
  State<MediaPicker> createState() => _MediaPickerState();
}

class _MediaPickerState extends State<MediaPicker> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _gifs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchTrendingGifs();
  }

  Future<void> _fetchTrendingGifs() async {
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'giphy-proxy',
        queryParameters: {'type': 'trending', 'limit': '20'},
      );
      
      if (response.data != null) {
        setState(() {
          _gifs = response.data['data'] ?? [];
        });
      }
    } catch (e) {
      debugPrint('Error fetching trending GIFs: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchGifs(String query) async {
    if (query.isEmpty) {
      _fetchTrendingGifs();
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'giphy-proxy',
        queryParameters: {'type': 'search', 'q': query, 'limit': '20'},
      );
      
      if (response.data != null) {
        setState(() {
          _gifs = response.data['data'] ?? [];
        });
      }
    } catch (e) {
      debugPrint('Error searching GIFs: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Material( // Added material for list clicks and ripples
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'GIFs'),
                Tab(text: 'Stickers'),
              ],
              labelColor: Colors.black,
              indicatorColor: const Color(0xFF3F472E),
            ),
            Flexible(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGifGrid(),
                    _buildStickerGrid(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGifGrid() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search GIPHY',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            onSubmitted: _searchGifs,
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _gifs.length,
                  itemBuilder: (context, index) {
                    final gif = _gifs[index];
                    final previewUrl = gif['images']['fixed_width_small_still']['url'];
                    final url = gif['images']['fixed_width']['url'];
                    final width = int.parse(gif['images']['fixed_width']['width']);
                    final height = int.parse(gif['images']['fixed_width']['height']);

                    return GestureDetector(
                      onTap: () => widget.onSelect(url, previewUrl, width, height, 'gif'),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: previewUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: Colors.grey[200]),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStickerGrid() {
    // Primary URLs from Supabase bucket
    final List<String> primaryUrls = List.generate(
      4, 
      (i) => 'https://icvncmawahwbpiohrcxv.supabase.co/storage/v1/object/public/stickers/blindly_sticker_${i+1}.png'
    );

    // Reliable fallback sticker set (using public high-quality stickers)
    final List<String> fallbackUrls = [
      'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Smilies/Beaming%20Face%20with%20Smiling%20Eyes.png',
      'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Smilies/Heart%20Eyes.png',
      'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Hand%20gestures/High%20Five.png',
      'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Activities/Party%20Popper.png',
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: primaryUrls.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => widget.onSelect(primaryUrls[index], primaryUrls[index], 200, 200, 'sticker'),
          child: CachedNetworkImage(
            imageUrl: primaryUrls[index],
            fit: BoxFit.contain,
            placeholder: (context, url) => Container(
              color: Colors.grey[100],
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            errorWidget: (context, url, error) {
              // On error (like 400), try fallback URL
              return CachedNetworkImage(
                imageUrl: fallbackUrls[index],
                fit: BoxFit.contain,
                errorWidget: (context, url, err) => const Icon(Icons.emoji_emotions_outlined, size: 40, color: Colors.grey),
              );
            },
          ),
        );
      },
    );
  }
}
