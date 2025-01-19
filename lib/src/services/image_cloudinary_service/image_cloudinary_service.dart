import 'dart:convert';
import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloudinary/cloudinary.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class ImageCloudinaryService {
  final Cloudinary cloudinary;

  ImageCloudinaryService()
      : cloudinary = Cloudinary.signedConfig(
          apiKey: dotenv.env['CLOUDINARY_API_KEY'] ?? '273821957655642',
          apiSecret: dotenv.env['CLOUDINARY_API_SECRET'] ??
              'mW5nEyCUV8Bt4tppImWiogZxSMk',
          cloudName: dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? 'dxityv8dk',
        );

  Future<String> uploadImage(String imagePath) async {
    try {
      final String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
      if (cloudName.isEmpty) {
        throw Exception('Cloudinary cloud name not configured');
      }
      final String cloudinaryUrl =
          "https://api.cloudinary.com/v1_1/$cloudName/image/upload";
      final String uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';
      if (uploadPreset.isEmpty) {
        throw Exception('Cloudinary upload preset not configured');
      }

      // Read the file as bytes instead of creating a new file
      final File imageFile = File(imagePath);
      final bytes = await imageFile.readAsBytes();

      // Create multipart request
      var request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl));
      request.fields['upload_preset'] = uploadPreset;

      // Add file bytes directly without creating a new file
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: imagePath.split('/').last,
        ),
      );

      var response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final data = json.decode(responseData);
        return data['secure_url'];
      } else {
        throw Exception('Failed to upload image to cloudinary');
      }
    } catch (e) {
      log('Error uploading image: $e');
      rethrow;
    }
  }

  Future<List<String>> uploadImages(List<String> imagePaths) async {
    List<String> uploadedUrls = [];

    for (String imagePath in imagePaths) {
      try {
        final url = await uploadImage(imagePath);
        uploadedUrls.add(url);
      } catch (e) {
        log('Error uploading image: $imagePath, $e');
      }
    }
    return uploadedUrls;
  }

  Future<bool> deleteImagesByUrls(List<String> imageUrls) async {
    bool allSuccess = true;
    for (String imageUrl in imageUrls) {
      try {
        final success = await deleteImageByUrl(imageUrl);
        if (!success) {
          allSuccess = false;
        }
      } catch (e) {
        log('Error deleting images: $imageUrl,Error: $e');
        allSuccess = false;
      }
    }
    return allSuccess;
  }

  Future<bool> deleteImageByUrl(String imageUrl) async {
    try {
      if (!imageUrl.contains('cloudinary')) {
        return false;
      }

      final publicId = extractPublicId(imageUrl);
      if (publicId == null) {
        return false;
      }

      return await deleteImage(publicId);
    } catch (e) {
      log('Error in deleteImageByUrl: $e');
      rethrow;
    }
  }

  Future<bool> deleteImage(String publicId) async {
    try {
      final String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
      final String apiKey = dotenv.env['CLOUDINARY_API_KEY'] ?? '';
      final String apiSecret = dotenv.env['CLOUDINARY_API_SECRET'] ?? '';

      if (cloudName.isEmpty || apiKey.isEmpty || apiSecret.isEmpty) {
        throw Exception('Cloudinary credentials not properly configured');
      }

      int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      String toSign = 'public_id=$publicId&timestamp=$timestamp$apiSecret';
      var bytes = utf8.encode(toSign);
      var digest = sha1.convert(bytes);
      String signature = digest.toString();

      var uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/destroy');

      var response = await http.post(
        uri,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'public_id': publicId,
          'timestamp': timestamp.toString(),
          'api_key': apiKey,
          'signature': signature,
        },
      );

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        return responseBody['result'] == 'ok';
      } else {
        throw Exception('Failed to delete image. Status: ${response.statusCode}');
      }
    } catch (e) {
      log('Error in deleteImage: $e');
      rethrow;
    }
  }

  Future<String?> updateImage(String oldImageUrl, String newImagePath) async {
    try {
      if (oldImageUrl.isNotEmpty) {
        await deleteImageByUrl(oldImageUrl);
      }
      return await uploadImage(newImagePath);
    } catch (e) {
      rethrow;
    }
  }

  String? extractPublicId(String imageUrl) {
    try {
      final Uri imageUri = Uri.parse(imageUrl);
      final pathSegments = imageUri.pathSegments;
      final uploadIndex = pathSegments.indexOf('upload');
      if (uploadIndex != -1 && uploadIndex < pathSegments.length - 1) {
        final String fullPath = pathSegments
            .sublist(uploadIndex + 1)
            .join('/')
            .split('.')
            .first;
        return fullPath.replaceFirst(RegExp(r'v\d+/'), '');
      }
      return null;
    } catch (e) {
      log('Error extracting public ID: $e');
      return null;
    }
  }
}
