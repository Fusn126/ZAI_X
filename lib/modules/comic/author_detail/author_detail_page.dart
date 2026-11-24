import 'package:flutter/material.dart';
import 'package:zai_x/app/app_constant.dart';
import 'package:zai_x/app/app_style.dart';
import 'package:zai_x/models/comic/author_model.dart';
import 'package:zai_x/modules/comic/author_detail/author_detail_controller.dart';
import 'package:zai_x/routes/app_navigator.dart';
import 'package:zai_x/services/user_service.dart';
import 'package:zai_x/widgets/net_image.dart';
import 'package:zai_x/widgets/page_list_view.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class ComicAuthorDetailPage extends StatelessWidget {
  final int id;
  final ComicAuthorDetailController controller;
  ComicAuthorDetailPage(this.id, {super.key})
      : controller = Get.put(
          ComicAuthorDetailController(id),
          tag: "$id",
        );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Obx(
          () => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              NetImage(
                controller.authorInfo.value?.cover ?? "",
                borderRadius: 24,
                width: 32,
                height: 32,
              ),
              AppStyle.hGap8,
              Text(controller.authorInfo.value?.nickname ?? "作者"),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: controller.subscribeAll,
            icon: const Icon(Remix.heart_line),
            label: const Text("全部订阅"),
          ),
        ],
      ),
      body: PageListView(
        pageController: controller,
        firstRefresh: true,
        separatorBuilder: (context, i) => Divider(
          endIndent: 12,
          indent: 12,
          color: Colors.grey.withValues(alpha: .2),
          height: 1,
        ),
        itemBuilder: (_, i) {
          var item = controller.list[i];
          return buildItem(item);
        },
      ),
    );
  }

  Widget buildItem(ComicAuthorComicModel item) {
    return InkWell(
      onTap: () {
        AppNavigator.toComicDetail(item.id);
      },
      child: Container(
        padding: AppStyle.edgeInsetsA12,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            NetImage(
              item.cover,
              width: 80,
              height: 110,
              borderRadius: 4,
            ),
            AppStyle.hGap12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppStyle.vGap4,
                  Text(item.status,
                      style: const TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            ),
            Center(
              child: Obx(
                () => UserService.instance.subscribedComicIds.contains(item.id)
                    ? IconButton(
                        icon: const Icon(Icons.favorite),
                        onPressed: () {
                          UserService.instance.cancelSubscribe(
                            [item.id],
                            AppConstant.kTypeComic,
                          );
                        },
                      )
                    : IconButton(
                        icon: const Icon(Icons.favorite_border),
                        onPressed: () {
                          UserService.instance.addSubscribe(
                            [item.id],
                            AppConstant.kTypeComic,
                          );
                        },
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
