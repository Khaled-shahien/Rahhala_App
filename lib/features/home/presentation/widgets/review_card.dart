import 'package:flutter/material.dart';
import 'rating_stars.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            /// 👤 Name + Date (من غير avatar)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Sara Ahmed",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "2 days ago",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),

            SizedBox(height: 8),

            RatingStars(rating: 5),

            SizedBox(height: 8),

            Text(
              "Amazing place! Everything was perfect and the view was incredible 🔥",
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
