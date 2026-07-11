import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crop_your_image/crop_your_image.dart';

enum CropShapeType {
  square,
  rectangle,
}


class CroppedImageContainer {
  final XFile file;
  final Uint8List bytes;

  CroppedImageContainer({required this.file, required this.bytes});
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
  State<ImageCropPicker> createState() => _ImageCropPickerState();
}

class _ImageCropPickerState extends State<ImageCropPicker> {
  final ImagePicker _picker = ImagePicker();
  
  // 🌟 Changed state arrays to manage byte data alongside metadata
  late List<CroppedImageContainer> images;
  final CropController _cropController = CropController();

  Uint8List? _rawImage;
  XFile? _pendingFile;
  bool _isProcessingCrop = false;

  @override
  void initState() {
    super.initState();
    images = [];
    _initializeDefaultImages();
  }

  // Helper to safely unpack any initial files passed to the widget
  Future<void> _initializeDefaultImages() async {
    for (final file in widget.initialImages) {
      final bytes = await file.readAsBytes();
      if (mounted) {
        setState(() {
          images.add(CroppedImageContainer(file: file, bytes: bytes));
        });
      }
    }
  }

  // =========================
  // PICK IMAGE (WITH AGGRESSIVE DOWN-SAMPLING)
  // =========================
  Future<void> _pickImage(ImageSource source) async {
    if (images.length >= widget.maxImages) return;

    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1024,   
      maxHeight: 1024,  
      imageQuality: 80, 
    );

    if (picked == null) return;

    final bytes = await picked.readAsBytes();

    setState(() {
      _rawImage = bytes;
      _pendingFile = picked;
    });

    if (mounted) {
      _showCropDialog();
    }
  }

  // =========================
  // MULTI PICK
  // =========================
  Future<void> _pickMultipleImages() async {
    final picked = await _picker.pickMultiImage(
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    if (picked.isEmpty) return;

    for (final img in picked) {
      if (images.length >= widget.maxImages) break;

      final bytes = await img.readAsBytes();

      setState(() {
        _rawImage = bytes;
        _pendingFile = img;
      });

      await _showCropDialog();
    }
  }

  // =========================
  // CROPPER DIALOG
  // =========================
  Future<void> _showCropDialog() async {
    if (_rawImage == null) return;

    setState(() {
      _isProcessingCrop = false;
    });

    await showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SizedBox(
            width: 400,
            height: 500,
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Crop(
                      image: _rawImage!,
                      controller: _cropController,
                      interactive: true,
                      aspectRatio: widget.cropType == CropShapeType.square ? 1 : 4 / 3,
                      onCropped: (croppedData) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (Navigator.canPop(dialogContext)) {
                            Navigator.pop(dialogContext);
                          }
                          _addCroppedImage(croppedData);
                        });
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          if (!_isProcessingCrop) Navigator.pop(dialogContext);
                        },
                        child: const Text("Cancel"),
                      ),
                      StatefulBuilder(
                        builder: (context, setButtonState) {
                          return _isProcessingCrop
                              ? const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: () {
                                    setButtonState(() {
                                      _isProcessingCrop = true;
                                    });
                                    setState(() {
                                      _isProcessingCrop = true;
                                    });
                                    
                                    Future.delayed(const Duration(milliseconds: 60), () {
                                      _cropController.crop();
                                    });
                                  },
                                  child: const Text("Crop"),
                                );
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // =========================
  // ADD CROPPED IMAGE
  // =========================
  void _addCroppedImage(Uint8List cropped) {
    if (_pendingFile == null || !mounted) return;

    final file = XFile.fromData(
      cropped,
      name: _pendingFile!.name,
      mimeType: 'image/jpeg',
    );

    setState(() {
      // 🌟 Store both the file schema and raw image bytes directly
      images.add(CroppedImageContainer(file: file, bytes: cropped));
      _rawImage = null;
      _pendingFile = null;
      _isProcessingCrop = false;
    });

    widget.onChanged(images.map((e) => e.file).toList());
  }

  // =========================
  // REMOVE IMAGE
  // =========================
  void _removeImage(CroppedImageContainer img) {
    setState(() {
      images.remove(img);
    });
    widget.onChanged(images.map((e) => e.file).toList());
  }

  // =========================
  // IMAGE CARD
  // =========================
  Widget _imageCard(CroppedImageContainer img) {
    final width = widget.cropType == CropShapeType.square ? 95.0 : 140.0;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: width,
            height: 95,
            child: Image.memory(
              img.bytes, 
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
                );
              },
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeImage(img),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  // =========================
  // SOURCE PICKER
  // =========================
  void _showSourcePicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!kIsWeb)
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Camera"),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickMultipleImages();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ...images.map(_imageCard),
        if (images.length < widget.maxImages)
          GestureDetector(
            onTap: _showSourcePicker,
            child: Container(
              width: widget.cropType == CropShapeType.square ? 95 : 140,
              height: 95,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Icon(Icons.add_a_photo, size: 30),
            ),
          ),
      ],
    );
  }
}