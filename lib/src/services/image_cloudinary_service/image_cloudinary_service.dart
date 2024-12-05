import 'dart:convert';
import 'dart:async';
import 'dart:developer';


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
    final String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
    if (cloudName.isEmpty) {
      throw Exception('Cloudinary cloud name not configured');
    }
    final String cloudinaryUrl =
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload";
    final String uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';
    if (uploadPreset.isEmpty) {
      throw Exception('Cloudinary upload preset not conifgured');
    }

    var request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl));
    request.fields['upload_preset'] = uploadPreset;
    request.files.add(await http.MultipartFile.fromPath('file', imagePath));

    var response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final data = json.decode(responseData);
      return data['secure_url'];
    } else {
      throw Exception('Failed to upload image to cloudinary');
    }
  }

  // Delete Image using URL
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

  // Delete Image using public ID
  Future<bool> deleteImage(String publicId) async {
    try {
      final String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
      final String apiKey = dotenv.env['CLOUDINARY_API_KEY'] ?? '';
      final String apiSecret = dotenv.env['CLOUDINARY_API_SECRET'] ?? '';

      if (cloudName.isEmpty || apiKey.isEmpty || apiSecret.isEmpty) {
        throw Exception('Cloudinary credentials not properly configured');
      }
  
      log('Deleting image with public ID: $publicId');
      log('Using cloud name: $cloudName');
      
      // Generate the timestamp
      int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Create the string to sign (must be in alphabetical order)
      String toSign = 'public_id=$publicId&timestamp=$timestamp$apiSecret';

      // Generate the signature
      var bytes = utf8.encode(toSign);
      var digest = sha1.convert(bytes);
      String signature = digest.toString();

      var uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/destroy');

      var response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'public_id': publicId,
          'timestamp': timestamp.toString(),
          'api_key': apiKey,
          'signature': signature,
        },
      );

      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody['result'] == 'ok') {
          log('Successfully deleted image from Cloudinary');
          return true;
        } else {
          throw Exception('Failed to delete image: ${responseBody['error']?.toString()}');
        }
      } else {
        throw Exception('Failed to delete image. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      log('Error in deleteImage: $e');
      rethrow;
    }
  }

  // Update Image
  Future<String?> updateImage(String oldImageUrl,String newImagePath)async{
    try{
      if(oldImageUrl.isNotEmpty){
        await deleteImageByUrl(oldImageUrl);
      }

      return await uploadImage(newImagePath);
    }catch(e){
      rethrow;
    }
  }

  // Helper method to extract public ID from URL
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
        
        // Remove version number
        return fullPath.replaceFirst(RegExp(r'v\d+/'), '');
      }
      return null;
    } catch (e) {
      log('Error extracting public ID: $e');
      return null;
    }
  }
}
