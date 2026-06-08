import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../common/app_colors.dart';
import '../../common/localization.dart';
import '../../data/models/story.dart';
import '../../data/repositories/story_repository.dart';
import '../../providers/auth_provider.dart';
import '../../providers/story_detail_provider.dart';
import '../../utils/result_state.dart';
import '../widgets/empty_display.dart';
import '../widgets/error_display.dart';
import '../widgets/shimmer_detail_loading.dart';

class DetailScreen extends StatelessWidget {
  final String storyId;

  const DetailScreen({super.key, required this.storyId});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final repo = context.read<StoryRepository>();

    return ChangeNotifierProvider(
      create: (_) =>
          StoryDetailProvider(repository: repo, token: auth.token!)
            ..fetchDetail(storyId),
      child: _DetailContent(storyId: storyId),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final String storyId;

  const _DetailContent({required this.storyId});

  @override
  Widget build(BuildContext context) {
    return Consumer<StoryDetailProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          body: switch (provider.state) {
            ResultLoading() => const ShimmerDetailLoading(),
            ResultSuccess<Story>(data: final story) => _buildDetail(
              context,
              story,
            ),
            ResultError(message: final msg) => ErrorDisplay(
              message: msg,
              onRetry: () => provider.fetchDetail(storyId),
            ),
            ResultEmpty() => EmptyDisplay(
              message: AppLocalizations.of(context).noData,
            ),
          },
        );
      },
    );
  }

  Widget _buildDetail(BuildContext context, Story story) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Hero(
              tag: 'story-image-${story.id}',
              child: CachedNetworkImage(
                imageUrl: story.photoUrl,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  color: AppColors.primaryColor.withValues(alpha: 0.10),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.photo_outlined,
                    color: AppColors.primaryColor,
                    size: 48,
                  ),
                ),
                errorWidget: (_, _, _) => Container(
                  color: AppColors.primaryColor.withValues(alpha: 0.10),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.primaryColor,
                    size: 48,
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primaryColor,
                      radius: 22,
                      child: Text(
                        story.name.isNotEmpty
                            ? story.name[0].toUpperCase()
                            : '?',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            story.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatFullDate(context, story.createdAt),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.55,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.description,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  story.description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.6),
                ),
                if (story.lat != null && story.lon != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    l10n.locationLabel,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  _StoryMap(lat: story.lat!, lon: story.lon!),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatFullDate(BuildContext context, DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${months[date.month - 1]} ${date.year} · $hour:$minute';
  }
}

class _StoryMap extends StatefulWidget {
  final double lat;
  final double lon;

  const _StoryMap({required this.lat, required this.lon});

  @override
  State<_StoryMap> createState() => _StoryMapState();
}

class _StoryMapState extends State<_StoryMap> {
  String _address = '';

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  Future<void> _loadAddress() async {
    try {
      final placemarks = await geocoding.placemarkFromCoordinates(
        widget.lat,
        widget.lon,
      );
      if (placemarks.isNotEmpty && mounted) {
        final place = placemarks.first;
        final parts = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
        ].where((e) => e != null && e.isNotEmpty);

        setState(() {
          _address = parts.join(', ');
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _address =
              '${widget.lat.toStringAsFixed(4)}, ${widget.lon.toStringAsFixed(4)}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = LatLng(widget.lat, widget.lon);
    final l10n = AppLocalizations.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 200,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: location, zoom: 15),
          markers: {
            Marker(
              markerId: const MarkerId('story-location'),
              position: location,
              infoWindow: InfoWindow(
                title: l10n.locationLabel,
                snippet: _address.isNotEmpty ? _address : '...',
              ),
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
    );
  }
}
