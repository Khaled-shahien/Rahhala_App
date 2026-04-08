import 'package:flutter/material.dart';
import '../../data/models/place_model.dart';
import '../widgets/place_card.dart';
import 'place_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Set<int> favIds = {};

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: mockPlaces.length,
      itemBuilder: (_, index) {
        final place = mockPlaces[index];

        return PlaceCard(
          place: place,
          isFav: favIds.contains(place.id),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PlaceDetailsScreen(place: place),
              ),
            );
          },
          onFavTap: () {
            setState(() {
              favIds.contains(place.id)
                  ? favIds.remove(place.id)
                  : favIds.add(place.id);
            });
          },
        );
      },
    );
  }
}
