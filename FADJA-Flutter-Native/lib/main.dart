import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(const FadjaApp());

class FadjaApp extends StatelessWidget {
  const FadjaApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'FADJA',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00D5E8),
            brightness: Brightness.dark,
            surface: const Color(0xFF07172F),
          ),
          scaffoldBackgroundColor: const Color(0xFF06142B),
        ),
        home: const FadjaHome(),
      );
}

class FadjaHome extends StatefulWidget {
  const FadjaHome({super.key});
  @override
  State<FadjaHome> createState() => _FadjaHomeState();
}

class _FadjaHomeState extends State<FadjaHome> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF06142B))
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (request) {
          final uri = Uri.tryParse(request.url);
          if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http') &&
              !request.url.startsWith('file:') &&
              !request.url.contains('localhost')) {
            // Les liens externes sont ouverts dans le navigateur du téléphone.
            // Les ressources distantes de la page locale restent chargées dans la WebView.
            final isResource = request.url.contains('cdn.jsdelivr.net') ||
                request.url.contains('fonts.googleapis.com') ||
                request.url.contains('fonts.gstatic.com');
            if (!isResource && (request.url.contains('google.com/search') ||
                request.url.contains('infotelcom.github.io/FADJA-OFFICIEL') ||
                request.url.startsWith('mailto:') || request.url.startsWith('tel:'))) {
              launchUrl(uri, mode: LaunchMode.externalApplication);
              return NavigationDecision.prevent;
            }
          }
          return NavigationDecision.navigate;
        },
        onPageStarted: (_) => setState(() { _loading = true; _failed = false; }),
        onPageFinished: (_) => setState(() => _loading = false),
        onWebResourceError: (error) {
          if (error.isForMainFrame == true) setState(() { _loading = false; _failed = true; });
        },
      ))
      ..loadFlutterAsset('assets/www/index.html');
  }

  Future<bool> _onBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          final shouldExit = await _onBack();
          if (shouldExit && mounted) await showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Quitter FADJA ?'),
              content: const Text('Voulez-vous fermer l’application ?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Rester')),
                FilledButton(onPressed: () { Navigator.pop(context); Navigator.of(context).maybePop(); }, child: const Text('Quitter')),
              ],
            ),
          );
        },
        child: Scaffold(
          body: SafeArea(
            child: Stack(children: [
              WebViewWidget(controller: _controller),
              if (_loading) const Align(
                alignment: Alignment.topCenter,
                child: LinearProgressIndicator(minHeight: 2, color: Color(0xFF00D5E8)),
              ),
              if (_failed) Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.wifi_off_rounded, size: 48, color: Color(0xFF00D5E8)),
                    const SizedBox(height: 16),
                    const Text('Impossible de charger FADJA', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Vérifiez votre connexion Internet puis réessayez.'),
                    const SizedBox(height: 16),
                    FilledButton.icon(onPressed: () => _controller.reload(), icon: const Icon(Icons.refresh), label: const Text('Réessayer')),
                  ]),
                ),
              ),
            ]),
          ),
        ),
      );
}
