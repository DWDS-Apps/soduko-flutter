import 'package:flutter/material.dart';
import '../app_state.dart';

class SettingsScreen extends StatelessWidget {
  final AppState state;
  const SettingsScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          final s = state.settings;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SectionHeader(title: 'Appearance'),
              const SizedBox(height: 8),
              _SettingsTile(
                  icon: Icons.dark_mode,
                  title: 'Dark Mode',
                  subtitle: 'Use dark color theme',
                  trailing: Switch(
                      value: s.darkMode,
                      onChanged: (v) => state.setDarkMode(v))),
              const Divider(height: 1),
              const SizedBox(height: 24),
              _SectionHeader(title: 'Gameplay'),
              const SizedBox(height: 8),
              _SettingsTile(
                  icon: Icons.lightbulb,
                  title: 'Auto Check Mistakes',
                  subtitle: 'Show incorrect entries in red',
                  trailing: Switch(
                      value: s.autoCheckMistakes,
                      onChanged: (v) => state.setAutoCheckMistakes(v))),
              const Divider(height: 1),
              _SettingsTile(
                  icon: Icons.highlight_alt,
                  title: 'Highlight Duplicates',
                  subtitle: 'Highlight same numbers',
                  trailing: Switch(
                      value: s.highlightDuplicates,
                      onChanged: (v) => state.setHighlightDuplicates(v))),
              const Divider(height: 1),
              const SizedBox(height: 24),
              _SectionHeader(title: 'Sound & Vibration'),
              const SizedBox(height: 8),
              _SettingsTile(
                  icon: Icons.volume_up,
                  title: 'Sound Effects',
                  subtitle: 'Play sounds on interactions',
                  trailing: Switch(
                      value: s.soundEnabled,
                      onChanged: (v) => state.setSoundEnabled(v))),
              const Divider(height: 1),
              _SettingsTile(
                  icon: Icons.vibration,
                  title: 'Vibration',
                  subtitle: 'Vibrate on interactions',
                  trailing: Switch(
                      value: s.vibrationEnabled,
                      onChanged: (v) => state.setVibrationEnabled(v))),
              const Divider(height: 1),
              const SizedBox(height: 24),
              _SectionHeader(title: 'Display'),
              const SizedBox(height: 8),
              _SettingsTile(
                  icon: Icons.timer,
                  title: 'Show Timer',
                  subtitle: 'Display game timer during play',
                  trailing: Switch(
                      value: s.showTimer,
                      onChanged: (v) => state.setShowTimer(v))),
              const Divider(height: 1),
              _SettingsTile(
                  icon: Icons.handyman,
                  title: 'Left-Handed Mode',
                  subtitle: 'Optimize for left-handed use',
                  trailing: Switch(
                      value: s.leftHandedMode,
                      onChanged: (v) => state.setLeftHandedMode(v))),
              const Divider(height: 1),
              const SizedBox(height: 24),
              _SectionHeader(title: 'Accessibility'),
              const SizedBox(height: 8),
              _SettingsTile(
                icon: Icons.text_fields,
                title: 'Font Size',
                subtitle: 'Adjust text size throughout the app',
                trailing: SegmentedButton<double>(
                  segments: const [
                    ButtonSegment(value: 0.85, label: Text('S')),
                    ButtonSegment(value: 1.0, label: Text('M')),
                    ButtonSegment(value: 1.25, label: Text('L')),
                    ButtonSegment(value: 1.5, label: Text('XL')),
                  ],
                  selected: {s.fontScale},
                  onSelectionChanged: (v) => state.setFontScale(v.first),
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
              const Divider(height: 1),
              const SizedBox(height: 32),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Reset Settings'),
                        content: const Text('Reset all settings to default?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                state.resetSettings();
                              },
                              child: const Text('Reset')),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.restore, color: Colors.red),
                  label: const Text('Reset to Defaults',
                      style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
            letterSpacing: 1));
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  const _SettingsTile(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.trailing});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: trailing,
    );
  }
}
