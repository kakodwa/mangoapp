import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/properties_provider.dart';
import '../../models/property_model.dart';
import 'property_details_screen.dart';
import 'edit_property_screen.dart';
import 'add_property_screen.dart';

class MyPropertiesScreen extends ConsumerWidget {
  const MyPropertiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProps = ref.watch(myPropertiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Properties"),
      ),

      // ✅ ADD PROPERTY BUTTON
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddPropertyScreen(),
            ),
          );
        },
      ),

      body: asyncProps.when(
        data: (properties) {
          if (properties.isEmpty) {
            return const Center(
              child: Text("No properties found"),
            );
          }

          return ListView.builder(
            itemCount: properties.length,
            itemBuilder: (context, index) {
              final property = properties[index];

              return GestureDetector(
                onTap: () {
                  // ✅ OPEN DETAIL PAGE
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PropertyDetailsScreen(
                        propertyId: property.id,
                      ),
                    ),
                  );
                },

                child: Card(
                  margin: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ================= IMAGE =================
                      if (property.images.isNotEmpty)
                        Image.network(
                          property.images.first.image, // ✅ correct field
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      else
                        Container(
                          height: 180,
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.25),
                          child: const Icon(Icons.home, size: 50),
                        ),

                      // ================= CONTENT =================
                      ListTile(
                        title: Text(property.title),
                        subtitle: Text(
                          "${property.city} • ${property.price}",
                        ),

                        // ================= ACTIONS =================
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ✏️ EDIT
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              onPressed: () {
                               Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => PropertyFormScreen(property: property),
  ),
);
                              },
                            ),

                            // 🗑 DELETE
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              onPressed: () async {
                                final confirm = await showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text("Delete Property?"),
                                    content: const Text(
                                      "This action cannot be undone.",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
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
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
    );
  }
}