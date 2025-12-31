import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
// CHECK YOUR IMPORTS
import '../../providers/onboarding_provider.dart';
import '../../../../media/providers/face_liveness_provider.dart';

class SelfieCaptureScreen extends ConsumerStatefulWidget {
  const SelfieCaptureScreen({super.key});

  @override
  ConsumerState<SelfieCaptureScreen> createState() => _SelfieCaptureScreenState();
}

class _SelfieCaptureScreenState extends ConsumerState<SelfieCaptureScreen> {
  // Your Vercel Link
  final String _livenessWebAppUrl = "https://faceliveness-blindly.vercel.app/"; 
  
  bool _isSessionReady = false;
  InAppWebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    _initPermissionsAndSession();
  }

  Future<void> _initPermissionsAndSession() async {
    // 1. Request Native Permissions first
    // (Microphone is required for the browser to release the camera)
    await [
      Permission.camera,
      Permission.microphone,
    ].request();
    
    // 2. Start the Session
    await _startNewSession();
  }

  // --- NEW: Helper to get a fresh ID (Fixes Server Error) ---
  Future<void> _startNewSession() async {
    if (mounted) setState(() => _isSessionReady = false);

    // Call Lambda to generate a BRAND NEW Session ID
    final success = await ref.read(faceLivenessProvider).initLivenessSession();
    
    if (success && mounted) {
      setState(() => _isSessionReady = true);
      
      // If WebView is already open, reload it with the NEW ID
      if (_webViewController != null) {
        final newUrl = "$_livenessWebAppUrl?sessionId=${ref.read(faceLivenessProvider).sessionId}";
        _webViewController!.loadUrl(urlRequest: URLRequest(url: WebUri(newUrl)));
      }
    } else {
      if (mounted) {
        _showErrorDialog("Connection Failed", "Could not create liveness session.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final livenessState = ref.watch(faceLivenessProvider);

    // Loading State
    if (!_isSessionReady || livenessState.sessionId == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 20),
              Text("Creating Secure Session...", style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black, 
      appBar: AppBar(
        title: const Text("Face Verification"), 
        backgroundColor: Colors.black, 
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: InAppWebView(
          // 3. Load Vercel URL with Session ID
          initialUrlRequest: URLRequest(
            url: WebUri("$_livenessWebAppUrl?sessionId=${livenessState.sessionId}"),
          ),
          
          initialSettings: InAppWebViewSettings(
            mediaPlaybackRequiresUserGesture: false,
            allowsInlineMediaPlayback: true, 
            iframeAllowFullscreen: true,
            
            // --- FIX FOR CAMERA NOT ACCESSIBLE ---
            // 1. Remove UserAgent (Let system decide)
            // 2. Clear cache to forget previous errors
            clearCache: true, 
            domStorageEnabled: true, 
            javaScriptEnabled: true,
            allowFileAccessFromFileURLs: true,
            allowUniversalAccessFromFileURLs: true,
          ),

          // 4. Grant Permissions to the Website
          onPermissionRequest: (controller, request) async {
            return PermissionResponse(
              resources: request.resources,
              action: PermissionResponseAction.GRANT,
            );
          },

          onWebViewCreated: (controller) {
            _webViewController = controller;
            
            // Listen for Success Signal
            controller.addJavaScriptHandler(
              handlerName: 'livenessComplete',
              callback: (args) {
                _handleWebSuccess();
              },
            );
          },
          
          onConsoleMessage: (controller, consoleMessage) {
            // Keep looking at logs if it fails!
            debugPrint("WEB LOG: ${consoleMessage.message}"); 
          },
        ),
      ),
    );
  }

  Future<void> _handleWebSuccess() async {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // Verify Result with Backend
    await ref.read(faceLivenessProvider).verifyLiveness();
    
    if (!mounted) return;
    Navigator.of(context).pop(); // Remove loader

    final provider = ref.read(faceLivenessProvider);
    
    if (provider.verificationStatus == "SUCCESS") {
       ref.read(onboardingProvider.notifier).completeStep('selfie_capture');
       Navigator.of(context).pop(); 
    } else {
       // --- SHOW RETRY DIALOG ---
       _showErrorDialog("Verification Failed", "Confidence: ${provider.confidence}%");
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text("$message\n\nWould you like to try again?"),
        actions: [
          TextButton(
            onPressed: () {
               Navigator.of(ctx).pop(); 
               Navigator.of(context).pop(); // Cancel: Go back to menu
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
               Navigator.of(ctx).pop();
               // --- CRITICAL FIX: GET NEW ID ON RETRY ---
               _startNewSession(); 
            },
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}