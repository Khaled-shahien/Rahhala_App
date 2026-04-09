import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahhala_app/core/constants/app_colors.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/features/home/domain/repositories/home_repository.dart';
import 'package:rahhala_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:rahhala_app/features/home/presentation/pages/place_details_screen.dart';
import 'package:rahhala_app/features/home/presentation/widgets/place_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(sl<HomeRepository>())..getHomeData(),
      child: Scaffold(
        body: Builder(
          builder: (context) {
            return RefreshIndicator(
              color: AppColors.lightBrown,
              backgroundColor: Colors.white,
              onRefresh: () async {
                await context.read<HomeCubit>().getHomeData();
              },
              child: BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is HomeError) {
                    return ListView(
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.4),
                        Center(child: Text('Error: ${state.message}')),
                      ],
                    );
                  } else if (state is HomeSuccess) {
                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: state.places.length,
                      itemBuilder: (context, index) {
                        final place = state.places[index];
                        return PlaceCard(
                          place: place,
                          isFav: place.isFavourite,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PlaceDetailsScreen(placeId: place.id),
                              ),
                            );
                          },
                          onFavTap: () {},
                        );
                      },
                    );
                  }
                  return ListView(
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.4),
                      const Center(child: Text("No Data Found")),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
