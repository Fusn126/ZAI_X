import 'package:zai_x/models/comment/comment_item.dart';
import 'package:zai_x/models/comment/user_comment_item.dart';
import 'package:zai_x/requests/common/api.dart';
import 'package:zai_x/requests/common/http_client.dart';
import 'package:get/get.dart';
import 'package:html_unescape/html_unescape.dart';

class CommentRequest {
  var unescape = HtmlUnescape();

  /// 读取最新的评论
  /// - [type] 类型
  /// - [objId] ID
  /// - [page] 页数
  /// - [pageSize] 每页数量
  Future<List<CommentItem>> getComment({
    required int type,
    required int objId,
    int sortBy = 1,
    int page = 1,
    int pageSize = 24,
  }) async {
    List<CommentItem> ls = [];
    Map result = await HttpClient.instance.getJson(
      '/comment/list',
      baseUrl: Api.BASE_URL,
      queryParameters: {
        "type": type,
        "objId": objId,
        "sortBy": sortBy,
        "page": page,
        "size": pageSize,
      },
      needLogin: true,
    );
    HttpClient.checkErrno(result);
    if (result["data"]["commentIdList"] == null) {
      return [];
    }
    var ids = result["data"]["commentIdList"];
    var comments = result["data"]["commentList"];
    for (String id in ids) {
      var idSplit = id.split(",");
      var item = _parseLatestCommentItem(comments, idSplit.first, type);
      if (idSplit.length > 1) {
        item.parents = [];
        for (var id2 in idSplit.skip(1)) {
          item.parents.insert(0, _parseLatestCommentItem(comments, id2, type));
        }
      }
      if (item.id != 0) {
        ls.add(item);
      }
    }
    return ls;
  }

  CommentItem _parseLatestCommentItem(Map comments, String id, int type) {
    if (!comments.containsKey(id)) {
      return CommentItem.createEmpty();
    }
    var item = comments[id];
    final author = item['author'] is Map ? item['author'] as Map : null;

    // 图片列表：优先使用 imgList 数组，回退到旧的 upload_images 逗号字符串
    List<String> images = [];
    final imgList = item['imgList'];
    if (imgList is List && imgList.isNotEmpty) {
      images = imgList.map((e) => e.toString()).toList();
    } else {
      images = (item['upload_images'] ?? '')
          .toString()
          .split(',')
          .where((x) => x.isNotEmpty)
          .toList();
    }

    //返回的类型非常随机，有时候是int，有时候是string，所以使用int.tryParse
    return CommentItem(
      type: type,
      id: int.tryParse(item['id'].toString()) ?? 0,
      objId: int.tryParse(item['obj_id'].toString()) ?? 0,
      content: unescape.convert(item['content'].toString()),
      photo: (author?['photo'] ?? item['photo'] ?? '').toString(),
      createTime: int.tryParse(item['create_time'].toString()) ?? 0,
      images: images,
      likeAmount: (int.tryParse(item['like_amount'].toString()) ?? 0).obs,
      nickname: (author?['nickname'] ?? item['nickname'] ?? '').toString(),
      replyAmount: int.tryParse(item['reply_amount'].toString()) ?? 0,
      gender:
          int.tryParse((author?['sex'] ?? item['sex'] ?? 0).toString()) ?? 0,
      userId: int.tryParse(
              (author?['uid'] ?? item['sender_uid'] ?? 0).toString()) ??
          0,
      originId: int.tryParse(item['origin_comment_id'].toString()) ?? 0,
      toCommentId: int.tryParse(item['to_comment_id'].toString()) ?? 0,
      isLike: (item['is_like'] == true).obs,
    );
  }

  /// 发表评论
  /// - [objId] ID
  /// - [type] 类型 ,见AppConstant
  /// - [content] 内容
  /// - [toCommentId] 回复评论ID
  /// - [originCommentId] 原始评论ID
  /// - [toUid] 回复用户
  Future<bool> sendComment({
    required int objId,
    required int type,
    required String content,
    int toCommentId = 0,
    int originCommentId = 0,
    int toUid = 0,
  }) async {
    var result = await HttpClient.instance.postJson(
      "/comment/create",
      baseUrl: Api.BASE_URL,
      queryParameters: Api.getDefaultParameter(),
      data: {
        "obj_id": objId,
        "to_comment_id": toCommentId,
        "type": type,
        "content": content,
        "img": [],
      },
      needLogin: true,
    );
    HttpClient.checkErrno(result);
    return true;
  }

  /// 评论点赞
  Future<int?> likeComment({
    required int commentId,
    required int objId,
    required int type,
  }) async {
    var result = await HttpClient.instance.postJson(
      "/comment/addLike",
      baseUrl: Api.BASE_URL,
      data: {
        "commentId": commentId,
        "type": type,
      },
      formUrlEncoded: true,
      needLogin: true,
    );
    if (result is Map) {
      HttpClient.checkErrno(result);
    }
    if (result is Map && result['data'] is Map) {
      return int.tryParse(result['data']['like_amount'].toString());
    }
    return null;
  }

  /// 取消评论点赞
  Future<int?> deleteLikeComment({
    required int commentId,
    required int objId,
    required int type,
  }) async {
    var result = await HttpClient.instance.postJson(
      "/comment/deleteLike",
      baseUrl: Api.BASE_URL,
      data: {
        "commentId": commentId,
        "type": type,
      },
      formUrlEncoded: true,
      needLogin: true,
    );
    if (result is Map) {
      HttpClient.checkErrno(result);
    }
    if (result is Map && result['data'] is Map) {
      return int.tryParse(result['data']['like_amount'].toString());
    }
    return null;
  }

  /// 读取用户的评论
  /// - [type] 类型 0=漫画，1=轻小说，2=新闻
  /// - [uid] 用户ID
  /// - [page] 页数,从0开始
  Future<List<UserCommentItem>> getUserComment({
    required int type,
    required int uid,
    int page = 0,
  }) async {
    List<UserCommentItem> ls = [];
    var result = await HttpClient.instance.getJson(
      type == 1
          ? '/comment/owner/1/$uid/$page.json'
          : '/v3/old/comment/owner/$type/$uid/$page.json',
      baseUrl: Api.BASE_URL,
      withDefaultParameter: true,
      needLogin: true,
    );
    for (var item in result) {
      ls.add(UserCommentItem.fromJson(item));
    }

    return ls;
  }
}
