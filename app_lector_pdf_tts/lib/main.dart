import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "core/theme.dart";
import "presentation/providers/providers.dart";
import "presentation/screens/home_screen.dart";
import "presentation/screens/settings_screen.dart";
import "presentation/screens/tools_screen.dart";

void main() => runApp(const ProviderScope(child: App()));

class App extends ConsumerWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
        title: "Lector PDF & TTS",
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ref.watch(settingsProvider).dark ? ThemeMode.dark : ThemeMode.light,
        home: const Shell(),
      );
}

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _i = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
        body: IndexedStack(index: _i, children: const [HomeScreen(), ToolsScreen(), SettingsScreen()]),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _i,
          onDestinationSelected: (v) => setState(() => _i = v),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.folder_outlined), label: "Archivos"),
            NavigationDestination(icon: Icon(Icons.build_outlined), label: "Herramientas"),
            NavigationDestination(icon: Icon(Icons.settings_outlined), label: "Ajustes"),
          ],
        ),
      );
}
