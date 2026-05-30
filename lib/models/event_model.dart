// lib/models/events/event_model.dart

import 'event_ticket_type_model.dart';

class EventModel {
  final int id;
  final String title;
  final String description;
  final String venue;
  final String district;
  final String city;

  // 🧭 GPS
  final double? latitude;
  final double? longitude;

  final String eventDate;
  final String startTime;
  final String endTime;
  final String banner;

  final double ticketPrice;
  final int totalTickets;
  final int availableTickets;
  final bool isFeatured;

  // 📞 Organizer phone number
  final String? organizerPhoneNumber;

  // 🎟️ Ticket types (VIP / VVIP / REGULAR)
  final List<EventTicketTypeModel> ticketTypes;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.venue,
    required this.district,
    required this.city,
    this.latitude,
    this.longitude,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.banner,
    required this.ticketPrice,
    required this.totalTickets,
    required this.availableTickets,
    required this.isFeatured,
    this.organizerPhoneNumber,
    required this.ticketTypes,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      venue: json['venue'] ?? '',
      district: json['district'] ?? '',
      city: json['city'] ?? '',

      // 🧭 GPS
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,

      eventDate: json['event_date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      banner: json['banner'] ?? '',

      ticketPrice:
          double.tryParse(json['ticket_price'].toString()) ?? 0.0,

      totalTickets: json['total_tickets'] ?? 0,
      availableTickets: json['available_tickets'] ?? 0,
      isFeatured: json['is_featured'] ?? false,

      // 📞 Organizer phone number
      organizerPhoneNumber: json['organizer_phone_number'],

      // 🎟️ Ticket types
      ticketTypes: (json['ticket_types'] as List? ?? [])
          .map((e) => EventTicketTypeModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'venue': venue,
      'district': district,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'event_date': eventDate,
      'start_time': startTime,
      'end_time': endTime,
      'banner': banner,
      'ticket_price': ticketPrice,
      'total_tickets': totalTickets,
      'available_tickets': availableTickets,
      'is_featured': isFeatured,
      'organizer_phone_number': organizerPhoneNumber,
      'ticket_types': ticketTypes.map((e) => e.toJson()).toList(),
    };
  }
}