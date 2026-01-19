import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:turun/app/app_logger.dart';
import 'package:turun/data/model/nutrition/meal_log_model.dart';

/// Service untuk integrasi Gemini AI dalam analisa makanan
class GeminiNutritionService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-lite:generateContent';

  String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  /// Analisa foto makanan menggunakan Gemini Vision
  Future<FoodAnalysisResult?> analyzeFoodImage({
    required File imageFile,
    required int targetCalories,
    required MealType mealType,
  }) async {
    try {
      AppLogger.info(LogLabel.general, 'Analyzing food image with Gemini...');

      // Convert image to base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final mimeType = _getMimeType(imageFile.path);

      // Build prompt
      final prompt = '''
Kamu adalah ahli nutrisi AI. Analisa foto makanan ini dan berikan respons dalam format JSON.

KONTEKS:
- Target kalori untuk ${mealType.displayName}: $targetCalories kkal
- Ini adalah foto makanan yang akan dikonsumsi user

TUGASMU:
1. Identifikasi nama makanan dalam bahasa Indonesia
2. Estimasi kalori (dalam kkal)
3. Tentukan status: PASS (sesuai target ±15%), OVER (melebihi), atau UNDER (kurang)
4. Berikan feedback singkat dan memotivasi dalam bahasa Indonesia

RESPONS DALAM FORMAT JSON SAJA (tanpa markdown):
{
  "food_name": "Nama Makanan",
  "calories": 500,
  "status": "PASS",
  "feedback": "Pesan feedback singkat"
}
''';

      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': prompt},
              {
                'inline_data': {
                  'mime_type': mimeType,
                  'data': base64Image,
                }
              }
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.4,
          'maxOutputTokens': 500,
        }
      };

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final textResponse =
            data['candidates'][0]['content']['parts'][0]['text'] as String;

        // Parse JSON response
        final result = _parseGeminiResponse(textResponse, targetCalories);
        AppLogger.success(
            LogLabel.general, 'Food analyzed: ${result?.foodName}');
        return result;
      } else {
        AppLogger.error(
            LogLabel.general, 'Gemini API error: ${response.statusCode}');
        AppLogger.error(LogLabel.general, 'Response: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      AppLogger.error(
          LogLabel.general, 'Failed to analyze food', e, stackTrace);
      return null;
    }
  }

  /// Analisa dari bytes (untuk camera capture)
  Future<FoodAnalysisResult?> analyzeFoodBytes({
    required Uint8List imageBytes,
    required int targetCalories,
    required MealType mealType,
  }) async {
    try {
      AppLogger.info(LogLabel.general, 'Analyzing food bytes with Gemini...');

      final base64Image = base64Encode(imageBytes);

      final prompt = '''
Kamu adalah ahli nutrisi AI. Analisa foto makanan ini dan berikan respons dalam format JSON.

KONTEKS:
- Target kalori untuk ${mealType.displayName}: $targetCalories kkal
- Ini adalah foto makanan yang akan dikonsumsi user

TUGASMU:
1. Identifikasi nama makanan dalam bahasa Indonesia
2. Estimasi kalori (dalam kkal)
3. Tentukan status: PASS (sesuai target ±15%), OVER (melebihi), atau UNDER (kurang)
4. Berikan feedback singkat dan memotivasi dalam bahasa Indonesia

RESPONS DALAM FORMAT JSON SAJA (tanpa markdown):
{
  "food_name": "Nama Makanan",
  "calories": 500,
  "status": "PASS",
  "feedback": "Pesan feedback singkat"
}
''';

      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': prompt},
              {
                'inline_data': {
                  'mime_type': 'image/jpeg',
                  'data': base64Image,
                }
              }
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.4,
          'maxOutputTokens': 500,
        }
      };

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final textResponse =
            data['candidates'][0]['content']['parts'][0]['text'] as String;

        final result = _parseGeminiResponse(textResponse, targetCalories);
        AppLogger.success(
            LogLabel.general, 'Food analyzed: ${result?.foodName}');
        return result;
      } else {
        AppLogger.error(
            LogLabel.general, 'Gemini API error: ${response.statusCode}');
        return null;
      }
    } catch (e, stackTrace) {
      AppLogger.error(
          LogLabel.general, 'Failed to analyze food bytes', e, stackTrace);
      return null;
    }
  }

  FoodAnalysisResult? _parseGeminiResponse(
      String response, int targetCalories) {
    try {
      // Clean up response - remove markdown code blocks if present
      var cleanResponse = response.trim();
      if (cleanResponse.startsWith('```json')) {
        cleanResponse = cleanResponse.substring(7);
      }
      if (cleanResponse.startsWith('```')) {
        cleanResponse = cleanResponse.substring(3);
      }
      if (cleanResponse.endsWith('```')) {
        cleanResponse = cleanResponse.substring(0, cleanResponse.length - 3);
      }
      cleanResponse = cleanResponse.trim();

      final json = jsonDecode(cleanResponse);

      final calories = json['calories'] as int;
      final statusString = (json['status'] as String).toLowerCase();

      MealStatus status;
      if (statusString == 'pass') {
        status = MealStatus.pass;
      } else if (statusString == 'over') {
        status = MealStatus.over;
      } else {
        status = MealStatus.under;
      }

      return FoodAnalysisResult(
        foodName: json['food_name'] as String,
        calories: calories,
        status: status,
        feedback: json['feedback'] as String,
        targetCalories: targetCalories,
      );
    } catch (e) {
      AppLogger.error(
          LogLabel.general, 'Failed to parse Gemini response: $response');
      return null;
    }
  }

  String _getMimeType(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}

/// Hasil analisa makanan dari Gemini
class FoodAnalysisResult {
  final String foodName;
  final int calories;
  final MealStatus status;
  final String feedback;
  final int targetCalories;

  FoodAnalysisResult({
    required this.foodName,
    required this.calories,
    required this.status,
    required this.feedback,
    required this.targetCalories,
  });

  bool get isOnTarget => status == MealStatus.pass;
  bool get isOverTarget => status == MealStatus.over;
  bool get isUnderTarget => status == MealStatus.under;

  int get calorieDifference => calories - targetCalories;
}
