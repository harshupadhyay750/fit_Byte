import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  // Replace with your actual Groq API Key
  final String apiKey = 'YOUR API KEY';
  final String baseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  Future<String> getDietRecommendation(String userInput) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {
              'role': 'system', 
              'content': 'You are a professional nutritionist AI named FitByte AI. Provide concise, helpful nutrition and diet advice.'
            },
            {'role': 'user', 'content': userInput}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        final error = jsonDecode(response.body);
        return 'AI Error: ${error['error']['message'] ?? 'Unknown error'}';
      }
    } catch (e) {
      return 'Connection Error: $e';
    }
  }

  Future<Map<String, dynamic>> getNutritionData(String foodName, double weightGrams) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {
              'role': 'system', 
              'content': 'You are a nutrition data expert. Return ONLY a raw JSON object with the following keys: "calories" (int), "protein" (double), "carbs" (double), "fat" (double). Estimate values based on the food name and weight provided. Do not include any text before or after the JSON.'
            },
            {'role': 'user', 'content': 'Food: $foodName, Weight: $weightGrams grams'}
          ],
          'temperature': 0.1,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String content = data['choices'][0]['message']['content'];
        // Remove any markdown code block markers if present
        content = content.replaceAll('```json', '').replaceAll('```', '').trim();
        return jsonDecode(content);
      } else {
        throw Exception('Failed to get nutrition data');
      }
    } catch (e) {
      return {
        'calories': 0,
        'protein': 0.0,
        'carbs': 0.0,
        'fat': 0.0,
      };
    }
  }

  Future<List<dynamic>> getStructuredDietPlan(String userProfile) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {
              'role': 'system', 
              'content': 'You are a master dietitian. Return ONLY a raw JSON array of 4 meal objects. Each object MUST have: "type" (Breakfast/Lunch/Dinner/Snack), "name" (String), "calories" (int), "protein" (int), "carbs" (int), "fat" (int). Do not include any text before or after the JSON.'
            },
            {'role': 'user', 'content': 'Generate a diet plan for: $userProfile'}
          ],
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String content = data['choices'][0]['message']['content'];
        content = content.replaceAll('```json', '').replaceAll('```', '').trim();
        return jsonDecode(content);
      } else {
        throw Exception('Failed to generate diet plan');
      }
    } catch (e) {
      return [];
    }
  }
}
