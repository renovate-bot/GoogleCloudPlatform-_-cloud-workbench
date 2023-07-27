import 'package:cloudprovision/theme.dart';
import 'package:cloudprovision/utils/runtime_env_client.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_strategy/url_strategy.dart';

import 'routing/app_router.dart';

Future<void> main() async {
  var envMap = await RuntimeEnvClient.getEnvVars(url: "/v1/env");

  await dotenv.load(fileName: "assets/env");

  WidgetsFlutterBinding.ensureInitialized();

  var firebaseConfigMap = envMap["FIREBASE_CONFIG"];
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: firebaseConfigMap['apiKey'],
      appId: firebaseConfigMap['appId'],
      messagingSenderId: firebaseConfigMap['messagingSenderId'],
      projectId: firebaseConfigMap['projectId'],
      authDomain: firebaseConfigMap['authDomain'],
      storageBucket: firebaseConfigMap['storageBucket'],
    ),
  );

  // Uncomment to run with local Firebase emulator

  // if (kDebugMode) {
  //   try {
  //     FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8088);
  //     await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  setPathUrlStrategy();
  runApp(
    ProviderScope(
      child: const CloudProvisionApp(),
    ),
  );
}

class CloudProvisionApp extends ConsumerWidget {
  const CloudProvisionApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: goRouter,
      theme: CloudTheme().themeData,
    );
  }
}
