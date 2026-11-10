class MemberProfile {
  const MemberProfile({
    required this.id,
    required this.name,
    this.callSign,
    this.phone,
    this.email,
    this.htCode,
    this.domicile,
    this.emergencyName,
    this.emergencyPhone,
    this.positionName,
    this.divisionName,
    this.specializationName,
    this.attendanceStatus,
    this.status,
  });

  final int id;
  final String name;
  final String? callSign;
  final String? phone;
  final String? email;
  final String? htCode;
  final String? domicile;
  final String? emergencyName;
  final String? emergencyPhone;
  final String? positionName;
  final String? divisionName;
  final String? specializationName;
  final String? attendanceStatus;
  final String? status;

  bool get isProfileCompleted =>
      callSign != null && callSign!.trim().isNotEmpty;

  factory MemberProfile.fromJson(Map<String, dynamic> json) {
    final root = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final rawPos = root['position'];
    final rawDiv = root['division'];
    final rawSpec = root['specialization'];

    final posName = rawPos is Map<String, dynamic>
        ? rawPos['name']?.toString()
        : (rawPos is String ? rawPos : root['position_name']?.toString());
    final divName = rawDiv is Map<String, dynamic>
        ? rawDiv['name']?.toString()
        : (rawDiv is String ? rawDiv : root['division_name']?.toString());
    final specName = rawSpec is Map<String, dynamic>
        ? rawSpec['name']?.toString()
        : (rawSpec is String ? rawSpec : root['specialization_name']?.toString());

    return MemberProfile(
      id: root['id'] as int? ?? 0,
      name: root['name']?.toString() ?? '',
      callSign: root['call_sign']?.toString(),
      phone: root['phone']?.toString(),
      email: root['email']?.toString(),
      htCode: root['ht_code']?.toString(),
      domicile: root['domicile']?.toString(),
      emergencyName: root['emergency_name']?.toString(),
      emergencyPhone: root['emergency_phone']?.toString(),
      positionName: posName,
      divisionName: divName,
      specializationName: specName,
      attendanceStatus: root['attendance_status']?.toString(),
      status: root['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'call_sign': callSign,
        'phone': phone,
        'email': email,
        'ht_code': htCode,
        'domicile': domicile,
        'emergency_name': emergencyName,
        'emergency_phone': emergencyPhone,
      };
}

