import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/properties_provider.dart';
import '../../models/property_model.dart';
import '../main_tabs_screen.dart'; // Core structural coordinator layout
import 'property_details_screen.dart';
import 'edit_property_screen.dart';
import 'add_property_screen.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/app_toast.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_fab.dart';
import '../../widgets/web_footer.dart';

class MyPropertiesScreen extends ConsumerWidget {
  const MyPropertiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProps = ref.watch(myPropertiesProvider);
    
    // Calculate screen metric profiles for dynamic structural responsiveness
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 900;
    
    // Determine the ideal count of layout grid column configurations
    int crossAxisCount = 1;
    if (screenWidth > 1200) {
      crossAxisCount = 3;
    } else if (screenWidth > 700) {
      crossAxisCount = 2;
    }

    return Stack(
      children: [
        asyncProps.when(
          data: (properties) {
            if (properties.isEmpty) {
              return const Center(
                child: Text("No properties found"),
              );
            }

            // Using CustomScrollView ensures our web footer scrolls along naturally at the bottom
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    vertical: 16,
                    // Centers the dynamic grid layout boundaries on wider desktop environments
                    horizontal: isLargeScreen ? (screenWidth - 1100).clamp(16.0, double.infinity) / 2 : 16,
                  ),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      // Adjusted ratio calculation to accommodate explicit card imagery limits safely
                      childAspectRatio: crossAxisCount == 1 ? 1.2 : 0.88,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final property = properties[index];

                        return GestureDetector(
                          onTap: () {
                            MainTabsScreen.of(context)?.navigateToPropertyDetails(property.id);
                          },
                          child: Card(
                            margin: EdgeInsets.zero, // Margins handled precisely by grid spacing
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ================= IMAGE =================
                                Expanded(
                                  child: property.images.isNotEmpty
                                      ? Image.network(
                                          property.images.first.image,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant
                                              .withOpacity(0.15),
                                          width: double.infinity,
                                          child: const Icon(Icons.home, size: 50),
                                        ),
                                ),

                                // ================= CONTENT & ACTIONS =================
                                ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 4,
                                  ),
                                  title: Text(
                                    property.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    "${property.city} • MWK ${property.price}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // ✏️ EDIT
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                        onPressed: () {
                                          MainTabsScreen.of(context)?.navigateToPropertyForm(property);
                                        },
                                      ),

                                      // 🗑 DELETE
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Theme.of(context).colorScheme.error,
                                        ),
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              title: const Text("Delete Property?"),
                                              content: const Text("This action cannot be undone."),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, false),
                                                  child: const Text("Cancel"),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, true),
                                                  child: const Text("Delete"),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirm == true) {
                                            await ref
                                                .read(propertyActionsProvider)
                                                .deleteProperty(property.id);

                                            ref.invalidate(myPropertiesProvider);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: properties.length,
                    ),
                  ),
                ),

                // Dynamic structural alignment box to prevent FAB overlaps before footer bounds
                const SliverToBoxAdapter(
                  child: SizedBox(height: 60),
                ),

                // ================= WEB FOOTER =================
                // Extends completely across edge layout coordinates globally at the scroll end
                const SliverToBoxAdapter(
                  child: WebFooter(),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text("Error: $e")),
        ),

        // ================= FLOATING ACTION LAYOUT OVERLAY =================
        Positioned(
          bottom: 16,
          right: 16,
          child: AppFab(
            heroTag: "add_property",
            icon: Icons.add,
            tooltip: "Add Property",
            toastMessage: "Create new property",
            onPressed: () {
              MainTabsScreen.of(context)?.navigateToVerifyAddProperty();
            },
          ),
        ),
      ],
    );
  }
}