import 'package:flutter/material.dart';
import 'package:zai_x/app/app_style.dart';
import 'package:zai_x/services/app_settings_service.dart';
import 'package:zai_x/app/dialog_utils.dart';
import 'package:zai_x/app/utils.dart';
import 'package:zai_x/routes/app_navigator.dart';
import 'package:zai_x/services/user_service.dart';

import 'package:get/get.dart';

class UserHomeController extends GetxController {
  final AppSettingsService settings = AppSettingsService.instance;

  @override
  void onInit() {
    UserService.instance.refreshProfile();
    super.onInit();
  }

  /// 登录
  void login() {
    UserService.instance.login();
  }

  /// 退出登录
  void logout() async {
    var result = await DialogUtils.showAlertDialog(
      "确定要退出登录吗？",
      title: "退出登录",
    );
    if (result) {
      UserService.instance.logout();
    }
  }

  /// 主题设置
  void setTheme() {
    settings.changeTheme();
  }

  /// 关于我们
  void about() {
    Get.dialog(AboutDialog(
      applicationIcon: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.withValues(alpha: .2),
          ),
          borderRadius: AppStyle.radius12,
        ),
        child: ClipRRect(
          borderRadius: AppStyle.radius12,
          child: Image.asset(
            'assets/images/logo.png',
            width: 48,
            height: 48,
          ),
        ),
      ),
      applicationName: "ZAI-X",
      applicationVersion:
          "Ver ${Utils.packageInfo.version} (${Utils.packageInfo.buildNumber})",
      applicationLegalese: "@xiaoyaocz",
    ));
  }

  /// 检查更新
  void checkUpdate() {
    Utils.checkUpdate(showMsg: true);
  }

  /// 订阅
  void toUserSubscribe() async {
    if (!await UserService.instance.login()) {
      return;
    }
    AppNavigator.toUserSubscribe();
  }

  /// 历史
  void toUserHistory() async {
    if (!await UserService.instance.login()) {
      return;
    }
    AppNavigator.toUserHistory();
  }

  /// 本机历史
  void toLocalHistory() async {
    if (!await UserService.instance.login()) {
      return;
    }
    AppNavigator.toUserHistory();
  }

  void toSettings() async {
    AppNavigator.toSettings();
  }

  void comicDownload() {
    AppNavigator.toComicDownloadManage(0);
  }

  void novelDownload() {
    AppNavigator.toNovelDownloadManage(0);
  }

  void userComment() {
    AppNavigator.toUserComment(int.tryParse(UserService.instance.userId) ?? 0);
  }

  void toFavorite() {
    AppNavigator.tolocalFavorite();
  }
}
