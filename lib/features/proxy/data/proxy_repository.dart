import 'package:fpdart/fpdart.dart';
import 'package:hiddify/core/utils/exception_handler.dart';
import 'package:hiddify/features/proxy/model/proxy_entity.dart';
import 'package:hiddify/features/proxy/model/proxy_failure.dart';
import 'package:hiddify/singbox/service/singbox_service.dart';
import 'package:hiddify/utils/custom_loggers.dart';

abstract interface class ProxyRepository {
  Stream<Either<ProxyFailure, List<ProxyGroupEntity>>> watchProxies();
  TaskEither<ProxyFailure, Unit> selectProxy(
    String groupTag,
    String outboundTag,
  );
  TaskEither<ProxyFailure, Unit> urlTest(String groupTag);
}

class ProxyRepositoryImpl
    with ExceptionHandler, InfraLogger
    implements ProxyRepository {
  ProxyRepositoryImpl({required this.singbox});

  final SingboxService singbox;

  @override
  Stream<Either<ProxyFailure, List<ProxyGroupEntity>>> watchProxies() {
    return singbox.watchOutbounds().map((event) {
      final groupWithSelected = {
        for (final group in event) group.tag: group.selected,
      };
      return event
          .map(
            (e) => ProxyGroupEntity(
              tag: e.tag,
              type: e.type,
              selected: e.selected,
              items: e.items
                  .map(
                    (e) => ProxyItemEntity(
                      tag: e.tag,
                      type: e.type,
                      urlTestDelay: e.urlTestDelay,
                      selectedTag: groupWithSelected[e.tag],
                    ),
                  )
                  .filter((t) => t.isVisible)
                  .toList(),
            ),
          )
          .toList();
    }).handleExceptions(
      (error, stackTrace) {
        loggy.error("error watching proxies", error, stackTrace);
        return ProxyUnexpectedFailure(error, stackTrace);
      },
    );
  }

  @override
  TaskEither<ProxyFailure, Unit> selectProxy(
    String groupTag,
    String outboundTag,
  ) {
    return exceptionHandler(
      () => singbox
          .selectOutbound(groupTag, outboundTag)
          .mapLeft(ProxyUnexpectedFailure.new)
          .run(),
      ProxyUnexpectedFailure.new,
    );
  }

  @override
  TaskEither<ProxyFailure, Unit> urlTest(String groupTag) {
    return exceptionHandler(
      () => singbox.urlTest(groupTag).mapLeft(ProxyUnexpectedFailure.new).run(),
      ProxyUnexpectedFailure.new,
    );
  }
}
