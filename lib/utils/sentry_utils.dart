import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hiddify/domain/failures.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

FutureOr<SentryEvent?> sentryBeforeSend(SentryEvent event, {Hint? hint}) {
  if (canSendEvent(event.throwable)) return event;
  return null;
}

bool canSendEvent(dynamic throwable) {
  return switch (throwable) {
    UnexpectedFailure(:final error) => canSendEvent(error),
    DioException _ => false,
    SocketException _ => false,
    ExpectedException _ => false,
    _ => true,
  };
}
