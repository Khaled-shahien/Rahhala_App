import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/core/localization/app_localization_extensions.dart';
import 'package:rahhala_app/features/image_search/domain/image_search_cubit.dart';
import 'package:rahhala_app/features/image_search/presentation/pages/pinterest_camera_screen.dart';

class ImageSearchBar extends StatefulWidget {
  const ImageSearchBar({super.key});

  @override
  State<ImageSearchBar> createState() => _ImageSearchBarState();
}

class _ImageSearchBarState extends State<ImageSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openCamera(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ImageSearchCubit>(),
          child: const PinterestCameraScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ImageSearchCubit>(),
      child: Builder(
        builder: (context) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(30.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: Colors.grey.shade500,
                  size: 22.sp,
                ),

                SizedBox(width: 8.w),

                /// Text Field
                Expanded(
                    child: TextField(
                  controller: _controller,
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    hintText: context.l10n.homeSearch,
                    filled: true,
                    fillColor: Colors.transparent,
                    hintStyle: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.grey.shade400,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.black,
                  ),
                )),

                SizedBox(width: 8.w),

                /// Camera Icon
                GestureDetector(
                  onTap: () => _openCamera(context),
                  child: Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      //color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.grey.shade600,
                      size: 22.sp,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
