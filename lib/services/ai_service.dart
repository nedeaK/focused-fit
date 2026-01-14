import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user_profile.dart';
import '../models/workout.dart';
import '../models/exercise.dart';

class AiService {
  Future<Workout?> generateWorkoutWithAi(UserProfile profile) async {
    final apiKey = ApiConfig.preferredApiKey;
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('No API key configured. Please add an API key in settings.');
    }

    final provider = ApiConfig.preferredProvider;

    try {
      if (provider == 'openai') {
        return await _generateWithOpenAi(profile, apiKey);
      } else if (provider == 'anthropic') {
        return await _generateWithAnthropic(profile, apiKey);
      } else {
        throw Exception('No valid API provider configured');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Workout> _generateWithOpenAi(UserProfile profile, String apiKey) async {
    final prompt = _buildPrompt(profile);

    final response = await http.post(
      Uri.parse(ApiConfig.openAiEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        'model': 'gpt-4o-mini',
        'messages': [
          {
            'role': 'system',
            'content': 'You are a professional fitness trainer creating personalized workout plans. Always respond with valid JSON only, no additional text.'
          },
          {
            'role': 'user',
            'content': prompt,
          }
        ],
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final content = data['choices'][0]['message']['content'];
      return _parseWorkoutFromJson(content, profile);
    } else {
      throw Exception('OpenAI API error: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Workout> _generateWithAnthropic(UserProfile profile, String apiKey) async {
    final prompt = _buildPrompt(profile);

    final response = await http.post(
      Uri.parse(ApiConfig.anthropicEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: json.encode({
        'model': 'claude-3-5-sonnet-20241022',
        'max_tokens': 2000,
        'messages': [
          {
            'role': 'user',
            'content': prompt,
          }
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final content = data['content'][0]['text'];
      return _parseWorkoutFromJson(content, profile);
    } else {
      throw Exception('Anthropic API error: ${response.statusCode} - ${response.body}');
    }
  }

  String _buildPrompt(UserProfile profile) {
    return '''
Create a personalized workout plan with the following requirements:

User Profile:
- Fitness Goal: ${profile.goal}
- Fitness Level: ${profile.fitnessLevel}
- Available Equipment: ${profile.equipment.join(', ')}
- Workout Duration: ${profile.availableTime} minutes
- Injuries/Limitations: ${profile.injuries.isNotEmpty ? profile.injuries.join(', ') : 'None'}

Please generate a workout plan that:
1. Matches the user's fitness level and goals
2. Uses only the available equipment
3. Fits within the time limit (${profile.availableTime} minutes)
4. Is safe and effective

Respond ONLY with valid JSON in this exact format (no markdown, no code blocks, just raw JSON):
{
  "name": "Workout Name",
  "description": "Brief description of the workout",
  "estimatedDuration": ${profile.availableTime},
  "estimatedCalories": 250,
  "difficulty": "${profile.fitnessLevel}",
  "exercises": [
    {
      "name": "Exercise Name",
      "description": "How to perform this exercise with proper form",
      "sets": 3,
      "reps": 12,
      "restSeconds": 60,
      "muscleGroup": "Target muscle group",
      "equipment": "Equipment needed"
    }
  ]
}

Generate 6-8 exercises for this workout. Make it challenging but appropriate for their level.
''';
  }

  Workout _parseWorkoutFromJson(String jsonContent, UserProfile profile) {
    try {
      // Remove markdown code blocks if present
      String cleanJson = jsonContent.trim();
      if (cleanJson.startsWith('```')) {
        cleanJson = cleanJson.replaceAll(RegExp(r'```json\s*'), '');
        cleanJson = cleanJson.replaceAll(RegExp(r'```\s*'), '');
      }

      final data = json.decode(cleanJson);

      final exercises = (data['exercises'] as List)
          .map((e) => Exercise.fromJson(e))
          .toList();

      return Workout(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: data['name'] ?? 'AI Generated Workout',
        description: data['description'] ?? 'Personalized workout plan',
        exercises: exercises,
        estimatedDuration: data['estimatedDuration'] ?? profile.availableTime,
        estimatedCalories: data['estimatedCalories'] ?? 250,
        difficulty: data['difficulty'] ?? profile.fitnessLevel,
      );
    } catch (e) {
      throw Exception('Failed to parse workout JSON: $e\nContent: $jsonContent');
    }
  }
}
