import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:rahhala_app/core/crash/app_error_reporter.dart';
import 'package:rahhala_app/core/localization/app_localization_extensions.dart';
import 'package:rahhala_app/core/logging/app_logger.dart';
import 'package:rahhala_app/features/image_search/domain/image_search_cubit.dart';
import 'package:rahhala_app/features/image_search/domain/image_search_state.dart';
import 'package:rahhala_app/features/image_search/presentation/pages/image_search_results_screen.dart';

class PinterestCameraScreen extends StatefulWidget {
  const PinterestCameraScreen({super.key});

  @override
  State<PinterestCameraScreen> createState() => _PinterestCameraScreenState();
}

class _PinterestCameraScreenState extends State<PinterestCameraScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  List<AssetEntity> _galleryAssets = [];
  bool _isCameraReady = false;
  bool _isFlashOn = false;
  String? _cameraError;
  String? _galleryError;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
    _loadGallery();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
      _cameraController = null;
      if (mounted) setState(() => _isCameraReady = false);
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    final noCameraMessage = context.l10n.imageSearchNoCamera;
    final cameraUnavailableMessage = context.l10n.imageSearchCameraUnavailable;
    try {
      if (mounted) {
        setState(() {
          _cameraError = null;
          _isCameraReady = false;
        });
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _cameraError = noCameraMessage);
        return;
      }

      final controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }

      await _cameraController?.dispose();
      setState(() {
        _cameras = cameras;
        _cameraController = controller;
        _isCameraReady = true;
      });
    } catch (e) {
      AppLogger.instance
          .e('PinterestCameraScreen failed camera init', error: e);
      if (mounted) {
        setState(() {
          _cameraError = cameraUnavailableMessage;
          _isCameraReady = false;
        });
      }
    }
  }

  Future<void> _loadGallery() async {
    final photoAccessRequiredMessage =
        context.l10n.imageSearchPhotoAccessRequired;
    final noPhotosMessage = context.l10n.imageSearchNoPhotos;
    try {
      final permission = await PhotoManager.requestPermissionExtend();
      if (!permission.hasAccess) {
        if (mounted) {
          setState(() => _galleryError = photoAccessRequiredMessage);
        }
        return;
      }

      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        filterOption: FilterOptionGroup(
          orders: [const OrderOption(type: OrderOptionType.createDate)],
        ),
      );

      if (albums.isEmpty) {
        if (mounted) setState(() => _galleryError = noPhotosMessage);
        return;
      }

      final assets = await albums.first.getAssetListRange(start: 0, end: 30);
      if (mounted) {
        setState(() {
          _galleryError = null;
          _galleryAssets = assets;
        });
      }
    } catch (e) {
      AppLogger.instance
          .e('PinterestCameraScreen failed gallery load', error: e);
      if (mounted) setState(() => _galleryError = noPhotosMessage);
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null) return;
    final nextFlashState = !_isFlashOn;
    try {
      await _cameraController!.setFlashMode(
        nextFlashState ? FlashMode.torch : FlashMode.off,
      );
      if (mounted) setState(() => _isFlashOn = nextFlashState);
    } catch (e) {
      AppLogger.instance
          .e('PinterestCameraScreen failed flash toggle', error: e);
    }
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    try {
      final file = await _cameraController!.takePicture();
      if (!mounted) return;
      _searchWithFile(file.path);
    } catch (e) {
      AppLogger.instance
          .e('PinterestCameraScreen failed taking picture', error: e);
    }
  }

  Future<void> _pickFromGallery(AssetEntity asset) async {
    final photoOpenErrorMessage = context.l10n.imageSearchPhotoOpenError;
    try {
      final file = await asset.file;
      if (file == null || !mounted) return;
      _searchWithFile(file.path);
    } catch (e) {
      AppLogger.instance
          .e('PinterestCameraScreen failed gallery pick', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(photoOpenErrorMessage)),
        );
      }
    }
  }

  void _searchWithFile(String path) {
    context.read<ImageSearchCubit>().pickAndSearch(path);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<ImageSearchCubit, ImageSearchState>(
      listener: (context, state) {
        if (state is ImageSearchLoading ||
            state is ImageSearchSuccess ||
            state is ImageSearchFailure) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<ImageSearchCubit>(),
                child: const ImageSearchResultsScreen(),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Stack(
            children: [
              if (_cameraError != null)
                Positioned.fill(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.no_photography_outlined,
                              color: Colors.white70, size: 44.sp),
                          SizedBox(height: 12.h),
                          Text(
                            _cameraError!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white70, fontSize: 14.sp),
                          ),
                          SizedBox(height: 16.h),
                          TextButton(
                            onPressed: _initCamera,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (_isCameraReady && _cameraController != null)
                Positioned.fill(
                  child: CameraPreview(_cameraController!),
                )
              else
                const Positioned.fill(
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              SafeArea(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTopButton(
                        icon: _isFlashOn ? Icons.flash_on : Icons.flash_auto,
                        onTap: _toggleFlash,
                      ),
                      _buildTopButton(
                        icon: Icons.close,
                        onTap: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),
              DraggableScrollableSheet(
                controller: _sheetController,
                initialChildSize: 0.22,
                minChildSize: 0.22,
                maxChildSize: 0.75,
                builder: (_, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? colorScheme.surface.withValues(alpha: 0.95)
                          : Colors.black.withValues(alpha: 0.85),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20.r)),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 10.h),
                        Container(
                          width: 40.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: isDark
                                ? colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.4)
                                : Colors.white38,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (_galleryAssets.isNotEmpty)
                                GestureDetector(
                                  onTap: () =>
                                      _pickFromGallery(_galleryAssets.first),
                                  child: _GalleryThumb(
                                    asset: _galleryAssets.first,
                                    size: 52,
                                    borderRadius: 10,
                                  ),
                                )
                              else
                                SizedBox(width: 52.w),
                              GestureDetector(
                                onTap: _takePicture,
                                child: Container(
                                  width: 72.w,
                                  height: 72.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 3.w),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 58.w,
                                      height: 58.w,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              _buildTopButton(
                                icon: Icons.flip_camera_ios_outlined,
                                onTap: () async {
                                  if (_cameras.length < 2) return;
                                  final current =
                                      _cameraController?.description;
                                  final next = _cameras.firstWhere(
                                    (c) => c != current,
                                    orElse: () => _cameras.first,
                                  );
                                  try {
                                    final controller = CameraController(
                                      next,
                                      ResolutionPreset.high,
                                      enableAudio: false,
                                    );
                                    await controller.initialize();
                                    await _cameraController?.dispose();
                                    if (!mounted) {
                                      await controller.dispose();
                                      return;
                                    }
                                    setState(() {
                                      _cameraController = controller;
                                      _isCameraReady = true;
                                    });
                                  } catch (e) {
                                    AppErrorReporter.record(
                                      'PinterestCameraScreen failed camera flip',
                                      error: e,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Expanded(
                          child: _galleryAssets.isEmpty
                              ? Center(
                                  child: Text(_galleryError ?? 'No photos',
                                      style: TextStyle(
                                          color: isDark
                                              ? colorScheme.onSurfaceVariant
                                              : Colors.white54)),
                                )
                              : GridView.builder(
                                  controller: scrollController,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 4.w),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    crossAxisSpacing: 3.w,
                                    mainAxisSpacing: 3.h,
                                  ),
                                  itemCount: _galleryAssets.length,
                                  itemBuilder: (_, i) => GestureDetector(
                                    onTap: () =>
                                        _pickFromGallery(_galleryAssets[i]),
                                    child: _GalleryThumb(
                                      asset: _galleryAssets[i],
                                      size: 100,
                                      borderRadius: 4,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: const BoxDecoration(
          color: Colors.black38,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24.sp),
      ),
    );
  }
}

class _GalleryThumb extends StatefulWidget {
  final AssetEntity asset;
  final double size;
  final double borderRadius;

  const _GalleryThumb({
    required this.asset,
    required this.size,
    required this.borderRadius,
  });

  @override
  State<_GalleryThumb> createState() => _GalleryThumbState();
}

class _GalleryThumbState extends State<_GalleryThumb> {
  File? _file;

  @override
  void initState() {
    super.initState();
    _loadThumb();
  }

  Future<void> _loadThumb() async {
    final file = await widget.asset.file;
    if (mounted) setState(() => _file = file);
  }

  @override
  Widget build(BuildContext context) {
    if (_file == null) {
      return Container(
        width: widget.size.w,
        height: widget.size.w,
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(widget.borderRadius.r),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius.r),
      child: Image.file(
        _file!,
        width: widget.size.w,
        height: widget.size.w,
        fit: BoxFit.cover,
        cacheWidth: 200,
      ),
    );
  }
}
