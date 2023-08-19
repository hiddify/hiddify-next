import 'package:hiddify/domain/clash/clash.dart';
import 'package:hiddify/domain/connectivity/connectivity.dart';
import 'package:hiddify/domain/singbox/singbox.dart';

abstract interface class CoreFacade
    implements SingboxFacade, ClashFacade, ConnectionFacade {}
