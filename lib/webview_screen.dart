import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mrcoach/widgets/iframe_platform.dart';

class Shop1Screen extends StatefulWidget {
  const Shop1Screen({super.key});

  @override
  State<Shop1Screen> createState() => _Shop1ScreenState();
}

class _Shop1ScreenState extends State<Shop1Screen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse('https://druxx-health-store.vercel.app/'));
    }
  }

  Future<void> _launchWeb() async {
    final uri = Uri.parse('https://druxx-health-store.vercel.app/');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Shop"),
          actions: [
            IconButton(
              icon: const Icon(Icons.open_in_new),
              onPressed: _launchWeb,
              tooltip: 'Open in new tab',
            ),
          ],
        ),
        body: getIFrameWidget('https://druxx-health-store.vercel.app/'),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Shop")),
      body: WebViewWidget(controller: _controller),
    );
  }
}

class EventWebViewScreen extends StatefulWidget {
  final String title;
  final String url;
  final bool allowAnyDomain;
  const EventWebViewScreen({super.key, required this.title, required this.url, this.allowAnyDomain = false});

  @override
  State<EventWebViewScreen> createState() => _EventWebViewScreenState();
}

class _EventWebViewScreenState extends State<EventWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _canGoBack = false;
  late final String _validatedUrl;

  @override
  void initState() {
    super.initState();

    // 1. Enforce absolute URL formatting and resolve relative paths
    String targetUrl = widget.url.trim();
    if (!targetUrl.startsWith('https://mrcoach.in')) {
      if (targetUrl.startsWith('/')) {
        targetUrl = 'https://mrcoach.in$targetUrl';
      } else {
        // Resolve a plain ID or slug
        if (!widget.allowAnyDomain) {
          targetUrl = 'https://mrcoach.in/events/$targetUrl';
        }
      }
    }

    // 2. Reject URLs that do not belong to the website domain (Fallback to default events list page)
    if (!widget.allowAnyDomain && !targetUrl.startsWith('https://mrcoach.in')) {
      targetUrl = 'https://mrcoach.in/events';
    }

    _validatedUrl = targetUrl;

    if (!kIsWeb) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onNavigationRequest: (NavigationRequest request) {
              final url = request.url;
              if (widget.allowAnyDomain) {
                return NavigationDecision.navigate;
              }
              // Only navigate if it is the verified mrcoach.in domain, razorpay checkout, or payment route
              if (url.startsWith('https://mrcoach.in') ||
                  url.contains('razorpay') ||
                  url.contains('api/payment') ||
                  url.contains('checkout')) {
                return NavigationDecision.navigate;
              }
              debugPrint('Blocked external redirection: $url');
              return NavigationDecision.prevent;
            },
            onPageStarted: (String url) {
              setState(() {
                _isLoading = true;
              });
            },
            onPageFinished: (String url) async {
              setState(() {
                _isLoading = false;
              });
              final canBack = await _controller.canGoBack();
              setState(() {
                _canGoBack = canBack;
              });
            },
          ),
        )
        ..loadRequest(Uri.parse(_validatedUrl));
    }
  }

  Future<void> _launchWeb() async {
    final uri = Uri.parse(_validatedUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.title.toUpperCase(),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.open_in_new, color: Colors.black),
              onPressed: _launchWeb,
              tooltip: 'Open in new tab',
            ),
          ],
        ),
        body: getIFrameWidget(_validatedUrl),
      );
    }

    return PopScope(
      canPop: !_canGoBack,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_canGoBack) {
          await _controller.goBack();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () async {
              if (await _controller.canGoBack()) {
                await _controller.goBack();
              } else {
                Navigator.pop(context);
              }
            },
          ),
          title: Text(
            widget.title.toUpperCase(),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: false,
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF9C413)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}