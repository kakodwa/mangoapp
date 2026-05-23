import 'package:flutter/material.dart';
import '../../providers/api_provider.dart';
import '../../widgets/main_app_bar.dart';
import '../../theme/design_system/app_spacing.dart';

class PropertyAmenitiesWidget extends StatelessWidget {
  final List<String> amenities;

  const PropertyAmenitiesWidget({
    Key? key,
    required this.amenities,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (amenities.isEmpty) {
      return const SizedBox.shrink();
    }

    final amenityIcons = {
      'wifi': Icons.wifi,
      'parking': Icons.local_parking,
      'security': Icons.security,
      'garden': Icons.grass,
      'pool': Icons.pool,
      'gym': Icons.fitness_center,
      'kitchen': Icons.kitchen,
      'balcony': Icons.window,
      'air_conditioning': Icons.ac_unit,
      'heating': Icons.thermostat,
      'laundry': Icons.local_laundry_service,
      'elevator': Icons.arrow_upward,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amenities',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.2,
          children: amenities.map((amenity) {
            final icon = amenityIcons[amenity.toLowerCase()] ?? Icons.check;
            return _buildAmenityItem(
              context,
              icon: icon,
              label: _formatAmenityLabel(amenity),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAmenityItem(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.onSurfaceVariant!),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatAmenityLabel(String amenity) {
    return amenity
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
