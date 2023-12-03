import 'package:flutter/widgets.dart';
import 'package:hiddify/bootstrap.dart';
import 'package:hiddify/core/model/environment.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  return lazyBootstrap(widgetsBinding, Environment.prod);
}
