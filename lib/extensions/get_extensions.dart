import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';

ProgressDialog? pd;

void toast(String msg) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 2,
  );
}

void showProgressDialog(BuildContext context, String message) {
  pd ??= ProgressDialog(context: context);
  if (pd?.isOpen() == true) {
    pd?.close();
  }
  pd?.show(
    max: 100,
    msg: message,
    progressType: ProgressType.valuable,
  );
}

void hideProgressDialog() {
  if (pd?.isOpen() == true) {
    pd?.close();
  }
}
