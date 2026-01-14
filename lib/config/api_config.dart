class ApiConfig {
  // API Keys - In production, these should be stored securely
  // Users can add their own API keys in the settings
  static String? _openAiApiKey;
  static String? _anthropicApiKey;

  static const String openAiEndpoint = 'https://api.openai.com/v1/chat/completions';
  static const String anthropicEndpoint = 'https://api.anthropic.com/v1/messages';

  // API Key getters
  static String? get openAiApiKey => _openAiApiKey;
  static String? get anthropicApiKey => _anthropicApiKey;

  // API Key setters
  static void setOpenAiApiKey(String? key) {
    _openAiApiKey = key;
  }

  static void setAnthropicApiKey(String? key) {
    _anthropicApiKey = key;
  }

  // Check if any API key is configured
  static bool get hasApiKey =>
      (_openAiApiKey != null && _openAiApiKey!.isNotEmpty) ||
      (_anthropicApiKey != null && _anthropicApiKey!.isNotEmpty);

  // Get preferred API (prioritize OpenAI, then Anthropic)
  static String? get preferredApiKey {
    if (_openAiApiKey != null && _openAiApiKey!.isNotEmpty) {
      return _openAiApiKey;
    }
    if (_anthropicApiKey != null && _anthropicApiKey!.isNotEmpty) {
      return _anthropicApiKey;
    }
    return null;
  }

  static String get preferredEndpoint {
    if (_openAiApiKey != null && _openAiApiKey!.isNotEmpty) {
      return openAiEndpoint;
    }
    return anthropicEndpoint;
  }

  static String get preferredProvider {
    if (_openAiApiKey != null && _openAiApiKey!.isNotEmpty) {
      return 'openai';
    }
    if (_anthropicApiKey != null && _anthropicApiKey!.isNotEmpty) {
      return 'anthropic';
    }
    return 'none';
  }
}
