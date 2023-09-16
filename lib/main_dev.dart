import 'package:flutter/widgets.dart';
import 'package:hiddify/bootstrap.dart';
import 'package:hiddify/domain/environment.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  return lazyBootstrap(widgetsBinding, Environment.dev);
}
