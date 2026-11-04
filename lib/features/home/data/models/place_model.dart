class Place {
  final int id;
  final String name;
  final String location;
  final String image;
  final String description;
  final double rating; // ← ضيف ده

  Place({
    required this.id,
    required this.name,
    required this.location,
    required this.image,
    required this.description,
    required this.rating, // ← ضيف ده
  });
}

final List<Place> mockPlaces = [
  Place(
    id: 1,
    name: 'Luxor',
    location: 'Egypt',
    image: 'assets/images/test.png',
    description: 'A beautiful historical city full of temples and culture.',
    rating: 4.5,
  ),
  Place(
    id: 2,
    name: 'Aswan',
    location: 'Egypt',
    image: 'assets/images/test.png',
    description: 'Amazing Nile views and peaceful vibes.',
    rating: 2.5,
  ),
];
