import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AvatarService {
  final FirebaseStorage _storage;
  final ImagePicker _picker;

  AvatarService({
    required FirebaseStorage storage,
  })  : _storage = storage,
        _picker = ImagePicker();

  /// Picks an image from the specified source (camera or gallery).
  Future<XFile?> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      return image;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  /// Uploads an image to Firebase Storage and returns the download URL.
  Future<String> uploadAvatar({
    required String userId,
    required XFile imageFile,
  }) async {
    try {
      final String fileName = 'avatars/$userId.jpg';
      final Reference ref = _storage.ref().child(fileName);

      UploadTask uploadTask;
      if (kIsWeb) {
        uploadTask = ref.putData(await imageFile.readAsBytes());
      } else {
        uploadTask = ref.putFile(File(imageFile.path));
      }

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      throw Exception('Failed to upload avatar: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred during upload: $e');
    }
  }
}
