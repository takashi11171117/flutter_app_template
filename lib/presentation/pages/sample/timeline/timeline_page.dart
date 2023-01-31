import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../../../../extensions/context_extension.dart';
import '../../../../model/use_cases/sample/timeline/fetch_timeline.dart';
import '../../../../model/use_cases/sample/timeline/post/fetch_post.dart';
import '../../../../utils/logger.dart';
import '../../../custom_hooks/use_refresh_controller.dart';
import '../../../widgets/error_text.dart';
import '../../../widgets/smart_refresher_custom.dart';
import 'edit_post_page.dart';
import 'post_detail_page.dart';
import 'widgets/timeline_tile.dart';

class TimelinePage extends HookConsumerWidget {
  const TimelinePage({super.key});

  static String get pageName => 'timeline';
  static String get pagePath => '/$pageName';

  /// go_routerの画面遷移
  static void show(BuildContext context) {
    context.push(pagePath);
  }

  /// 従来の画面遷移
  static Future<void> showNav1(BuildContext context) {
    return Navigator.of(context, rootNavigator: true).push<void>(
      CupertinoPageRoute(
        builder: (_) => const TimelinePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    final refreshController = useRefreshController();

    final asyncValue = ref.watch(fetchTimelineAsyncProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'タイムライン',
          style: context.subtitleStyle.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: asyncValue.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16)
                    .copyWith(bottom: 80),
                child: Text(
                  'タイムラインはありません',
                  style: context.bodyStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return Scrollbar(
            controller: scrollController,
            child: SmartRefresher(
              header: const SmartRefreshHeader(),
              footer: const SmartRefreshFooter(),
              enablePullUp: true,
              controller: refreshController,
              physics: const BouncingScrollPhysics(),
              onRefresh: () async {
                await ref.read(fetchTimelineAsyncProvider.notifier).refresh();
                refreshController.refreshCompleted();
              },
              onLoading: () async {
                await ref.read(fetchTimelineAsyncProvider.notifier).fetchMore();
                refreshController.loadComplete();
              },
              child: ListView.separated(
                controller: scrollController,
                itemBuilder: (BuildContext context, int index) {
                  final data = items[index];
                  return TimelineTile(
                    data: data,
                    onTap: () {
                      PostDetailPage.show(
                        context,
                        args: FetchPostArgs(
                          postId: data.postId,
                          userId: data.userId,
                        ),
                      );
                    },
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider(height: 1);
                },
                itemCount: items.length,
              ),
            ),
          );
        },
        error: (e, stackTrace) {
          logger.shout(e);
          final message = 'エラー\n$e';
          return ErrorText(
            message: message,
            onRetry: () {
              ref.invalidate(fetchTimelineAsyncProvider);
            },
          );
        },
        loading: () => const Center(
          child: CupertinoActivityIndicator(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          EditPostPage.show(context);
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}
