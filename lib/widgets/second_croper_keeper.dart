import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

enum CropShapeType {
  square,
  rectangle,
}

class ImageCropPicker extends StatefulWidget {
  final int maxImages;
  final CropShapeType cropType;
  final List<XFile> initialImages;
  final Function(List<XFile>) onChanged;

  const ImageCropPicker({
    super.key,
    required this.onChanged,
    this.maxImages = 4,
    this.cropType = CropShapeType.square,
    this.initialImages = const [],
  });

  @override
  State<ImageCropPicker> createState() =>
      _ImageCropPickerState();
}

class _ImageCropPickerState
    extends State<ImageCropPicker> {
  final ImagePicker _picker = ImagePicker();

  late List<XFile> images;

  @override
  void initState() {
    super.initState();
    images = [...widget.initialImages];
  }

  // =========================
  // PICK SOURCE
  // =========================

  Future<void> _showSourcePicker() async {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // CAMERA ONLY MOBILE
                if (!kIsWeb)
                  ListTile(
                    leading: const Icon(
                      Icons.camera_alt,
                    ),
                    title: const Text(
                      "Take Picture",
                    ),
                    onTap: () async {
                      Navigator.pop(context);

                      await _pickImage(
                        ImageSource.camera,
                      );
                    },
                  ),

                // GALLERY
                ListTile(
                  leading: const Icon(
                    Icons.photo,
                  ),
                  title: const Text(
                    "Choose From Gallery",
                  ),
                  onTap: () async {
                    Navigator.pop(context);

                    await _pickMultipleImages();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =========================
  // PICK SINGLE IMAGE
  // =========================

  Future<void> _pickImage(
    ImageSource source,
  ) async {
    try {
      if (images.length >=
          widget.maxImages) {
        return;
      }

      final picked =
          await _picker.pickImage(
        source: source,
        imageQuality: 90,
      );

      if (picked == null) return;

      final cropped =
          await _cropImage(
        picked.path,
      );

      if (cropped == null) return;

      setState(() {
        images.add(
          XFile(cropped.path),
        );
      });

      widget.onChanged(images);
    } catch (e) {
      debugPrint(
        'Pick image error: $e',
      );
    }
  }

  // =========================
  // PICK MULTIPLE IMAGES
  // =========================

  Future<void>
      _pickMultipleImages() async {
    try {
      final picked =
          await _picker.pickMultiImage(
        imageQuality: 90,
      );

      if (picked.isEmpty) return;

      for (final img in picked) {
        if (images.length >=
            widget.maxImages) {
          break;
        }

        final cropped =
            await _cropImage(
          img.path,
        );

        if (cropped != null) {
          images.add(
            XFile(cropped.path),
          );
        }
      }

      setState(() {});

      widget.onChanged(images);
    } catch (e) {
      debugPrint(
        'Multi image error: $e',
      );
    }
  }

  // =========================
  // CROP IMAGE
  // =========================

  Future<CroppedFile?> _cropImage(
    String path,
  ) async {
    try {
      // WEB
      if (kIsWeb) {
        return CroppedFile(path);
      }

      // MOBILE
      return await ImageCropper()
          .cropImage(
        sourcePath: path,

        aspectRatio:
            widget.cropType ==
                    CropShapeType
                        .square
                ? const CropAspectRatio(
                    ratioX: 1,
                    ratioY: 1,
                  )
                : const CropAspectRatio(
                    ratioX: 4,
                    ratioY: 3,
                  ),

        uiSettings: [
          AndroidUiSettings(
            toolbarTitle:
                'Crop Image',
            toolbarColor:
                Colors.black,
            toolbarWidgetColor:
                Colors.white,
            lockAspectRatio: true,
            hideBottomControls:
                false,
          ),

          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled:
                true,
          ),
        ],
      );
    } catch (e) {
      debugPrint(
        'Crop error: $e',
      );

      return null;
    }
  }

  // =========================
  // REMOVE IMAGE
  // =========================

  void _removeImage(XFile img) {
    setState(() {
      images.remove(img);
    });

    widget.onChanged(images);
  }

  // =========================
  // IMAGE CARD
  // =========================

  Widget _imageCard(XFile img) {
    final width =
        widget.cropType ==
                CropShapeType.square
            ? 95.0
            : 140.0;

    return Stack(
      children: [
        ClipRRect(
          borderRadius:
              BorderRadius.circular(
            14,
          ),

          child: SizedBox(
            width: width,
            height: 95,

            child: kIsWeb

                // WEB
                ? Image.network(
                    img.path,
                    fit: BoxFit.cover,
                  )

                // ANDROID / IOS
                : Image.file(
                    File(img.path),
                    fit: BoxFit.cover,
                  ),
          ),
        ),

        Positioned(
          top: 4,
          right: 4,

          child: GestureDetector(
            onTap: () =>
                _removeImage(img),

            child: Container(
              padding:
                  const EdgeInsets.all(
                4,
              ),

              decoration:
                  const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,

      children: [
        ...images.map(_imageCard),

        if (images.length <
            widget.maxImages)
          GestureDetector(
            onTap: _showSourcePicker,

            child: Container(
              width:
                  widget.cropType ==
                          CropShapeType
                              .square
                      ? 95
                      : 140,

              height: 95,

              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),

                border: Border.all(
                  color:
                      Colors.grey.shade300,
                ),

                color: Colors.white,
              ),

              child: const Icon(
                Icons.add_a_photo,
                size: 30,
              ),
            ),
          ),
      ],
    );
  }
}