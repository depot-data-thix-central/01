// lib/presentation/chat/widgets/stories_row.dart
import 'package:flutter/material.dart';
import '../../models/chat_models.dart';

class StoriesRow extends StatelessWidget {
  final List<Story> stories;
  final VoidCallback onViewAll;
  final Function(Story) onStoryTap;

  const StoriesRow({
    super.key,
    required this.stories,
    required this.onViewAll,
    required this.onStoryTap,
  });

  @override
  Widget build(BuildContext context) {
    if (stories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'En ligne',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey),
              ),
              GestureDetector(
                onTap: onViewAll,
                child: Text(
                  'Voir tout',
                  style: TextStyle(fontSize: 10, color: const Color(0xFFD4AF37)),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 70,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: stories.length,
            itemBuilder: (context, index) => _buildStoryItem(stories[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildStoryItem(Story story) {
    return GestureDetector(
      onTap: () => onStoryTap(story),
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: story.isViewed
                        ? null
                        : const LinearGradient(
                            colors: [Color(0xFFD4AF37), Color(0xFFAA7C11)],
                          ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundImage: story.userAvatar != null
                          ? NetworkImage(story.userAvatar!)
                          : null,
                      child: story.userAvatar == null
                          ? const Icon(Icons.person, size: 20)
                          : null,
                    ),
                  ),
                ),
                if (story.type == 'video')
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              story.userName.length > 8
                  ? '${story.userName.substring(0, 8)}...'
                  : story.userName,
              style: const TextStyle(fontSize: 9, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
