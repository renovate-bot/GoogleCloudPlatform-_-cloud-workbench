import 'package:cloudprovision/blocs/app/app_bloc.dart';
import 'package:cloudprovision/repository/build_repository.dart';
import 'package:cloudprovision/repository/models/build.dart';
import 'package:cloudprovision/repository/models/metadata_model.dart';
import 'package:cloudprovision/repository/models/service.dart';
import 'package:cloudprovision/repository/models/template.dart';
import 'package:cloudprovision/repository/service/build_service.dart';
import 'package:cloudprovision/repository/service/template_service.dart';
import 'package:cloudprovision/repository/template_repository.dart';
import 'package:cloudprovision/ui/templates/bloc/template-bloc.dart';
import 'package:cloudprovision/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;

class MyServiceDialog extends StatefulWidget {
  final Service _service;

  MyServiceDialog(this._service, {super.key});

  @override
  State<MyServiceDialog> createState() => _MyServiceDialogState(_service);
}

class _MyServiceDialogState extends State<MyServiceDialog> {
  final Service service;

  final TemplateBloc _templateBloc = TemplateBloc(
      templateRepository: TemplateRepository(service: TemplateService()));

  _MyServiceDialogState(this.service);

  List<Build> _triggerBuilds = [];
  bool _loadingTriggerBuilds = false;
  late String _triggerId;

  @override
  void initState() {
    _loadingTriggerBuilds = true;
    loadTriggerBuilds();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(100),
      padding: EdgeInsets.all(25),
      color: Colors.white,
      child: Column(
        children: [
          _serviceDetails(service, context),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }

  _service(Service service) {
    String serviceUrl =
        "https://console.cloud.google.com/home/dashboard?project=${service.projectId}";
    String serviceIcon = "unknown";

    String tags = service.params['tags'].toString();

    if (tags.contains("cloudrun") ||
        service.templateName.toLowerCase().contains("cloudrun")) {
      serviceUrl =
          "https://console.cloud.google.com/run/detail/${service.region}/${service.serviceId}/metrics?project=${service.projectId}";
      serviceIcon = "cloud_run";
    }

    if (tags.contains("gke") ||
        service.templateName.toLowerCase().contains("gke")) {
      serviceUrl =
          "https://console.cloud.google.com/kubernetes/clusters/details/${service.region}/${service.name}-dev/details?project=${service.projectId}";
      serviceIcon = "google_kubernetes_engine";
    }

    if (tags.contains("pubsub") ||
        service.templateName.toLowerCase().contains("pubsub")) {
      serviceUrl =
          "https://console.cloud.google.com/cloudpubsub/topic/list?referrer=search&project=${service.projectId}";
      serviceIcon = "pubsub";
    }

    if (tags.contains("storage") ||
        service.templateName.toLowerCase().contains("storage")) {
      serviceUrl =
          "https://console.cloud.google.com/storage/browser?project=${service.projectId}&prefix=";
      serviceIcon = "cloud_storage";
    }

    if (tags.contains("cloudsql") ||
        service.templateName.toLowerCase().contains("cloudsql")) {
      serviceUrl =
          "https://console.cloud.google.com/sql/instances?referrer=search&project=${service.projectId}";
      serviceIcon = "cloud_sql";
    }

    return TextButton(
      onPressed: () async {
        final Uri _url = Uri.parse(serviceUrl);
        if (!await launchUrl(_url)) {
          throw 'Could not launch $_url';
        }
      },
      child: Row(
        children: [
          SizedBox(
            width: 30,
            height: 30,
            child: Image(
              image: AssetImage('images/${serviceIcon}.png'),
              fit: BoxFit.fill,
            ),
          ),
          SizedBox(
            width: 4,
          ),
          SelectableText(
            service.name,
            style: AppText.linkFontStyle,
            // overflow:
            //     TextOverflow
            //         .ellipsis,
            // maxLines: 1,
          ),
        ],
      ),
    );
  }

  _serviceDetails(Service service, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 140,
                        child: Text(
                          'Service name:',
                          style: AppText.fontStyleBold,
                        ),
                      ),
                      _service(service),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      SizedBox(
                        width: 150,
                        child: Text(
                          'Service ID:',
                          style: AppText.fontStyleBold,
                        ),
                      ),
                      Text(
                        '${service.serviceId}',
                        style: AppText.fontStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      SizedBox(
                        width: 150,
                        child: Text(
                          'Region:',
                          style: AppText.fontStyleBold,
                        ),
                      ),
                      Text(
                        '${service.region}',
                        style: AppText.fontStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      SizedBox(
                        width: 150,
                        child: Text(
                          'Project ID:',
                          style: AppText.fontStyleBold,
                        ),
                      ),
                      Text(
                        '${service.projectId}',
                        style: AppText.fontStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      SizedBox(
                        width: 150,
                        child: Text(
                          'Last deployed:',
                          style: AppText.fontStyleBold,
                        ),
                      ),
                      Text(
                        DateFormat('MM/d/yy, h:mm a')
                            .format(service.deploymentDate),
                        style: AppText.fontStyle,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "(${timeago.format(service.deploymentDate)})",
                        style: AppText.fontStyle,
                      )
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      SizedBox(
                        width: 150,
                        child: Text(
                          'Deployed by:',
                          style: AppText.fontStyleBold,
                        ),
                      ),
                      Text(
                        '${service.user}',
                        style: AppText.fontStyle,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              children: [
                // IconButton(
                //   icon: Icon(Icons.delete),
                //   onPressed: () {},
                // ),
                // IconButton(
                //   icon: Icon(
                //     Icons.more_vert,
                //   ),
                //   onPressed: () {},
                // ),
                // const SizedBox(width: 12),
              ],
            ),
          ],
        ),
        Divider(),
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "Repository:",
                    style: AppText.fontStyleBold,
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () async {
                      final Uri _url = Uri.parse(service.instanceRepo);
                      if (!await launchUrl(_url)) {
                        throw 'Could not launch $_url';
                      }
                    },
                    child: Text(
                      service.instanceRepo,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: AppText.linkFontStyle,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8.0,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Image(
                            color: Colors.white,
                            image: AssetImage('images/cloud_shell.png'),
                            fit: BoxFit.fill,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("DEVELOP IN GOOGLE CLOUD SHELL",
                              style: AppText.buttonFontStyle),
                        )
                      ],
                    ),
                    onPressed: () async {
                      final Uri _url = Uri.parse(
                          "https://console.cloud.google.com/cloudshell/editor?cloudshell_git_repo=${service.instanceRepo}&cloudshell_workspace=.");
                      if (!await launchUrl(_url)) {
                        throw 'Could not launch $_url';
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ],
        ),
        Divider(),
        Row(
          children: [
            Text(
              "Build History: ",
              style: AppText.fontStyleBold,
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () async {
                final Uri _url = Uri.parse(
                    "https://console.cloud.google.com/cloud-build/triggers;region=global/edit/${_triggerId}?project=${service.projectId}");
                if (!await launchUrl(_url)) {
                  throw 'Could not launch $_url';
                }
              },
              child: Text(
                "${service.serviceId}-webhook-trigger",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: AppText.linkFontStyle,
              ),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () async {
                final Uri _url = Uri.parse(
                    "https://console.cloud.google.com/cloud-build/builds;region=global?query=trigger_id=${_triggerId}&project=${service.projectId}");
                if (!await launchUrl(_url)) {
                  throw 'Could not launch $_url';
                }
              },
              child: Text(
                "View All",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: AppText.linkFontStyle,
              ),
            )
          ],
        ),
        const SizedBox(height: 4),
        _loadingTriggerBuilds
            ? LinearProgressIndicator()
            : buildCloudBuildsSection(),
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ExpansionTile(
                title: Text(
                  'Resources (ref guides, codelabs, etc):',
                  style: AppText.fontStyleBold,
                ),
                children: <Widget>[
                  for (TemplateMetadata tm in service.template!.metadata)
                    Row(
                      children: [
                        TextButton(
                          onPressed: () async {
                            final Uri _url = Uri.parse(tm.value);
                            if (!await launchUrl(_url)) {
                              throw 'Could not launch $_url';
                            }
                          },
                          child: Text(
                            tm.name,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: AppText.linkFontStyle,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ExpansionTile(
                title: Text(
                  'Template:',
                  style: AppText.fontStyleBold,
                ),
                children: <Widget>[
                  Row(
                    children: [
                      Text(
                        "${service.templateName}",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: AppText.fontStyle,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void loadTriggerBuilds() async {
    List<Build> builds = await BuildRepository(service: BuildService())
        .getTriggerBuilds(service.projectId, service.serviceId);

    setState(() {
      if (builds.isNotEmpty) {
        _triggerId = builds.first.buildTriggerId;
      }
      _triggerBuilds = builds;
      _loadingTriggerBuilds = false;
    });
  }

  buildCloudBuildsSection() {
    List<Widget> rows = [];
    for (Build build in _triggerBuilds) {
      rows.add(Row(
        children: [
          build.status == "SUCCESS"
              ? Icon(
                  Icons.check_circle,
                  color: Colors.green,
                )
              : Icon(
                  Icons.cancel,
                  color: Colors.red,
                ),
          SizedBox(
            width: 4,
          ),
          SizedBox(
              width: 80,
              child: Text(build.status == "SUCCESS" ? "Successful" : "Failed")),
          SizedBox(
            width: 4,
          ),
          TextButton(
            onPressed: () async {
              final Uri _url = Uri.parse(build.buildLogUrl);
              if (!await launchUrl(_url)) {
                throw 'Could not launch $_url';
              }
            },
            child: Text(
              build.buildId.substring(0, 8),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          SizedBox(
            width: 4,
          ),
          Text(
            DateFormat('MM/d/yy, h:mm a')
                .format(DateTime.parse(build.createTime)),
          ),
          SizedBox(
            width: 4,
          ),
          Text(
            "(${timeago.format(service.deploymentDate)})",
          ),
        ],
      ));
    }
    return Column(
      children: rows,
    );
  }
}
