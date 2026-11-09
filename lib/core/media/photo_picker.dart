import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

enum PhotoSource { gallery, camera }

class PickedPhoto {
  const PickedPhoto({
    required this.path,
    required this.name,
    required this.bytes,
  });

  final String path;
  final String name;
  final int bytes;
}

/// Kamera atau galeri tidak bisa dibuka (izin ditolak atau tidak tersedia).
class PhotoUnavailableException implements Exception {
  const PhotoUnavailableException(this.source);

  final PhotoSource source;
}

/// Pemilih foto. Dibungkus supaya bisa diganti di tes.
abstract interface class PhotoPicker {
  /// Null bila pengguna membatalkan.
  Future<PickedPhoto?> pick(PhotoSource source);
}

class ImagePickerPhotoPicker implements PhotoPicker {
  ImagePickerPhotoPicker([ImagePicker? picker])
      : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<PickedPhoto?> pick(PhotoSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source == PhotoSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (file == null) return null;
      return PickedPhoto(
        path: file.path,
        name: file.name.contains('.') ? file.name : file.path,
        bytes: await file.length(),
      );
    } on PlatformException {
      throw PhotoUnavailableException(source);
    }
  }
}

final photoPickerProvider = Provider<PhotoPicker>(
  (ref) => ImagePickerPhotoPicker(),
);
