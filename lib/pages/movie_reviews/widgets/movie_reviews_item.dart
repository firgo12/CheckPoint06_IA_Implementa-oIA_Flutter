import 'package:flutter/material.dart';
import 'package:movie_app/models/review_model.dart';

class MovieReviewsItem extends StatelessWidget {
  final Review review;
  final VoidCallback onTap;

  const MovieReviewsItem({
    super.key,
    required this.review,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: review.authorDetails.avatarPath != null
                  ? NetworkImage(
                      'https://image.tmdb.org/t/p/w500${review.authorDetails.avatarPath}')
                  : null,
              child: review.authorDetails.avatarPath == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(review.author),
            subtitle: Text(review.content),
            isThreeLine: true,
          ),
          const Divider(thickness: 1, color: Colors.grey),
        ],
      ),
    );
  }
}
