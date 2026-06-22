import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  // If you are testing on an Android Emulator, use 'http://10.0.2.2:5000/api'
  // If you are testing on Windows Desktop or Web, use 'http://localhost:5000/api'
  static const String baseUrl = 'https://mrcoachclientbackend-production.up.railway.app/api';
  static final String _sessionCacheBuster = DateTime.now().millisecondsSinceEpoch.toString();
  
  // Static variables to cache home resources in memory between screen pushes/pops
  static List<dynamic>? cachedBanners;
  static Map<String, String>? cachedDynamicImageMap;
  static Map<String, String>? cachedDynamicInnerBannerMap;
  static List<dynamic>? cachedServices;
  static String? cachedServicesHeroImage;

  // Load home resources from SharedPreferences on app startup
  static Future<void> loadCachedHomeResources() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final bannersStr = prefs.getString('cached_banners_json');
      if (bannersStr != null) {
        cachedBanners = jsonDecode(bannersStr);
      }

      final servicesStr = prefs.getString('cached_services_json');
      if (servicesStr != null) {
        cachedServices = jsonDecode(servicesStr);
        final Map<String, String> tileMap = {};
        final Map<String, String> innerMap = {};
        for (var s in cachedServices!) {
          if (s['title'] != null && s['imageUrl'] != null && s['imageUrl'].toString().isNotEmpty) {
            if (s['category'] == 'CategoryBanner') {
              tileMap[s['title']] = s['imageUrl'];
            } else if (s['category'] == 'CategoryInnerBanner') {
              innerMap[s['title']] = s['imageUrl'];
            }
          }
        }
        cachedDynamicImageMap = tileMap;
        cachedDynamicInnerBannerMap = innerMap;
      }

      cachedServicesHeroImage = prefs.getString('cached_services_hero_image');
    } catch (e) {
      // ignore
    }
  }

  // Helper to dynamically rewrite image/media URLs to match the active baseUrl host/origin
  static String getMediaUrl(String url, {int? width}) {
    if (url.isEmpty) return '';

    // Auto-optimize Cloudinary image URLs
    if (url.contains('res.cloudinary.com') && url.contains('/image/upload/')) {
      if (!url.contains('/c_scale') && !url.contains('/q_') && !url.contains('/f_')) {
        final targetWidth = width ?? 400;
        url = url.replaceAll('/image/upload/', '/image/upload/c_scale,w_$targetWidth,q_auto,f_auto/');
      }
      return url; // Cloudinary uses versioned URLs; caching is safe without cache-busters
    }

    final String origin = baseUrl.replaceAll('/api', '');
    String finalUrl = url;
    if (!url.startsWith('http')) {
      finalUrl = '$origin$url';
    } else if (url.contains('localhost:5000')) {
      finalUrl = url.replaceAll('http://localhost:5000', origin);
    }
    
    if (finalUrl.contains('?')) {
      return '$finalUrl&cb=$_sessionCacheBuster';
    } else {
      return '$finalUrl?cb=$_sessionCacheBuster';
    }
  }

  // --- AUTHENTICATION ---

  // 1. Register a new user
  static Future<Map<String, dynamic>> registerUser(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Success! Save the digital ID badge (Token) to the phone
        await saveToken(data['token']);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', data['name'] ?? name);
        await prefs.setString('user_email', data['email'] ?? email);
        return {'success': true, 'message': 'Registration successful!'};
      } else {
        // Backend sent an error (like "User already exists")
        return {'success': false, 'message': data['message'] ?? 'Registration failed'};
      }
    } catch (e) {
      // The phone couldn't even reach the server
      return {'success': false, 'message': 'Could not connect to server. Is the backend running?'};
    }
  }

  // 2. Login existing user
  static Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Success! Save the token
        await saveToken(data['token']);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', data['name'] ?? '');
        await prefs.setString('user_email', data['email'] ?? '');
        return {'success': true, 'message': 'Login successful!'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Invalid email or password'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Could not connect to server. Is the backend running?'};
    }
  }

  // --- SERVICES ---

  // Fetch all services from the database
  static Future<List<dynamic>> getServices() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/services'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_services_json', response.body);
        return data;
      } else {
        return []; // Return empty list on failure
      }
    } catch (e) {
      return []; // Return empty list if connection fails
    }
  }

  // --- EVENTS ---

  // Fetch upcoming events from the database
  static Future<List<dynamic>> getUpcomingEvents([Map<String, String>? filters]) async {
    try {
      var uri = Uri.parse('$baseUrl/events/upcoming');
      if (filters != null && filters.isNotEmpty) {
        uri = uri.replace(queryParameters: filters);
      }
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Fetch completed events from the database
  static Future<List<dynamic>> getCompletedEvents([Map<String, String>? filters]) async {
    try {
      var uri = Uri.parse('$baseUrl/events/completed');
      if (filters != null && filters.isNotEmpty) {
        uri = uri.replace(queryParameters: filters);
      }
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Fetch all time slots from the database
  static Future<List<dynamic>> getSlots() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/admin/slots'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return []; // Return empty list on failure
      }
    } catch (e) {
      return []; // Return empty list if connection fails
    }
  }

  // --- BOOKINGS & PAYMENTS ---

  // Create a Razorpay Order ID
  static Future<Map<String, dynamic>> createRazorpayOrder(double amount) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Please login to book a session'};

      final response = await http.post(
        Uri.parse('$baseUrl/payment/create-order'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'amount': amount}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'orderId': data['order']['id'],
          'key': data['key'],
        };
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to create payment order'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Could not connect to payment server.'};
    }
  }

  // Create a new booking
  static Future<Map<String, dynamic>> createBooking(Map<String, dynamic> bookingData) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Please login to book a session'};

      final response = await http.post(
        Uri.parse('$baseUrl/bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(bookingData),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Booking confirmed!',
          'reward': data['reward'],
        };
      } else {
        return {'success': false, 'message': data['message'] ?? 'Booking failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Could not connect to server.'};
    }
  }

  // Get user's bookings
  static Future<List<dynamic>> getMyBookings() async {
    try {
      final token = await getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/bookings/mybookings'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Fetch user rewards
  static Future<List<dynamic>> getUserRewards() async {
    try {
      final token = await getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/rewards'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Update a reward status
  static Future<bool> updateRewardStatus(String id, String status) async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await http.put(
        Uri.parse('$baseUrl/rewards/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': status}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Fetch user notifications
  static Future<List<dynamic>> getUserNotifications() async {
    try {
      final token = await getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Fetch active home banners
  static Future<List<dynamic>> getActiveBanners() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/home-banners/active'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_banners_json', response.body);
        return data;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Fetch services hero banner image
  static Future<String> getServicesHeroImage() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/services/hero-image?t=${DateTime.now().millisecondsSinceEpoch}'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final imageUrl = data['imageUrl'] ?? '';
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_services_hero_image', imageUrl);
        return imageUrl;
      }
      return '';
    } catch (e) {
      print('Error in getServicesHeroImage: $e');
      return '';
    }
  }

  // Update a notification status
  static Future<bool> updateNotificationStatus(String id, String status) async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await http.put(
        Uri.parse('$baseUrl/notifications/$id/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': status}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // --- MEMORY MANAGEMENT (Saving the Token) ---

  // Saves the token in the phone's secure memory
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Fetches the token (to check if user is already logged in)
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Logs the user out by throwing away the token and cached profile
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
  }

  // Deletes the user account permanently
  static Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/profile/delete-account'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await logout(); // Clear local session files
        return {'success': true, 'message': data['message'] ?? 'Account deleted successfully'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to delete account'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Could not connect to server'};
    }
  }

  // Get cached user name and email
  static Future<Map<String, String>> getCachedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('user_name') ?? 'Enter your name',
      'email': prefs.getString('user_email') ?? '...@gmail.com',
    };
  }

  // Update cached user name and email
  static Future<void> updateCachedProfile(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);
  }

  // Fetch fresh user profile from backend
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        if (data['name'] != null) await prefs.setString('user_name', data['name']);
        if (data['email'] != null) await prefs.setString('user_email', data['email']);
        return data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Upload profile image
  static Future<Map<String, dynamic>> uploadProfileImage(XFile file) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Not logged in'};

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/profile/upload-image'),
      );
      request.headers['Authorization'] = 'Bearer $token';

      final bytes = await file.readAsBytes();

      String mimeType = 'image/jpeg';
      final nameLower = file.name.toLowerCase();
      if (nameLower.endsWith('.png')) {
        mimeType = 'image/png';
      } else if (nameLower.endsWith('.webp')) {
        mimeType = 'image/webp';
      } else if (nameLower.endsWith('.gif')) {
        mimeType = 'image/gif';
      }

      request.files.add(http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: file.name,
        contentType: MediaType.parse(mimeType),
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'profileImage': data['profileImage']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Image upload failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Remove profile image
  static Future<Map<String, dynamic>> removeProfileImage() async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Not logged in'};

      final response = await http.delete(
        Uri.parse('$baseUrl/profile/remove-image'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'profileImage': null};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to remove image'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Update profile details
  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> updateData) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Not logged in'};

      final response = await http.put(
        Uri.parse('$baseUrl/profile/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updateData),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (data['name'] != null && data['email'] != null) {
          await updateCachedProfile(data['name'], data['email']);
        }
        return {'success': true, 'user': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Profile update failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Send Password OTP
  static Future<Map<String, dynamic>> sendPasswordOtp(String currentPassword) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Not logged in'};

      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-password-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'currentPassword': currentPassword}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'OTP sent'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to send OTP'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Verify Password OTP
  static Future<Map<String, dynamic>> verifyPasswordOtp(String otp) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Not logged in'};

      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-password-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'otp': otp}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'OTP verified'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Invalid OTP'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Change Password
  static Future<Map<String, dynamic>> changePassword(String otp, String newPassword) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Not logged in'};

      final response = await http.post(
        Uri.parse('$baseUrl/auth/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'otp': otp, 'newPassword': newPassword}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'Password changed successfully'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to change password'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Update location in profile
  static Future<bool> updateLocation(Map<String, dynamic> locationData) async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await http.put(
        Uri.parse('$baseUrl/profile/update-location'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(locationData),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating location in backend: $e');
      return false;
    }
  }

  // --- REFERRALS ---

  // Fetch referral dashboard stats
  static Future<Map<String, dynamic>?> getReferralDashboard() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/referrals/dashboard'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Fetch referral history
  static Future<List<dynamic>> getReferralHistory() async {
    try {
      final token = await getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/referrals/history'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Fetch referral share link
  static Future<String?> getReferralShareLink() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/referrals/share-link'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['shareLink'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Send Login OTP to Phone
  static Future<Map<String, dynamic>> sendLoginOtp(String phoneNumber, {bool isLogin = false}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'isLogin': isLogin,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'OTP sent',
          'dummyOtp': data['dummyOtp']
        };
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to send OTP'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Verify Login OTP
  static Future<Map<String, dynamic>> verifyLoginOtp(String phoneNumber, String otp, {bool? whatsappUpdates, String? referralCode}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'otp': otp,
          if (whatsappUpdates != null) 'whatsappUpdates': whatsappUpdates,
          if (referralCode != null && referralCode.isNotEmpty) 'referralCode': referralCode,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (data['token'] != null) {
          await saveToken(data['token']);
          await updateCachedProfile(data['name'] ?? 'Enter your name', data['email'] ?? '...@gmail.com');
        }
        return {
          'success': true,
          'user': data,
          'message': 'Logged in successfully'
        };
      } else {
        return {'success': false, 'message': data['message'] ?? 'Invalid OTP'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Login/Register with Google
  static Future<Map<String, dynamic>> loginWithGoogle({String? idToken, String? accessToken}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          if (idToken != null) 'idToken': idToken,
          if (accessToken != null) 'accessToken': accessToken,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (data['token'] != null) {
          await saveToken(data['token']);
          await updateCachedProfile(data['name'] ?? 'Enter your name', data['email'] ?? '...@gmail.com');
        }
        return {
          'success': true,
          'user': data,
          'message': 'Logged in with Google successfully'
        };
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed Google login'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Login/Register with Apple
  static Future<Map<String, dynamic>> loginWithApple({required String identityToken, String? email, String? name}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/apple'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identityToken': identityToken,
          if (email != null) 'email': email,
          if (name != null) 'name': name,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (data['token'] != null) {
          await saveToken(data['token']);
          await updateCachedProfile(data['name'] ?? 'Enter your name', data['email'] ?? '...@gmail.com');
        }
        return {
          'success': true,
          'user': data,
          'message': 'Logged in with Apple successfully'
        };
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed Apple login'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Complete Profile Setup after OTP verification
  static Future<Map<String, dynamic>> completeProfileSetup({
    required String name,
    required String email,
    required int age,
    required String gender,
    required String password,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No session token found. Please log in again.'};
      }

      final response = await http.put(
        Uri.parse('$baseUrl/profile/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'age': age,
          'gender': gender,
          'password': password,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        await updateCachedProfile(name, email);
        return {'success': true, 'user': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to update profile'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // --- NEW COIN REWARDS & CHALLENGES ECOSYSTEM ---

  // Get user's coin wallet
  static Future<Map<String, dynamic>?> getUserWallet() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/rewards/wallet'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get user's coin transaction history
  static Future<List<dynamic>> getCoinTransactions() async {
    try {
      final token = await getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/rewards/transactions'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Get user's challenges with progress
  static Future<List<dynamic>> getChallenges() async {
    try {
      final token = await getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/rewards/challenges'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Update challenge progress
  static Future<Map<String, dynamic>> updateChallengeProgress(String challengeId, double progress) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Not logged in'};

      final response = await http.post(
        Uri.parse('$baseUrl/rewards/challenges/$challengeId/progress'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'progress': progress}),
      );
      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        ...data,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Claim challenge reward
  static Future<Map<String, dynamic>> claimChallengeReward(String challengeId) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Not logged in'};

      final response = await http.post(
        Uri.parse('$baseUrl/rewards/challenges/$challengeId/claim'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        ...data,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Redeem coins for voucher
  static Future<Map<String, dynamic>> redeemCoinsForVoucher(int coins) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Not logged in'};

      final response = await http.post(
        Uri.parse('$baseUrl/rewards/vouchers/redeem'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'coins': coins}),
      );
      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 201,
        ...data,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Get user's vouchers
  static Future<List<dynamic>> getUserVouchers() async {
    try {
      final token = await getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/rewards/vouchers'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Apply voucher code to purchase
  static Future<Map<String, dynamic>> applyVoucher(String voucherCode) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Not logged in'};

      final response = await http.post(
        Uri.parse('$baseUrl/rewards/vouchers/apply'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'voucherCode': voucherCode}),
      );
      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        ...data,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Mark voucher as used
  static Future<Map<String, dynamic>> useVoucher(String voucherCode) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Not logged in'};

      final response = await http.post(
        Uri.parse('$baseUrl/rewards/vouchers/use'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'voucherCode': voucherCode}),
      );
      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        ...data,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
