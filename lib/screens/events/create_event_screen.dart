import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../../providers/api_provider.dart';
import '../../theme/design_system/app_text_field.dart';
import '../../utils/app_toast.dart';
import '../../widgets/main_app_bar.dart';
import '../../theme/design_system/app_spacing.dart';

class AddEventScreen extends ConsumerStatefulWidget {
  const AddEventScreen({super.key});

  @override
  ConsumerState<AddEventScreen> createState() => _AddEventScreenState();
}

class TicketTypeInput {
  String name;
  TextEditingController price;
  TextEditingController seats;

  TicketTypeInput({
    required this.name,
    required this.price,
    required this.seats,
  });
}

class _AddEventScreenState extends ConsumerState<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final title = TextEditingController();
  final description = TextEditingController();
  final venue = TextEditingController();
  final district = TextEditingController();
  final city = TextEditingController();
  final latitude = TextEditingController();
  final longitude = TextEditingController();
  final date = TextEditingController();
  final startTime = TextEditingController();
  final endTime = TextEditingController();

  bool isFeatured = false;
  bool loading = false;
  bool gettingGps = false;

  final ImagePicker picker = ImagePicker();
  XFile? banner;

  final List<String> ticketTypeOptions = ["regular", "vip", "vvip"];

  String formatTimeOfDay(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');

  return "$hour:$minute:00";
}

  List<TicketTypeInput> ticketTypes = [
    TicketTypeInput(
      name: "regular",
      price: TextEditingController(),
      seats: TextEditingController(),
    )
  ];

  final List<String> malawiDistricts = [
    "Balaka","Blantyre","Chikwawa","Chiradzulu","Chitipa",
    "Dedza","Dowa","Karonga","Kasungu","Likoma","Lilongwe",
    "Machinga","Mangochi","Mchinji","Mulanje","Mwanza",
    "Mzimba","Neno","Nkhata Bay","Nkhotakota","Nsanje",
    "Ntcheu","Ntchisi","Phalombe","Rumphi","Salima",
    "Thyolo","Zomba",
  ];

  // ===================== GPS =====================
Future<void> getGPS() async {
  setState(() => gettingGps = true);

  try {
    bool enabled =
        await Geolocator.isLocationServiceEnabled();

    if (!enabled) {
      AppToast.error(context, "Enable GPS first");
      return;
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        AppToast.error(
          context,
          "Location permission denied",
        );
        return;
      }
    }

    Position pos =
        await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      latitude.text =
          pos.latitude.toStringAsFixed(6);

      longitude.text =
          pos.longitude.toStringAsFixed(6);
    });

    AppToast.success(context, "GPS captured");
  } catch (e) {
    AppToast.error(
      context,
      "Failed to get GPS",
    );
  } finally {
    if (mounted) {
      setState(() => gettingGps = false);
    }
  }
}
  // ===================== IMAGE =====================
  Future<void> pickBanner() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        banner = picked;
      });
    }
  }

  // ===================== DATE PICKER =====================
Future<void> pickDate() async {
  final picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2100),
  );

  if (picked != null) {
    date.text =
        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
  }
}
  // ===================== TIME PICKER =====================
  Future<void> pickTime(TextEditingController controller) async {
  final picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );

  if (picked != null) {
    controller.text = formatTimeOfDay(picked);
  }
}
  // ===================== TICKET =====================
  void addTicketType() {
    setState(() {
      ticketTypes.add(
        TicketTypeInput(
          name: "regular",
          price: TextEditingController(),
          seats: TextEditingController(),
        ),
      );
    });
  }

  void removeTicketType(int i) {
    setState(() {
      ticketTypes.removeAt(i);
    });
  }

  // ===================== SUBMIT =====================
  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (banner == null) {
      AppToast.error(context, "Add event banner");
      return;
    }

    final usedTypes = <String>{};

for (final ticket in ticketTypes) {
  final seats = int.tryParse(ticket.seats.text) ?? 0;

  // CHECK EMPTY SEATS
  if (seats <= 0) {
    AppToast.error(
      context,
      "${ticket.name.toUpperCase()} seats must be greater than 0",
    );
    return;
  }

  // CHECK DUPLICATE TICKET TYPES
  if (usedTypes.contains(ticket.name)) {
    AppToast.error(
      context,
      "${ticket.name.toUpperCase()} already added",
    );
    return;
  }

  usedTypes.add(ticket.name);
}

    setState(() => loading = true);

    try {
      final api = ref.read(apiClientProvider);

      final fields = {
        "title": title.text,
        "description": description.text,
        "venue": venue.text,
        "district": district.text,
        "city": city.text,
        "latitude": latitude.text,
        "longitude": longitude.text,
        "event_date": date.text,
        "start_time": startTime.text,
        "end_time": endTime.text,
        "is_featured": isFeatured.toString(),
        "ticket_types": jsonEncode(
          ticketTypes.map((t) => {
            "name": t.name,
            "price": double.tryParse(t.price.text) ?? 0,
            "total_seats": int.tryParse(t.seats.text) ?? 0,
          }).toList(),
        ),
      };

      await api.uploadMultipart(
        endpoint: "events/",
        fields: fields.map((k, v) => MapEntry(k, v.toString())),
        files: [banner!],
        fileFieldName: "banner",
      );

      if (mounted) {
        AppToast.success(context, "Event created successfully");
        Navigator.pop(context);
      }
    } catch (e) {
      AppToast.error(context, e.toString());
    }

    setState(() => loading = false);
  }

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: const MainAppBar(title: "Create Event"),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.md),
          children: [

            AppTextField(label: "Title", controller: title, type: TextFieldType.text),
            const SizedBox(height: AppSpacing.sm),

            AppTextField(label: "Description", controller: description, type: TextFieldType.multiline),
            const SizedBox(height: AppSpacing.sm),

            AppTextField(label: "Venue", controller: venue, type: TextFieldType.text),
            const SizedBox(height: AppSpacing.sm),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: district.text.isEmpty ? null : district.text,
                    items: malawiDistricts.map((d) {
                      return DropdownMenuItem(value: d, child: Text(d));
                    }).toList(),
                    onChanged: (val) => setState(() => district.text = val!),
                    decoration: const InputDecoration(labelText: "District"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: AppTextField(label: "City", controller: city, type: TextFieldType.text)),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            Row(
  crossAxisAlignment: CrossAxisAlignment.end,
  children: [
    Expanded(
      child: AppTextField(
        label: "Latitude",
        controller: latitude,
        type: TextFieldType.text,
      ),
    ),
    const SizedBox(width: 10),

    Expanded(
      child: AppTextField(
        label: "Longitude",
        controller: longitude,
        type: TextFieldType.text,
      ),
    ),
    const SizedBox(width: 10),

    SizedBox(
      height: 56,
      width: 56,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: gettingGps
            ? Padding(
                padding: const EdgeInsets.all(14),
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Theme.of(context).colorScheme.surface,
                ),
              )
            : IconButton(
                onPressed: getGPS,
                icon: Icon(
                  Icons.my_location,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
      ),
    ),
  ],
),

            const SizedBox(height: AppSpacing.sm),

            GestureDetector(
              onTap: pickDate,
              child: AbsorbPointer(
                child: AppTextField(label: "Event Date", controller: date, type: TextFieldType.text),
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => pickTime(startTime),
                    child: AbsorbPointer(
                      child: AppTextField(label: "Start Time", controller: startTime, type: TextFieldType.text),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => pickTime(endTime),
                    child: AbsorbPointer(
                      child: AppTextField(label: "End Time", controller: endTime, type: TextFieldType.text),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

           const SizedBox(height: AppSpacing.md),

// ===================== TICKET TYPES =====================
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(
      "Ticket Types",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),

    TextButton.icon(
      onPressed: addTicketType,
      icon: Icon(Icons.add),
      label: Text("Add"),
    ),
  ],
),

const SizedBox(height: 10),

...ticketTypes.asMap().entries.map((entry) {
  final i = entry.key;
  final item = entry.value;

  return Container(
    margin: EdgeInsets.only(bottom: 12),
    padding: EdgeInsets.all(AppSpacing.sm),
    decoration: BoxDecoration(
      border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.38)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [

        // TYPE
        DropdownButtonFormField<String>(
          value: item.name,
          items: ticketTypeOptions.map((t) {
            return DropdownMenuItem(
              value: t,
              child: Text(t.toUpperCase()),
            );
          }).toList(),
          onChanged: (val) {
            setState(() => item.name = val!);
          },
          decoration: const InputDecoration(
            labelText: "Ticket Type",
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // PRICE + SEATS
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: item.price,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Price",
                ),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: TextFormField(
                controller: item.seats,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Seats",
                ),
              ),
            ),
          ],
        ),

        // DELETE
        if (ticketTypes.length > 1)
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
              onPressed: () => removeTicketType(i),
            ),
          ),
      ],
    ),
  );
}),

const SizedBox(height: AppSpacing.md),

ElevatedButton(
  onPressed: pickBanner,
  child: Text("Pick Banner Image"),
),

            const SizedBox(height: 10),
            Text(banner == null ? "No image selected" : "Image selected"),

            const SizedBox(height: AppSpacing.md),

            SwitchListTile(
              value: isFeatured,
              onChanged: (v) => setState(() => isFeatured = v),
              title: Text("Featured Event"),
            ),

            const SizedBox(height: AppSpacing.md),

            ElevatedButton(
              onPressed: loading ? null : submit,
              child: loading
                  ? CircularProgressIndicator(color: Theme.of(context).colorScheme.surface)
                  : Text("Create Event"),
            ),
          ],
        ),
      ),
    );
  }
}