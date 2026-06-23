import 'package:flutter/material.dart';
import 'app_state.dart';
import 'services/storage_service.dart';
import 'screens/main_menu_screen.dart';
import 'themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = StorageService();
  await storage.init();
  final appState = AppState(storage);
  await appState.init();

  runApp(SudokuApp(appState: appState));
}

class SudokuApp extends StatelessWidget {
  final AppState appState;
  const SudokuApp({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final isDark = appState.settings.darkMode;
        final fontScale = appState.settings.fontScale;
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(fontScale)),
          child: MaterialApp(
            title: 'Sudoku',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            home: MainMenuScreen(state: appState),
          ),
        );
      },
    );
  }
}
