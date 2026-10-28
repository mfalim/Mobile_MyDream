/// Pembaca JSON yang toleran terhadap bentuk data dari Laravel: angka bisa
/// berupa teks decimal ("95000000.00"), boolean bisa 0/1, dan string kosong
/// dianggap tidak ada.
int? jsonInt(Object? v) => switch (v) {
      num n => n.round(),
      String s => double.tryParse(s.trim())?.round(),
      _ => null,
    };

double? jsonDouble(Object? v) => switch (v) {
      num n => n.toDouble(),
      String s => double.tryParse(s.trim()),
      _ => null,
    };

bool jsonBool(Object? v, {bool fallback = false}) => switch (v) {
      bool b => b,
      num n => n != 0,
      String s => s == '1' || s.toLowerCase() == 'true',
      _ => fallback,
    };

/// String yang sudah dirapikan; kosong atau bukan teks menjadi null.
String? jsonString(Object? v) => switch (v) {
      String s => s.trim().isEmpty ? null : s.trim(),
      num n => '$n',
      _ => null,
    };

/// Nama dari string atau objek `{ "name": ... }` (mis. relasi kategori).
String? jsonNameOf(Object? v) => switch (v) {
      String s => jsonString(s),
      Map m => jsonString(m['name']),
      _ => null,
    };
