// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:mvc_pattern/mvc_pattern.dart';

// Project imports:
import '../../interfaces/i_view_controller.dart';
import '../../utils/page_args.dart';

class HomePageController extends ControllerMVC implements IViewController {
  static late HomePageController _this;

  factory HomePageController() {
    _this = HomePageController._();
    return _this;
  }

  static HomePageController get con => _this;
  PageArgs? args;
  HomePageController._();

  bool isLoading = false;
  TextEditingController controller = TextEditingController();

  @override
  void initPage({PageArgs? arguments}) {
    controller = TextEditingController();
  }

  @override
  disposePage() {}
}
