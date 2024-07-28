/// MODO DE USO
/// Abrir una terminal en la raiz del proyecto (Donde se ubica el archivo pubspec.yaml) y tipear 'dart newpage.dart [nombre de la pagina]'
/// No colocar los sufijos page ni page_controller, ya que eso lo hace el script de manera automatica
/// Se pueden utilizar espacios, guines medios y guines bajos para los nombres, y utilizar mayusculas y minusculas de manera indiferente, el script les dara el formato correcto
/// Ej: "dart newpage.dart home" creara el archivo home_page con la clase HomePage y HomePageState, y tambien creara el archivo home_page_controller con la clase HomePageController
///
/// REQUERIMIENTOS
/// # Deben existir las siguientes carpetas en la raiz del proyecto (Donde se ubica el archivo pubspec.yaml):
///   - lib/src/ui/pages
///   - lib/src/ui/page_controllers
/// # Debe existir la clase IViewController en lib/src/interfaces/i_view_controller.dart
/// # Debe existir la clase PageArgs en lib/src/utils/page_args.dart
/// # El proyecto debe contar con el package mvc_pattern (https://pub.dev/packages/mvc_pattern)
///
///  EJEMPLOS DE NOMBRES
/// - "dart newpage.dart EMA crack" => ema_crack_page.dart (EmaCrackPage) y ema_crack_page_controller.dart (EmaCrackPageController)
/// - "dart newpage.dart COSMIC_barrilet cODE-magic" cosmic_barrilet_code_magic_page.dart (CosmicBarriletCodeMagicPage) y cosmic_barrilet_code_magic_page_controller.dart (CosmicBarriletCodeMagicPageController)

// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:io';

void main(List<String> text) async {
  List<String> aux = [];
  String joinedText = text.join(" ");
  aux.addAll(joinedText.replaceAll(RegExp(r"[-_]"), " ").split(" "));
  String fileName = _getFileName(aux);
  String className = _getClassName(aux);

  File viewFile = File("lib/src/ui/pages/${fileName}_page.dart");
  await viewFile
      .writeAsString(_writeView(fileName: fileName, className: className));
  await viewFile.create();

  File controllerFile =
      File("lib/src/ui/page_controllers/${fileName}_page_controller.dart");
  await controllerFile.writeAsString(
      _writeController(fileName: fileName, className: className));
  await controllerFile.create();
}

String _getFileName(List<String> words) {
  List<String> result = [];
  words.forEach((element) {
    element.replaceAll(" ", "");
  });
  words.removeWhere((element) => element.isEmpty);
  for (String element in words) {
    result.add(element.replaceAll(" ", "").toLowerCase());
  }
  return result.join("_");
}

String _getClassName(List<String> words) {
  List<String> result = [];
  words.forEach((element) {
    element.replaceAll(" ", "");
  });
  words.removeWhere((element) => element.isEmpty);
  for (String element in words) {
    result.add(
        "${element.replaceAll(" ", "")[0].toUpperCase()}${element.replaceAll(" ", "").substring(1).toLowerCase()}");
  }
  return result.join();
}

String _writeView({
  required String fileName,
  required String className,
}) {
  return """
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../utils/page_args.dart';
import '../page_controllers/${"${fileName}_page_controller"}.dart';

class ${"${className}Page"} extends StatefulWidget {
  final PageArgs? args;
  const ${"${className}Page"}(this.args, {super.key});

  @override
  ${"${className}PageState"} createState() => ${"${className}PageState"}();
}

class ${"${className}PageState"} extends StateMVC<${"${className}Page"}> {
  late ${"${className}PageController"} _con;
  PageArgs? args;

  ${"${className}PageState"}() : super(${"${className}PageController"}()) {
    _con = ${"${className}PageController"}.con;
  }

  @override
  void initState() {
    _con.initPage(arguments: widget.args);
    super.initState();
  }

  @override
  void dispose() {
    _con.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: _con.onPopInvoked,
      canPop: false,
      child: SafeArea(
        child: Scaffold(
          body: Container(),
        ),
      ),
    );
  }
}

 """;
}

String _writeController({required String fileName, required String className}) {
  return """ 
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../interfaces/i_view_controller.dart';
import '../../utils/page_args.dart';

class ${"${className}PageController"} extends ControllerMVC implements IViewController {
  static late ${"${className}PageController"} _this;

  factory ${"${className}PageController"}() {
    _this = ${"${className}PageController"}._();
    return _this;
  }

  static ${"${className}PageController"} get con => _this;
  ${"${className}PageController"}._();

  PageArgs? args;

  @override
  void initPage({PageArgs? arguments}) {}

  @override
  disposePage() {}

  void onPopInvoked(didPop) {
    if (didPop) return;
    // ADD CODE >>>>>>

    // <<<<<<<<<<<<<<<
  }
}
  """;
}
