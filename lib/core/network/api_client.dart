
import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({
    required String baseUrl,
    String? token,
    http.Client? client,
    this.timeout = const Duration(seconds: 30),
  })  : baseUrl = Uri.parse(baseUrl.endsWith('/') ? baseUrl : '$baseUrl/'),
        _token = token,
        _client = client ?? http.Client();

  final Uri baseUrl;
  final Duration timeout;
  final http.Client _client;
  String? _token;

  String? get token => _token;

  void setToken(String? value) {
    _token = value;
  }

  void close() {
    _client.close();
  }

  Future<dynamic> get(
    String path, {
    Map<String, String>? queryParameters,
  }) {
    return _send(
      'GET',
      path,
      queryParameters: queryParameters,
    );
  }

  Future<dynamic> post(
    String path, {
    Map<String, Object?>? body,
  }) {
    return _send('POST', path, body: body);
  }

  Future<dynamic> put(
    String path, {
    Map<String, Object?>? body,
  }) {
    return _send('PUT', path, body: body);
  }

  Future<dynamic> patch(
    String path, {
    Map<String, Object?>? body,
  }) {
    return _send('PATCH', path, body: body);
  }

  Future<dynamic> delete(
    String path, {
    Map<String, Object?>? body,
  }) {
    return _send('DELETE', path, body: body);
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, String>? queryParameters,
    Map<String, Object?>? body,
  }) async {
    final normalizedPath = path.replaceFirst(RegExp(r'^/+'), '');
    var uri = baseUrl.resolve(normalizedPath);
    if (queryParameters != null && queryParameters.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParameters);
    }

    final headers = <String, String>{
      'Accept': 'application/json',
      if (_token != null && _token!.isNotEmpty)
        'Authorization': 'Bearer $_token',
      if (body != null) 'Content-Type': 'application/json',
    };
    final encodedBody = body == null ? null : jsonEncode(body);

    late final http.Response response;
    switch (method) {
      case 'GET':
        response = await _client.get(uri, headers: headers).timeout(timeout);
        break;
      case 'POST':
        response = await _client
            .post(uri, headers: headers, body: encodedBody)
            .timeout(timeout);
        break;
      case 'PUT':
        response = await _client
            .put(uri, headers: headers, body: encodedBody)
            .timeout(timeout);
        break;
      case 'PATCH':
        response = await _client
            .patch(uri, headers: headers, body: encodedBody)
            .timeout(timeout);
        break;
      case 'DELETE':
        response = await _client
            .delete(uri, headers: headers, body: encodedBody)
            .timeout(timeout);
        break;
      default:
        throw ArgumentError.value(method, 'method', 'Unsupported HTTP method');
    }

    final dynamic responseData;
    if (response.body.isEmpty) {
      responseData = null;
    } else {
      try {
        responseData = jsonDecode(response.body);
      } on FormatException {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Server returned an invalid JSON response.',
          responseData: response.body,
        );
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = responseData is Map<String, dynamic>
          ? responseData['message']?.toString() ??
              responseData['error']?.toString() ??
              'Request failed.'
          : 'Request failed.';
      final errors = responseData is Map<String, dynamic>
          ? responseData['errors']
          : null;

      throw ApiException(
        statusCode: response.statusCode,
        message: message,
        errors: errors is Map<String, dynamic> ? errors : null,
        responseData: responseData,
      );
    }

    return responseData;
  }

  // Authentication
  Future<dynamic> loginWithGoogle(String idToken) async {
    final result = await post('auth/google', body: {'id_token': idToken});
    if (result is Map<String, dynamic> &&
        result['data'] is Map<String, dynamic>) {
      final accessToken = result['data']['token'];
      if (accessToken is String) setToken(accessToken);
    }
    return result;
  }

  Future<dynamic> me() => get('me');

  Future<dynamic> logout() async {
    final result = await post('logout');
    setToken(null);
    return result;
  }

  // Public pages and catalog
  Future<dynamic> home() => get('home');

  Future<dynamic> about() => get('about');

  Future<dynamic> store() => get('store');

  Future<dynamic> catalog({Map<String, String>? filters}) =>
      get('catalog', queryParameters: filters);

  Future<dynamic> categories() => get('catalog/categories');

  Future<dynamic> packages({Map<String, String>? filters}) =>
      get('catalog/packages', queryParameters: filters);

  Future<dynamic> package(String slug) => get('catalog/packages/$slug');

  Future<dynamic> vendors({Map<String, String>? filters}) =>
      get('vendors', queryParameters: filters);

  Future<dynamic> vendor(String slug) => get('catalog/vendors/$slug');

  Future<dynamic> members({Map<String, String>? filters}) =>
      get('members', queryParameters: filters);

  Future<dynamic> member(int id) => get('members/$id');

  Future<dynamic> articles({Map<String, String>? filters}) =>
      get('content/articles', queryParameters: filters);

  Future<dynamic> article(String slug) => get('content/articles/$slug');

  Future<dynamic> publicEvents({Map<String, String>? filters}) =>
      get('content/events', queryParameters: filters);

  Future<dynamic> publicEvent(String slug) => get('content/events/$slug');

  Future<dynamic> inspirations({Map<String, String>? filters}) =>
      get('content/inspirations', queryParameters: filters);

  Future<dynamic> inspiration(String slug) =>
      get('content/inspirations/$slug');

  // Cart; requires a signed-in user.
  Future<dynamic> cart() => get('cart');

  Future<dynamic> addPackageToCart(int packageId) =>
      post('cart/packages/$packageId');

  Future<dynamic> addVendorToCart(int vendorId) =>
      post('cart/vendors/$vendorId');

  Future<dynamic> removeVendorFromCart(int vendorId) =>
      delete('cart/vendors/$vendorId');

  Future<dynamic> clearCart() => delete('cart');

  // Client endpoints; require the client role.
  Future<dynamic> clientDashboard() => get('client/dashboard');

  Future<dynamic> clientProfile() => get('client/profile');

  Future<dynamic> saveClientProfile(Map<String, Object?> data) =>
      put('client/profile', body: data);

  Future<dynamic> bookings({Map<String, String>? filters}) =>
      get('client/bookings', queryParameters: filters);

  Future<dynamic> createBooking(Map<String, Object?> data) =>
      post('client/bookings', body: data);

  Future<dynamic> bookingPayments(int bookingId) =>
      get('client/bookings/$bookingId/payments');

  Future<dynamic> submitBookingPayment(
    int bookingId,
    Map<String, Object?> data,
  ) =>
      post('client/bookings/$bookingId/payments', body: data);

  Future<dynamic> clientEvents({Map<String, String>? filters}) =>
      get('client/events', queryParameters: filters);

  Future<dynamic> createClientEvent(Map<String, Object?> data) =>
      post('client/events', body: data);

  // Member endpoints; require the member role.
  Future<dynamic> memberDashboard() => get('member/dashboard');

  Future<dynamic> completeMemberProfile(Map<String, Object?> data) =>
      put('member/profile', body: data);

  Future<dynamic> updateScheduleStatus(int scheduleId, String status) =>
      patch(
        'member/schedules/$scheduleId/status',
        body: {'status': status},
      );

  // Admin endpoints; require an admin token.
  Future<dynamic> adminDashboard() => get('admin/dashboard');

  Future<dynamic> adminIndex(
    String resource, {
    Map<String, String>? filters,
  }) =>
      get('admin/$resource', queryParameters: filters);

  Future<dynamic> adminShow(String resource, int id) =>
      get('admin/$resource/$id');

  Future<dynamic> adminCreate(
    String resource,
    Map<String, Object?> data,
  ) =>
      post('admin/$resource', body: data);

  Future<dynamic> adminUpdate(
    String resource,
    int id,
    Map<String, Object?> data,
  ) =>
      put('admin/$resource/$id', body: data);

  Future<dynamic> adminDelete(String resource, int id) =>
      delete('admin/$resource/$id');

  Future<dynamic> adminCalendar({Map<String, String>? filters}) =>
      get('admin/calendar/events', queryParameters: filters);

  Future<dynamic> adminTracking({Map<String, String>? filters}) =>
      get('admin/tracking', queryParameters: filters);

  Future<dynamic> adminTrackingEvent(int eventId) =>
      get('admin/tracking/events/$eventId');

  Future<dynamic> updateAdminScheduleStatus(int scheduleId, String status) =>
      patch(
        'admin/tracking/schedules/$scheduleId/status',
        body: {'status': status},
      );

  Future<dynamic> updateAdminScheduleTime(
    int scheduleId,
    Map<String, Object?> data,
  ) =>
      patch('admin/tracking/schedules/$scheduleId/time', body: data);

  Future<dynamic> updateBookingStatus(
    int bookingId,
    Map<String, Object?> data,
  ) =>
      patch('admin/tracking/bookings/$bookingId/status', body: data);

  Future<dynamic> adminEvents({Map<String, String>? filters}) =>
      get('admin/events', queryParameters: filters);

  Future<dynamic> createAdminEvent(Map<String, Object?> data) =>
      post('admin/events', body: data);

  Future<dynamic> showAdminEvent(int eventId) => get('admin/events/$eventId');

  Future<dynamic> updateAdminEvent(
    int eventId,
    Map<String, Object?> data,
  ) =>
      put('admin/events/$eventId', body: data);

  Future<dynamic> deleteAdminEvent(int eventId) =>
      delete('admin/events/$eventId');

  Future<dynamic> createAdminVendor(Map<String, Object?> data) =>
      post('vendors', body: data);

  Future<dynamic> updateAdminVendor(
    int vendorId,
    Map<String, Object?> data,
  ) =>
      put('vendors/$vendorId', body: data);

  Future<dynamic> deleteAdminVendor(int vendorId) =>
      delete('vendors/$vendorId');
}

class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.message,
    this.errors,
    this.responseData,
  });

  final int statusCode;
  final String message;
  final Map<String, dynamic>? errors;
  final dynamic responseData;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
