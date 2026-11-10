import 'package:w51/core/storage/storage_keys.dart';
import 'package:w51/core/utils/json_helpers.dart';
import 'package:w51/features/auth/domain/entities/app_user.dart';

abstract final class UserCodec {
  static Map<String, dynamic> encode(AppUser user) => {
        'v': kStorageVersion,
        'id': user.id,
        'name': user.name,
        'email': user.email,
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
    final email = jsonString(json['email']);
    if (id == null || name == null || email == null) return null;
    return AppUser(
      id: id,
      name: name,
      email: email,
      hasPassword: jsonBool(json['has_password'], fallback: true),
      avatarUrl: jsonString(json['avatar']),
      role: jsonString(json['role']),
      callSign: jsonString(json['call_sign']),
    );
  }

  /// Buat AppUser dari respons JSON /api/auth/google (isi dari key "data").
  /// [data] adalah isi dari {"data": { "user": {...}, "token": "...", ... }}
  static AppUser fromApiResponse(Map<String, dynamic> data) {
    final userMap = data['user'] as Map<String, dynamic>? ?? {};
    final memberMap = data['member'] is Map<String, dynamic>
        ? data['member'] as Map<String, dynamic>
        : (userMap['member'] is Map<String, dynamic>
            ? userMap['member'] as Map<String, dynamic>
            : null);
    final callSign = jsonString(memberMap?['call_sign']);

    return AppUser(
      id: userMap['id']?.toString() ?? '',
      name: jsonString(userMap['name']) ?? '',
      email: jsonString(userMap['email']) ?? '',
      hasPassword: false,
      avatarUrl: jsonString(userMap['avatar']),
      role: jsonString(data['role']) ?? jsonString(userMap['role']),
      callSign: callSign,
    );
  }
}
