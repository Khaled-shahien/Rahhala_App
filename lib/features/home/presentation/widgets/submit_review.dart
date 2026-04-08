import 'package:flutter/material.dart';

class SubmitReview extends StatefulWidget {
  const SubmitReview({super.key});

  @override
  State<SubmitReview> createState() => _SubmitReviewState();
}

class _SubmitReviewState extends State<SubmitReview> {
  int selectedRating = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Submit your review",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text("Your Rate"),
        const SizedBox(height: 6),
        Row(
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (selectedRating == index + 1) {
                    selectedRating = 0;
                  } else {
                    selectedRating = index + 1;
                  }
                });
              },
              child: Icon(
                index < selectedRating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 28,
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        const TextField(
          decoration: InputDecoration(
            hintText: "Name",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        const TextField(
          decoration: InputDecoration(
            hintText: "Email",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        const TextField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "Your review",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              print("Rating: $selectedRating");
            },
            child: const Text("Submit"),
          ),
        ),
      ],
    );
  }
}
