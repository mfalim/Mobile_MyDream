import 'package:w51/core/storage/storage_keys.dart';
import 'package:w51/core/utils/json_helpers.dart';
import 'package:w51/features/auth/domain/entities/app_user.dart';

abstract final class UserCodec {
  static Map<String, dynamic> encode(AppUser user) => {
        'v': kStorageVersion,
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'username': user.username,
        'has_password': user.hasPassword,
        'avatar': user.avatarUrl,
        'role': user.role,
        'call_sign': user.callSign,
      };

  /// Null bila data tidak ada, berformat lama, atau tidak lengkap.
  static AppUser? decode(Map<String, dynamic>? json) {
    if (json == null || json['v'] != kStorageVersion) return null;
    final id = jsonString(json['id']);
    final name = jsonString(json['name']);
    final username = jsonString(json['username']);
    final email = jsonString(json['email']) ??
        (username != null ? '@$username' : '');
    if (id == null || name == null) return null;
    return AppUser(
      id: id,
      name: name,
      email: email,
      username: username,
      hasPassword: jsonBool(json['has_password'], fallback: true),
      avatarUrl: jsonString(json['avatar']),
      role: jsonString(json['role']),
      callSign: jsonString(json['call_sign']),
    );
  }

  /// Buat AppUser dari respons JSON /api/auth/* (isi dari key "data").
  /// [data] adalah isi dari {"data": { "user": {...}, "token": "...", ... }}
  static AppUser fromApiResponse(Map<String, dynamic> data) {
    final userMap = data['user'] as Map<String, dynamic>? ?? {};
    final memberMap = data['member'] is Map<String, dynamic>
        ? data['member'] as Map<String, dynamic>
        : (userMap['member'] is Map<String, dynamic>
            ? userMap['member'] as Map<String, dynamic>
            : null);
    final callSign = jsonString(memberMap?['call_sign']);
    final username = jsonString(userMap['username']);
    final email = jsonString(userMap['email']) ??
        (username != null ? '@$username' : '');
    final hasPassword = jsonBool(
      data['has_password'] ?? userMap['has_password'],
      fallback: false,
    );

    return AppUser(
      id: userMap['id']?.toString() ?? '',
      name: jsonString(userMap['name']) ?? '',
      email: email,
      username: username,
      hasPassword: hasPassword,
      avatarUrl: jsonString(userMap['avatar']),
      role: jsonString(data['role']) ?? jsonString(userMap['role']),
      callSign: callSign,
    );
  }
}
