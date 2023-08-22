import 'package:cloud_provision_server/controllers/BaseController.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';

import 'dart:convert';
import 'package:googleapis/cloudbuild/v1.dart' as cb;
import '../services/TriggersService.dart';

class TriggersController extends BaseController {
  TriggersService _triggersService = TriggersService();

  Router get router {
    final router = Router();
    router.post('/', _runTriggerHandler);
    router.get('/<serviceId>/builds', _getTriggerBuildsHandler);
    return router;
  }

  Future<Response> _runTriggerHandler(Request request) async {
    try {
      final body = await request.readAsString();
      Map<String, dynamic> requestMap = jsonDecode(body);

      String projectId = requestMap['project_id'];
      // String branchName = requestMap['branch_name'];
      // if (branchName == null || branchName == "") {
      //   branchName = "main";
      // }
      String branchName = "main";

      var triggerName = requestMap['app_name'] + "-trigger";

      cb.Operation operation =
          await _triggersService.runTrigger(projectId, branchName, triggerName);

      if (operation != null) {
        return Response.ok(
          jsonResponseEncode(operation.metadata),
        );
      } else {
        return Response.internalServerError(
          body: jsonResponseEncode({"msg": "Failed to run trigger"}),
        );
      }
    } on Exception catch (e, stacktrace) {
      print("Exception occurred: $e stackTrace: $stacktrace");
      return Response.internalServerError(
        body: jsonResponseEncode({"msg": "Internal Server Error"}),
      );
    }
  }

  Future<Response> _getTriggerBuildsHandler(Request request) async {
    try {
      String? serviceId = request.params['serviceId'];
      String? projectId = request.url.queryParameters['projectId'];
      String? accessToken = request.headers["Access-token"];

      var triggerName = serviceId! + "-webhook-trigger";

      List<Map> response =
          await _triggersService.getTriggerBuilds(projectId, triggerName, accessToken);

      if (response != null) {
        return Response.ok(
          jsonResponseEncode(response),
        );
      } else {
        return Response.internalServerError(
          body: jsonResponseEncode({"msg": "Failed to get trigger builds"}),
        );
      }
    } on Exception catch (e, stacktrace) {
      print("Exception occurred: $e stackTrace: $stacktrace");
      return Response.internalServerError(
        body: jsonResponseEncode({"msg": "Internal Server Error"}),
      );
    }
  }
}
