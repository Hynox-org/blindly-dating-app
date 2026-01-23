import 'package:flutter/material.dart';
import '../../../../core/widgets/app_layout.dart';
import '../../../home/screens/connection_type_screen.dart';
import '../../../../core/utils/navigation_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../provider/recent_matches_provider.dart';

class ChatScreen extends ConsumerWidget{
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppLayout(
      selectedIndex: 4,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Chat',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              NavigationUtils.navigateToWithSlide(
                context,
                const ConnectionTypeScreen(),
              );
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      hintText: 'Search conversations',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontFamily: 'Poppins',
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),

              // Recent Matches Header
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Text(
                  'Recent matches',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              // Recent Matches Section
              SizedBox(
                height: 110,
                child: Consumer(
                  builder: (context, ref, _) {
                    final state = ref.watch(recentMatchesProvider);

                    return state.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, __) => const SizedBox(),
                      data: (matches) => ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: matches.length,
                        itemBuilder: (_, i) {
                          final m = matches[i];
                          return _buildRecentMatchItem(
                            m.displayName,
                            m.imageUrl ?? '',
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              // Conversations Header
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Text(
                  'Conversations',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              // Conversations List
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildConversationItem(
                    name: 'Alexander',
                    message: 'Sounds great! See you again',
                    time: '5m ago',
                    imageUrl: 'https://randomuser.me/api/portraits/men/86.jpg',
                    unreadCount: 2,
                  ),
                  _buildConversationItem(
                    name: 'Alexander',
                    message: 'Sent a photo',
                    time: 'Tue',
                    imageUrl:
                        'https://randomuser.me/api/portraits/women/65.jpg',
                    unreadCount: 0,
                  ),
                  _buildConversationItem(
                    name: 'Alexander',
                    message: 'Sounds great! See you again',
                    time: 'Sun',
                    imageUrl: 'https://randomuser.me/api/portraits/men/51.jpg',
                    unreadCount: 2,
                  ),
                  _buildConversationItem(
                    name: 'Alexander',
                    message: 'Sounds great! See you again',
                    time: 'Sun',
                    imageUrl: 'https://randomuser.me/api/portraits/men/11.jpg',
                    unreadCount: 0,
                  ),
                  _buildConversationItem(
                    name: 'Alexander',
                    message: 'Sounds great! See you again',
                    time: 'Sat',
                    imageUrl:
                        'https://randomuser.me/api/portraits/women/90.jpg',
                    unreadCount: 2,
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentMatchItem(String name, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          CircleAvatar(radius: 32, backgroundImage: NetworkImage(imageUrl)),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationItem({
    required String name,
    required String message,
    required String time,
    required String imageUrl,
    required int unreadCount,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(imageUrl),
          ),
          title: Text(
            name,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              message,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey[800],
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              if (unreadCount > 0) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEBC163), // Gold-ish color from image
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const Divider(height: 1, color: Colors.grey),
      ],
    );
  }
}
