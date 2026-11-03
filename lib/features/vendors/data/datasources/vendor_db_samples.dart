/// MOCK: contoh JSON berbentuk database asli (hanya kolom tabel `vendors`;
/// harga berupa teks decimal seperti keluaran Laravel). Dipakai untuk
/// memastikan layar tetap rapi bila API hanya mengirim data minimal.
final Map<String, Map<String, dynamic>> kDatabaseShapedVendorDetails = {
  'vendor-db-katering': {
    'id': 'vendor-db-katering',
    'name': 'Katering Jember',
    'category': 'Catering',
    'price': '100000000.00',
    'phone': '+628000000009',
    'city': null,
    'address': 'Jl. Contoh No. 1, Jember',
    'description': null,
    'instagram': null,
    'photos': <Object>[],
  },
  'vendor-db-dekor': {
    'id': 'vendor-db-dekor',
    'name': 'dekor jember',
    'category': 'Decoration',
    'price': '10000290.00',
    'phone': '+628000000010',
    'city': null,
    'address': 'Jl. Contoh No. 2, Surabaya',
    'description': null,
    'instagram': null,
    'photos': <Object>[],
  },
};
