import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';

class CloudinaryService {
  static const String cloudName = "dbnqmarau";
  static const String uploadPreset = "items_and_avatars";


  static Future<Map<String, dynamic>?> uploadCustomItemImage(File file) async {
    final url = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );
    
    final mimeType = lookupMimeType(file.path)?.split('/');

    final request = http.MultipartRequest("POST", url)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = 'custom_items'
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: mimeType != null
              ? MediaType(mimeType[0], mimeType[1])
              : MediaType('image', 'jpeg'),
        ),
      );

    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final json = jsonDecode(responseData);
      return {
        'url': json['secure_url'],
        'publicId': json['public_id'],
      };
    }

    return null;
  }


  static Future<Map<String, dynamic>?> uploadUserAvatarImage(File file) async {
    final url = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    final mimeType = lookupMimeType(file.path)?.split('/');

    final request = http.MultipartRequest("POST", url)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = 'user_avatars'
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: mimeType != null
              ? MediaType(mimeType[0], mimeType[1])
              : MediaType('image', 'jpeg'),
        ),
      );

    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final json = jsonDecode(responseData);
      return {
        'url': json['secure_url'],
        'publicId': json['public_id'],
      };
    }

    return null;
  }


  static Future<File> downloadImageToFile(String url, String fileName) async {
    final response = await http.get(Uri.parse(url));

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');

    await file.writeAsBytes(response.bodyBytes);

    return file;
  }

  // FOR DEBUGGING ONLY!! IN REAL PRODUCTION CODE, DON'T LEAVE THE API'S AT ALL!!!!
  static Future<bool> deleteImageByPublicId(String publicId) async {
    final url = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/destroy",
    );

    final apiSecret = "GJ0omOFkvwG0ER9H09hghKTScj4";

    int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final signature = generateCloudinarySignature(
      publicId: publicId,
      apiSecret: apiSecret,
      timestamp: timestamp);

    final response = await http.post(
      url,
      body: {
        "public_id": publicId,
        "api_key": "341432718117616",
        "timestamp": timestamp.toString(),
        "signature": signature,
      },
    );

    print("(Cloudinary) trying to delete image, response status code: ${response.statusCode}");

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      print("(Cloudinary) trying to delete image, result was: ${json['result']}");
      return json['result'] == 'ok';
    }

    return false;
  }

  static String generateCloudinarySignature({
    required String publicId,
    required String apiSecret,
    required int timestamp,
  }) {
    final data = 'public_id=$publicId&timestamp=$timestamp$apiSecret';

    final bytes = utf8.encode(data);
    final digest = sha1.convert(bytes);

    return digest.toString();
  }
}