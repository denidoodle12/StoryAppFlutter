import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../common/app_colors.dart';
import '../../common/app_routes.dart';
import '../../common/flavor_config.dart';
import '../../common/localization.dart';
import '../../providers/story_list_provider.dart';
import '../../providers/story_upload_provider.dart';
import '../widgets/common_widgets.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 80,
    );
    if (file != null && mounted) {
      context.read<StoryUploadProvider>().setImage(file);
    }
  }

  Future<void> _handleUpload() async {
    if (!_formKey.currentState!.validate()) return;

    final uploadProvider = context.read<StoryUploadProvider>();
    if (uploadProvider.imageFile == null) {
      context.showErrorSnackBar(AppLocalizations.of(context).selectImage);
      return;
    }

    final success = await uploadProvider.upload(
      description: _descriptionController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      context.showSuccessSnackBar(AppLocalizations.of(context).uploadSuccess);
      context.read<StoryListProvider>().fetchStories();
      context.go(AppRoutes.home);
    } else if (uploadProvider.errorMessage != null) {
      context.showErrorSnackBar(uploadProvider.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.uploadStory)),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImagePreview(context),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_rounded),
                      label: Text(l10n.camera),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_rounded),
                      label: Text(l10n.gallery),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  labelText: l10n.description,
                  hintText: l10n.descriptionHint,
                  alignLabelWithHint: true,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.edit_note_rounded),
                  ),
                ),
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return l10n.descriptionRequired;
                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (FlavorConfig.isPaid) _buildLocationPicker(context),
              if (FlavorConfig.isFree) _buildPaidFeatureHint(context),
              const SizedBox(height: 32),
              Consumer<StoryUploadProvider>(
                builder: (context, provider, _) {
                  return SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: provider.isUploading ? null : _handleUpload,
                      icon: provider.isUploading
                          ? const ButtonLoadingIndicator()
                          : const Icon(Icons.upload_rounded),
                      label: Text(l10n.upload),
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

  Widget _buildImagePreview(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Consumer<StoryUploadProvider>(
      builder: (context, provider, _) {
        if (provider.imageBytes != null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Image.memory(
                  provider.imageBytes!,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => provider.clearImage(),
                      iconSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          height: 250,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.onSurface.withValues(alpha: 0.12),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 64,
                color: AppColors.primaryColor.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.selectImage,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.selectImageSubtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: colorScheme.onSurface.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationPicker(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<StoryUploadProvider>(
      builder: (context, provider, _) {
        if (provider.selectedLocation != null) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.onSurface.withValues(alpha: 0.12),
              ),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: provider.selectedLocation!,
                        zoom: 15,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId('selected'),
                          position: provider.selectedLocation!,
                        ),
                      },
                      zoomControlsEnabled: false,
                      scrollGesturesEnabled: false,
                      rotateGesturesEnabled: false,
                      tiltGesturesEnabled: false,
                      zoomGesturesEnabled: false,
                      myLocationButtonEnabled: false,
                      liteModeEnabled: true,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: AppColors.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          provider.selectedAddress ?? '',
                          style: GoogleFonts.plusJakartaSans(fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: colorScheme.error,
                          size: 20,
                        ),
                        onPressed: () => provider.clearLocation(),
                        tooltip: l10n.removeLocation,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return OutlinedButton.icon(
          onPressed: () => _navigateToPickLocation(),
          icon: const Icon(Icons.add_location_alt_rounded),
          label: Text(l10n.addLocation),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        );
      },
    );
  }

  Future<void> _navigateToPickLocation() async {
    final result = await context.push<Map<String, dynamic>>(
      AppRoutes.pickLocation,
    );

    if (result != null && mounted) {
      final latLng = result['latLng'] as LatLng;
      final address = result['address'] as String;
      context.read<StoryUploadProvider>().setLocation(latLng, address);
    }
  }

  Widget _buildPaidFeatureHint(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Opacity(
      opacity: 0.5,
      child: OutlinedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.lock_rounded),
        label: Text('${l10n.addLocation} (Paid)'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
