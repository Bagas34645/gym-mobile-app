import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/gym_button.dart';

class MidtransPaymentView extends StatefulWidget {
  const MidtransPaymentView({super.key});

  @override
  State<MidtransPaymentView> createState() => _MidtransPaymentViewState();
}

class _MidtransPaymentViewState extends State<MidtransPaymentView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  String get _redirectUrl => Get.arguments['redirect_url'] as String;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onNavigationRequest: (request) {
            final url = request.url;
            if (url.contains('finish') || url.contains('unfinish')) {
              _finishPayment();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(_redirectUrl));
  }

  void _finishPayment() {
    if (!mounted) return;
    Get.back(result: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pembayaran Midtrans', style: AppTextStyles.headingSmall),
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _finishPayment,
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GymButton(
            text: 'Selesai',
            onPressed: _finishPayment,
          ),
        ),
      ),
    );
  }
}
