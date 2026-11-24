import 'package:zai_x/app/app_constant.dart';
import 'package:zai_x/app/controller/base_controller.dart';
import 'package:zai_x/models/comic/author_model.dart';
import 'package:zai_x/requests/comic_request.dart';
import 'package:zai_x/services/user_service.dart';
import 'package:get/get.dart';

class ComicAuthorDetailController
    extends BasePageController<ComicAuthorComicModel> {
  final int id;
  ComicAuthorDetailController(this.id);

  final ComicRequest request = ComicRequest();

  /// 作者信息
  Rx<ComicAuthorModel?> authorInfo = Rx<ComicAuthorModel?>(null);

  @override
  Future<List<ComicAuthorComicModel>> getData(int page, int pageSize) async {
    var result = await request.authorDetail(id: id, page: page);
    if (page == 1) {
      authorInfo.value = result;
    }
    return result.data;
  }

  void subscribeAll() {
    if (list.isEmpty) {
      return;
    }
    UserService.instance.addSubscribe(
      list.map((e) => e.id).toList(),
      AppConstant.kTypeComic,
    );
  }
}
