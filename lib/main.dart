import 'package:ezgym/models/jumping_jack_counter.dart';
import 'package:ezgym/models/squat_counter.dart';
import 'package:ezgym/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'models/push_up_model.dart';
import 'package:app_links/app_links.dart';

final appLinks = AppLinks();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void initAppLinks() {
  appLinks.uriLinkStream.listen((Uri uri) {
    handleIncomingLink(uri);
  });

  appLinks.getInitialLink().then((uri) {
    if (uri != null) handleIncomingLink(uri);
  });
}

void handleIncomingLink(Uri uri) {
  print('Received URI: $uri');
  if (uri.pathSegments.isNotEmpty && uri.pathSegments[0] == 'routine') {
    final routineId = uri.pathSegments[1];
    navigatorKey.currentState?.pushNamed('/routine', arguments: routineId);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final uri = await appLinks.getInitialLink();
  if (uri != null) handleIncomingLink(uri);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PushUpCounter>(
          create: (_) => PushUpCounter(),
        ),
        BlocProvider<SquatCounter>(
          create: (_) => SquatCounter(),
        ),
        BlocProvider<JumpingJackCounter>(create: (_) => JumpingJackCounter()),
      ],
      child: MaterialApp(home: Login()),
    );
  }
}
