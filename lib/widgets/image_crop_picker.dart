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
  // CROPPER DIALOG WITH PINCH & ZOOM
  // =========================
// =========================
// CROPPER DIALOG WITH DIRECT CLICKABLE ZOOM BUTTONS (+ / -)
// =========================
Future<void> _showCropDialog() async {
  if (_rawImage == null) return;

  setState(() {
    _isProcessingCrop = false;
  });

  // Controller to programmatically control the + and - zoom actions
  final TransformationController transformController = TransformationController();
  double currentScale = 1.0;

  void zoom(double step) {
    // Calculate new target scale (bounded between 1.0x and 3.0x)
    final double targetScale = (currentScale + step).clamp(1.0, 3.0);
    if (targetScale == currentScale) return;

    currentScale = targetScale;
    
    // Programmatically set the scale matrix
    transformController.value = Matrix4.identity()..scale(targetScale);
  }

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SizedBox(
              width: 440,
              height: 560,
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: Stack(
                        children: [
                          // 🔍 InteractiveViewer provides programmatic zoom control
                          InteractiveViewer(
                            transformationController: transformController,
                            minScale: 1.0,
                            maxScale: 3.0,
                            panEnabled: true, // Click & drag to pan around
                            scaleEnabled: true, // Allows mouse wheel / pinch zoom as well
                            child: Crop(
                              image: _rawImage!,
                              controller: _cropController,
                              interactive: false, // Gesture handling managed by InteractiveViewer
                              fixCropRect: false,
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
                          
                          // Floating instruction badge
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.touch_app, color: Colors.white, size: 14),
                                  SizedBox(width: 6),
                                  Text(
                                    "Use + / - buttons or drag to align",
                                    style: TextStyle(color: Colors.white, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ➕ / ➖ CLICKABLE ZOOM CONTROLS
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    color: Colors.grey.shade100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Zoom Out (-) Button
                        IconButton.filledTonal(
                          icon: const Icon(Icons.remove),
                          tooltip: "Zoom Out",
                          onPressed: () {
                            setDialogState(() {
                              zoom(-0.25); // Scale down by 0.25x
                            });
                          },
                        ),
                        const SizedBox(width: 16),
                        
                        // Current Scale Indicator Text
                        Text(
                          "${(currentScale * 100).toInt()}%",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Zoom In (+) Button
                        IconButton.filledTonal(
                          icon: const Icon(Icons.add),
                          tooltip: "Zoom In",
                          onPressed: () {
                            setDialogState(() {
                              zoom(0.25); // Scale up by 0.25x
                            });
                          },
                        ),
                        
                        const SizedBox(width: 20),
                        
                        // Reset Zoom Button
                        TextButton.icon(
                          icon: const Icon(Icons.restart_alt, size: 18),
                          label: const Text("Reset"),
                          onPressed: () {
                            setDialogState(() {
                              currentScale = 1.0;
                              transformController.value = Matrix4.identity();
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  // Action Buttons (Cancel / Crop)
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
                        ElevatedButton(
                          onPressed: _isProcessingCrop
                              ? null
                              : () {
                                  setDialogState(() => _isProcessingCrop = true);
                                  setState(() => _isProcessingCrop = true);

                                  Future.delayed(const Duration(milliseconds: 60), () {
                                    _cropController.crop();
                                  });
                                },
                          child: _isProcessingCrop
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text("Crop"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

  void _addCroppedImage(Uint8List cropped) {
    if (_pendingFile == null || !mounted) return;

    final file = XFile.fromData(
      cropped,
      name: _pendingFile!.name,
      mimeType: 'image/jpeg',
    );

    setState(() {
      images.add(CroppedImageContainer(file: file, bytes: cropped));
      _rawImage = null;
      _pendingFile = null;
      _isProcessingCrop = false;
    });

    widget.onChanged(images.map((e) => e.file).toList());
  }

  void _removeImage(CroppedImageContainer img) {
    setState(() {
      images.remove(img);
    });
    widget.onChanged(images.map((e) => e.file).toList());
  }

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