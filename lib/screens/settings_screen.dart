import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _openAiController = TextEditingController();
  final _anthropicController = TextEditingController();
  bool _obscureOpenAi = true;
  bool _obscureAnthropic = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApiKeys();
  }

  Future<void> _loadApiKeys() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _openAiController.text = prefs.getString('openai_api_key') ?? '';
      _anthropicController.text = prefs.getString('anthropic_api_key') ?? '';

      ApiConfig.setOpenAiApiKey(_openAiController.text);
      ApiConfig.setAnthropicApiKey(_anthropicController.text);

      _isLoading = false;
    });
  }

  Future<void> _saveApiKeys() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('openai_api_key', _openAiController.text);
    await prefs.setString('anthropic_api_key', _anthropicController.text);

    ApiConfig.setOpenAiApiKey(_openAiController.text);
    ApiConfig.setAnthropicApiKey(_anthropicController.text);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('API keys saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _clearApiKeys() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear API Keys?'),
        content: const Text('Are you sure you want to clear all API keys? The app will use template-based workouts.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('openai_api_key');
      await prefs.remove('anthropic_api_key');

      setState(() {
        _openAiController.clear();
        _anthropicController.clear();
      });

      ApiConfig.setOpenAiApiKey(null);
      ApiConfig.setAnthropicApiKey(null);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('API keys cleared')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('AI Settings', style: TextStyle(color: Colors.black87)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(),
              const SizedBox(height: 24),
              const Text(
                'API Configuration',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              _buildApiKeyField(
                controller: _openAiController,
                label: 'OpenAI API Key',
                hint: 'sk-...',
                obscure: _obscureOpenAi,
                onToggleObscure: () {
                  setState(() {
                    _obscureOpenAi = !_obscureOpenAi;
                  });
                },
                helpUrl: 'https://platform.openai.com/api-keys',
              ),
              const SizedBox(height: 16),
              _buildApiKeyField(
                controller: _anthropicController,
                label: 'Anthropic (Claude) API Key',
                hint: 'sk-ant-...',
                obscure: _obscureAnthropic,
                onToggleObscure: () {
                  setState(() {
                    _obscureAnthropic = !_obscureAnthropic;
                  });
                },
                helpUrl: 'https://console.anthropic.com/settings/keys',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveApiKeys,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save API Keys',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _clearApiKeys,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Clear All Keys'),
                ),
              ),
              const SizedBox(height: 24),
              _buildCurrentStatus(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700]),
              const SizedBox(width: 12),
              const Text(
                'AI-Powered Workouts',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Add your own AI API key to generate truly personalized workout plans. Without an API key, the app will use pre-built workout templates.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your API keys are stored locally on your device and never shared.',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiKeyField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscure,
    required VoidCallback onToggleObscure,
    required String helpUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  // In a real app, this would open the URL
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Get your key at: $helpUrl')),
                  );
                },
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('Get Key', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            obscureText: obscure,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: IconButton(
                icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: onToggleObscure,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStatus() {
    final hasKey = ApiConfig.hasApiKey;
    final provider = ApiConfig.preferredProvider;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasKey ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasKey ? Colors.green[200]! : Colors.orange[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasKey ? Icons.check_circle : Icons.warning,
            color: hasKey ? Colors.green[700] : Colors.orange[700],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasKey ? 'AI Enabled' : 'Using Templates',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: hasKey ? Colors.green[700] : Colors.orange[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasKey
                      ? 'Using ${provider == 'openai' ? 'OpenAI' : 'Anthropic'} for workout generation'
                      : 'Add an API key to enable AI-powered workouts',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _openAiController.dispose();
    _anthropicController.dispose();
    super.dispose();
  }
}
