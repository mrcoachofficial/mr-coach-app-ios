import 'package:flutter/foundation.dart';
enum ServiceCategory {
  diet,
  fitness,
  yoga,
  events,
  physio,
  nutrition,
  other, sports, therapy,
}

extension ServiceCategoryX on ServiceCategory {
  String get label {
    switch (this) {
      case ServiceCategory.diet:      return 'Diet';
      case ServiceCategory.fitness:   return 'Fitness';
      case ServiceCategory.yoga:      return 'Yoga';
      case ServiceCategory.events:    return 'Events';
      case ServiceCategory.physio:    return 'Physio';
      case ServiceCategory.nutrition: return 'Nutrition';
      case ServiceCategory.other:     return 'Other';
      case ServiceCategory.sports:    return 'Sports';
      case ServiceCategory.therapy:   return 'Therapy';
    }
  }

  String get emoji {
    switch (this) {
      case ServiceCategory.diet:      return '🥗';
      case ServiceCategory.fitness:   return '🏋️';
      case ServiceCategory.yoga:      return '🧘';
      case ServiceCategory.events:    return '🏅';
      case ServiceCategory.physio:    return '🩺';
      case ServiceCategory.nutrition: return '💊';
      case ServiceCategory.other:     return '📋';
      case ServiceCategory.sports:    return '⚽';
      case ServiceCategory.therapy:   return '🏥';
    }
  }

  int get colorValue {
    switch (this) {
      case ServiceCategory.diet:      return 0xFFFFD54F;
      case ServiceCategory.fitness:   return 0xFFFF7043;
      case ServiceCategory.yoga:      return 0xFF7C4DFF;
      case ServiceCategory.events:    return 0xFF00BCD4;
      case ServiceCategory.physio:    return 0xFF26A69A;
      case ServiceCategory.nutrition: return 0xFF66BB6A;
      case ServiceCategory.other:     return 0xFFBDBDBD;
      case ServiceCategory.sports:    return 0xFFFFC107;
      case ServiceCategory.therapy:   return 0xFFFF4081;
    }
  }

  int get darkColorValue {
    switch (this) {
      case ServiceCategory.diet:      return 0xFF1A1200;
      case ServiceCategory.fitness:   return 0xFF7F1C00;
      case ServiceCategory.yoga:      return 0xFF311B92;
      case ServiceCategory.events:    return 0xFF006064;
      case ServiceCategory.physio:    return 0xFF004D40;
      case ServiceCategory.nutrition: return 0xFF1B5E20;
      case ServiceCategory.other:     return 0xFF424242;
      case ServiceCategory.sports:    return 0xFFFFC107;
      case ServiceCategory.therapy:   return 0xFFFF4081;
    }
  }

  int get lightColorValue {
    switch (this) {
      case ServiceCategory.diet:      return 0xFFFFF8D6;
      case ServiceCategory.fitness:   return 0xFFFBE9E7;
      case ServiceCategory.yoga:      return 0xFFEDE7F6;
      case ServiceCategory.events:    return 0xFFE0F7FA;
      case ServiceCategory.physio:    return 0xFFE0F2F1;
      case ServiceCategory.nutrition: return 0xFFE8F5E9;
      case ServiceCategory.other:     return 0xFFF5F5F5;
      case ServiceCategory.sports:    return 0xFFFFF8E1;
      case ServiceCategory.therapy:   return 0xFFFFEBEE;
    }
  }
}

enum BookingType   { demo, enquire }
enum ServiceMode   { home, online }
enum BookingStatus { active, completed, cancelled }

class BookedService {
  final String id;
  final String name;
  final String emoji;

  const BookedService({
    required this.id,
    required this.name,
    required this.emoji,
  });
}

class Booking {
  final String          bookingId;
  final ServiceCategory serviceCategory;
  final String          sourceScreen;
  final BookedService   service;
  final BookingType     type;
  final ServiceMode     serviceMode;
  BookingStatus         status;

  final DateTime? sessionDate;
  final String?   timeSlot;
  final String?   address;
  final int?      sessionCount;
  final String?   customerName;
  final String?   customerPhone;
  final String?   enquirerName;
  final String?   enquirerPhone;
  final String?   doubtMessage;
  final DateTime  bookedAt;
  final List<BookedService>? additionalServices;

  Booking({
    required this.bookingId,
    required this.serviceCategory,
    required this.sourceScreen,
    required this.service,
    required this.type,
    required this.serviceMode,
    this.status = BookingStatus.active,
    this.sessionDate,
    this.timeSlot,
    this.address,
    this.sessionCount,
    this.customerName,
    this.customerPhone,
    this.enquirerName,
    this.enquirerPhone,
    this.doubtMessage,
    required this.bookedAt,
    required int totalAmount,
    this.additionalServices,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    final name = (json['serviceName'] ?? '').toString().toLowerCase();
    ServiceCategory cat = ServiceCategory.other;
    if (name.contains('diet')) {
      cat = ServiceCategory.diet;
    } else if (name.contains('fitness') || name.contains('gym') || name.contains('strength')) {
      cat = ServiceCategory.fitness;
    } else if (name.contains('yoga')) {
      cat = ServiceCategory.yoga;
    } else if (name.contains('event')) {
      cat = ServiceCategory.events;
    } else if (name.contains('physio')) {
      cat = ServiceCategory.physio;
    } else if (name.contains('nutrition')) {
      cat = ServiceCategory.nutrition;
    } else if (name.contains('sport')) {
      cat = ServiceCategory.sports;
    } else if (name.contains('therapy')) {
      cat = ServiceCategory.therapy;
    }

    BookingType type = BookingType.enquire;
    if (json['bookingType']?.toString().toLowerCase() == 'demo') {
      type = BookingType.demo;
    }

    BookingStatus status = BookingStatus.active;
    final jsonStatus = json['status']?.toString().toLowerCase();
    if (jsonStatus == 'completed') {
      status = BookingStatus.completed;
    } else if (jsonStatus == 'cancelled') {
      status = BookingStatus.cancelled;
    } else {
      status = BookingStatus.active;
    }

    final List<BookedService>? additionalServices = json['additionalServices'] != null
        ? (json['additionalServices'] as List)
            .map((item) => BookedService(
                  id: item['id'] ?? item['_id'] ?? '',
                  name: item['name'] ?? '',
                  emoji: item['emoji'] ?? '➕',
                ))
            .toList()
        : null;

    return Booking(
      bookingId: json['_id'] ?? '',
      serviceCategory: cat,
      sourceScreen: 'dynamic',
      service: BookedService(
        id: json['_id'] ?? '',
        name: json['serviceName'] ?? 'Service',
        emoji: cat.emoji,
      ),
      type: type,
      serviceMode: json['mode'] == 'Home Visit' ? ServiceMode.home : ServiceMode.online,
      status: status,
      sessionDate: json['date'] != null ? DateTime.tryParse(json['date'].toString()) : null,
      timeSlot: json['time'],
      address: json['address'],
      customerName: json['customerName'] ?? json['enquirerName'] ?? '',
      customerPhone: json['mobileNumber'],
      enquirerName: json['enquirerName'] ?? '',
      enquirerPhone: json['mobileNumber'],
      bookedAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now() : DateTime.now(),
      totalAmount: (json['price'] as num?)?.toInt() ?? 0,
      additionalServices: additionalServices,
    );
  }

  int get totalAmount =>
      type == BookingType.demo ? 99 * (sessionCount ?? 1) : 0;

  get paymentId => null;

  get notes => null;
}

class BookingStore extends ChangeNotifier {
  BookingStore._();
  static final BookingStore instance = BookingStore._();

  final List<Booking> _bookings = [];

  List<Booking> get bookings =>
      List.unmodifiable(_bookings.reversed.toList());

  List<Booking> get all => bookings;

  List<Booking> byCategory(ServiceCategory cat) =>
      bookings.where((b) => b.serviceCategory == cat).toList();

  List<Booking> byStatus(BookingStatus s) =>
      bookings.where((b) => b.status == s).toList();

  void addBooking(Booking booking) {
    _bookings.add(booking);
    notifyListeners();
  }

  void setBookings(List<Booking> list) {
    _bookings.clear();
    _bookings.addAll(list);
    notifyListeners();
  }

  void updateStatus(String bookingId, BookingStatus newStatus) {
    final idx = _bookings.indexWhere((b) => b.bookingId == bookingId);
    if (idx != -1) {
      _bookings[idx].status = newStatus;
      notifyListeners();
    }
  }

  void removeBooking(String bookingId) {
    _bookings.removeWhere((b) => b.bookingId == bookingId);
    notifyListeners();
  }

  int get totalCount      => _bookings.length;
  int get demoCount       => _bookings.where((b) => b.type == BookingType.demo).length;
  int get enquiryCount    => _bookings.where((b) => b.type == BookingType.enquire).length;
  int get totalAmountPaid => _bookings
      .where((b) => b.type == BookingType.demo)
      .fold(0, (s, b) => s + b.totalAmount);
}