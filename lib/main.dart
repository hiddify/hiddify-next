import 'package:flutter/widgets.dart';
import 'package:hiddify/bootstrap.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  return lazyBootstrap(widgetsBinding);
}
