import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/properties_provider.dart';
import '../../providers/api_provider.dart';
import '../../widgets/main_app_bar.dart';
import '../../widgets/shop_map_modal.dart';
import '../../theme/app_colors.dart';
import 'property_unlock_screen.dart';
import 'property_card.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../../theme/design_system/app_spacing.dart';

class PropertyDetailsScreen extends ConsumerWidget {
  final int propertyId;

  const PropertyDetailsScreen({
    Key? key,
    required this.propertyId,
  }) : super(key: key);

  bool _isLandProperty(String type) {
    final value = type.toLowerCase();
    return value.contains('land') ||
        value.contains('plot') ||
        value.contains('farm');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertyAsync = ref.watch(propertyDetailsProvider(propertyId));


    return Scaffold(
      appBar: propertyAsync.when(
        data: (property) => MainAppBar(title: property.title),
        loading: () => const MainAppBar(title: 'Loading...'),
        error: (_, __) => MainAppBar(title: 'Property detail'),
      ),
      body: propertyAsync.when(
        data: (property) {
          final authState = ref.watch(authProvider);
          final isLoggedIn = authState.isAuthenticated;
          final currentUserId = authState.user?.id;
          final relatedAsync = ref.watch(relatedPropertiesProvider(property.id));
          final isOwner = currentUserId == property.ownerId;

          final isLand = _isLandProperty(property.propertyType);

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // 🖼 IMAGE HEADER / CAROUSEL
                  SliverAppBar(
                    expandedHeight: 300,
                    floating: false,
                    pinned: false,
                    automaticallyImplyLeading: false,
                    flexibleSpace: FlexibleSpaceBar(
                      background: property.images.isNotEmpty
                          ? Stack(
                              children: [
                                PageView.builder(
                                  itemCount: property.images.length,
                                  itemBuilder: (context, index) {
                                    final image = property.images[index];

                                    return Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.network(
                                          image.image,
                                          fit: BoxFit.cover,
                                        ),

                                        // gradient overlay
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Theme.of(context).colorScheme.onSurface.withOpacity(0.15),
                                                Colors.transparent,
                                                Theme.of(context).colorScheme.onSurface.withOpacity(0.25),
                                              ],
                                            ),
                                          ),
                                        ),

                                        // primary badge
                                        if (image.isPrimary)
                                          Positioned(
                                            top: 50,
                                            right: 16,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 5,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.mangoOrange,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: const Text(
                                                'Primary',
                                                style: TextStyle(
                                                  color: Theme.of(context).colorScheme.surface,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),

                                        // alt text
                                        if (image.altText != null &&
                                            image.altText!.isNotEmpty)
                                          Positioned(
                                            left: 16,
                                            bottom: 20,
                                            right: 16,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 8,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.black54,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                image.altText!,
                                                style: const TextStyle(
                                                  color: Theme.of(context).colorScheme.surface,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),

                                // image counter
                                if (property.images.length > 1)
                                  Positioned(
                                    right: 16,
                                    bottom: 16,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${property.images.length} Photos',
                                        style: const TextStyle(
                                          color: Theme.of(context).colorScheme.surface,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          : Container(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              child: Center(
                                child: Icon(
                                  Icons.home,
                                  size: 80,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                    ),
                  ),

                  // 📄 CONTENT
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🏷 TITLE
                          Text(
                            property.title,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),

                          const SizedBox(height: 10),

                          // 🏠 PURPOSE + TYPE
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _buildTag(
                                property.listingPurpose.toUpperCase(),
                                AppColors.mangoOrange,
                              ),
                              _buildTag(
                                property.propertyType.toUpperCase(),
                                Theme.of(context).colorScheme.primary,
                              ),
                              _buildTag(
                                property.status.toUpperCase(),
                                Theme.of(context).colorScheme.secondary,
                              ),
                            ],
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // 💰 PRICE
                          Text(
                            '${property.currency} ${property.price.toStringAsFixed(0)}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.mangoOrange,
                                ),
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // 📍 LOCATION
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: AppColors.mangoOrange,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  property.isUnlocked || isOwner
                                      ? '${property.address}, ${property.city}, ${property.district}, Malawi'
                                      : '${property.city}, ${property.district}, Malawi',
                                  style:
                                      Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // 📊 DETAILS GRID
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: 1.65,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            children: [
                              _buildDetail(
                                context,
                                Icons.category,
                                'Type',
                                property.propertyType,
                              ),

                              _buildDetail(
                                context,
                                Icons.sell,
                                'Purpose',
                                property.listingPurpose,
                              ),

                              _buildDetail(
                                context,
                                Icons.check_circle,
                                'Status',
                                property.status,
                              ),

                              if (!isLand && property.bedrooms != null)
                                _buildDetail(
                                  context,
                                  Icons.bed,
                                  'Bedrooms',
                                  '${property.bedrooms}',
                                ),

                              if (!isLand && property.bathrooms != null)
                                _buildDetail(
                                  context,
                                  Icons.bathroom,
                                  'Bathrooms',
                                  '${property.bathrooms}',
                                ),

                              _buildDetail(
                                context,
                                Icons.square_foot,
                                'Size',
                                '${property.sizeSqm} sqm',
                              ),

                              _buildDetail(
                                context,
                                Icons.visibility,
                                'Views',
                                '${property.viewCount}',
                              ),

                              _buildDetail(
                                context,
                                Icons.public,
                                'Visibility',
                                property.isPubliclyVisible
                                    ? 'Public'
                                    : 'Private',
                              ),

                              _buildDetail(
                                context,
                                Icons.calendar_today,
                                'Listed',
                                '${property.createdAt.day}/${property.createdAt.month}/${property.createdAt.year}',
                              ),
                            ],
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // 📜 DESCRIPTION
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Description',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(property.description),
                            ],
                          ),

                          // 🔒 LOCK SECTION
                          if (!property.isUnlocked && !isOwner)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.mangoOrange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.mangoOrange
                                      .withOpacity(0.4),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.lock,
                                        color: AppColors.mangoOrange,
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Expanded(
                                        child: Text(
                                          'Full Details Locked',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                color:
                                                    AppColors.mangoOrange,
                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  const Text(
                                    'Unlock this property to view full description, exact location, and contact details.',
                                  ),

                                  const SizedBox(height: AppSpacing.sm),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Unlock Fee'),
                                      Text(
                                        'MWK ${property.unlockFee.toStringAsFixed(0)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color:
                                                  AppColors.mangoOrange,
                                              fontWeight:
                                                  FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: AppSpacing.sm),

                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style:
                                          ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppColors.mangoOrange,
                                      ),
                                      onPressed: () {
                                        if (!isLoggedIn) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const LoginScreen(),
                                            ),
                                          );
                                          return;
                                        }

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                PropertyUnlockScreen(
                                              propertyId: property.id,
                                              propertyTitle:
                                                  property.title,
                                              unlockFee:
                                                  property.unlockFee,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Unlock for MWK ${property.unlockFee.toStringAsFixed(0)}',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: AppSpacing.md),

                          // 👤 OWNER
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.outline.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Property Owner',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor:
                                          AppColors.mangoOrange
                                              .withOpacity(0.1),
                                      child: Icon(
                                        Icons.person,
                                        color:
                                            AppColors.mangoOrange,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              property.ownerName,
                                              style: const TextStyle(
                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                              overflow:
                                                  TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Icon(
                                            Icons.verified,
                                            color: Theme.of(context).colorScheme.primary,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          
                          // ================= RELATED PROPERTIES =================
const SizedBox(height: 25),

Text(
  "Related Properties",
  style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
),

const SizedBox(height: 10),

SizedBox(
  height: 340,
  child:relatedAsync.when(
        data: (items) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return SizedBox(
                width: 280,
                child: PropertyCard(property: items[index]),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) {
  print(e);
  print(stack);

  return Center(
    child: Text(
      "Failed to load related properties\n$e",
      textAlign: TextAlign.center,
    ),
  );
},
      ),
),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // ✅ FLOATING MAP BUTTON
              if (property.isUnlocked)
                Positioned(
                  bottom: 20,
                  right: 16,
                  child: FloatingActionButton(
                    backgroundColor: AppColors.mangoOrange,
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => ShopMapModal(
                          shopLat: property.latitude,
                          shopLng: property.longitude,
                        ),
                      );
                    },
                    child: const Icon(Icons.map),
                  ),
                ),
            ],
          );
        },

        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.mangoOrange,
          ),
        ),

        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: AppSpacing.md),
              Text('Error: $error'),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () =>
                    ref.refresh(propertyDetailsProvider(propertyId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildDetail(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).colorScheme.outline.shade200),
      ),
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.mangoOrange,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style:
                      Theme.of(context).textTheme.labelSmall,
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}