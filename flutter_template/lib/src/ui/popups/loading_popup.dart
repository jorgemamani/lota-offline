// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '/src/support/futuristic.dart';
import '/src/ui/components/loading_component.dart';
import '/values/k_colors.dart';

class LoadingPopup {
  final BuildContext context;
  final Color backgroundColor;
  final Future onLoading;
  Function? onResult;
  Function? onError;

  LoadingPopup({
    required this.context,
    required this.onLoading,
    this.onResult,
    this.onError,
    this.backgroundColor = const Color(0x80707070),
  });

  final double radius = 20;

  Future show() {
    return showDialog(
        context: context,
        barrierColor: kPrimary.withOpacity(0.5),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return _dialog();
        });
  }

  _dialog() {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Futuristic(
        autoStart: true,
        futureBuilder: () => onLoading,
        busyBuilder: (context) => body(),
        onData: (data) {
          Navigator.pop(context);
          onResult!(data);
        },
        onError: (error, retry) {
          Navigator.pop(context);
          onError!(error);
        },
      ),
    );
  }

  body() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        loadingComponent(true, color: Colors.white, size: 50),
      ],
    );
  }
}
