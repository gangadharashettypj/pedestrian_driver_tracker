import 'package:flutter/material.dart';

class ButtonLoadingAnimationController extends ChangeNotifier {
  bool _showLoading = false;

  void _notifyView() {
    notifyListeners();
  }

  bool get showLoading => _showLoading;

  void startLoadingAnimation() {
    _showLoading = true;
    _notifyView();
  }

  void stopLoadingAnimation() {
    _showLoading = false;
    _notifyView();
  }
}
