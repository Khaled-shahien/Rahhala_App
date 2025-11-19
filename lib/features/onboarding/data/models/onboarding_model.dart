

class OnboardingModel {
  final String title;
  final String subtitle;
  final String description;
  final List<String> images; 

  OnboardingModel({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.images,
  });
}

final List<OnboardingModel> onboardingPages = [
  
  OnboardingModel(
    title: 'Discover',
    subtitle: 'Amazing\nDestinations',
    description: 'From the Nile to the desert — your\nEgyptian journey begins.',
    images: [
      'assets/images/1.png', 
      'assets/images/2.png', 
      'assets/images/3.png', 

    ],
  ),

  OnboardingModel(
    title: 'Designing',
    subtitle: 'Your Trip',
    description: 'Finding destinations and experiences\nthat match your vibe.',
    images: [
      'assets/images/Rectangle 119.png', 
      'assets/images/Rectangle 120.png', 
      'assets/images/Rectangle 121.png', 
    ],
  ),

  OnboardingModel(
    title: 'Ready to',
    subtitle: 'Explore ?',
    description:
        'Your personalized adventure awaits —\nlet\'s start the journey!',
    images: [
      'assets/images/7.png', 
      'assets/images/8.png', 
      'assets/images/9.png', 
    ],
  ),
];

