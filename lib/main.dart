import 'package:erazor_partner/common/error_text.dart';
import 'package:erazor_partner/common/loader.dart';
import 'package:erazor_partner/controllers/auth_controller.dart';
import 'package:erazor_partner/controllers/firebase_controller.dart';
import 'package:erazor_partner/firebase_options.dart';
import 'package:erazor_partner/models/salon_details.dart';
import 'package:erazor_partner/providers/firebase_providers.dart';
import 'package:erazor_partner/router.dart';
import 'package:erazor_partner/theme/theme.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Blue001,
  ));

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // await FirebaseAppCheck.instance.activate(
  //     //webRecaptchaSiteKey: 'recaptcha-v3-site-key',
  //     androidProvider: AndroidProvider.debug);

  // final appcheck = await FirebaseAppCheck.instance.getToken();
  // print('appcheck $appcheck');

  final messaging = FirebaseMessaging.instance;

  final settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (kDebugMode) {
    print('Permission granted: ${settings.authorizationStatus}');
  }
  FirebaseMessaging.onBackgroundMessage(_messageHandler);

  runApp(const ProviderScope(child: SafeArea(child: PartnerApp())));
}

Future<void> _messageHandler(RemoteMessage message) async {
  debugPrint('background message ${message.data}');
}

class PartnerApp extends ConsumerStatefulWidget {
  const PartnerApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PartnerAppState();
}

class _PartnerAppState extends ConsumerState<PartnerApp> {
  void getToken() async {
    final fcm = ref.watch(messagingProvider);
    await fcm.getToken().then((value) => ref
        .watch(firebaseControllerProvider.notifier)
        .updateToken(token: value ?? ''));
  }

  @override
  initState() {
    initialization();
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      debugPrint('message received');
      debugPrint(event.data.toString());
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('message opened');
    });
    super.initState();
  }

  void initialization() async {
    await Future.delayed(const Duration(seconds: 1));
    FlutterNativeSplash.remove();
  }

  void getData(WidgetRef ref, SalonDetails data) async {
    ref.read(salonDetailsProvider.notifier).update((state) => data);
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(salonProvider).when(
          data: (data) {
            print('data $data');
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'Erazor Partner',
              theme: ThemeData(
                  scaffoldBackgroundColor: Colors.white,
                  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                    showSelectedLabels: true,
                    showUnselectedLabels: true,
                    selectedItemColor: Blue001,
                    //unselectedItemColor: Colors.black,
                    type: BottomNavigationBarType.fixed,
                    elevation: 10,
                    backgroundColor: Colors.white,
                  ),
                  bottomSheetTheme: const BottomSheetThemeData(
                      surfaceTintColor: Colors.white),
                  dialogTheme: const DialogTheme(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      surfaceTintColor: Colors.white,
                      backgroundColor: Colors.white),
                  floatingActionButtonTheme:
                      const FloatingActionButtonThemeData(
                          foregroundColor: Colors.white,
                          backgroundColor: Blue001),
                  appBarTheme: const AppBarTheme(
                      systemOverlayStyle: SystemUiOverlayStyle.light,
                      //color: Blue001,
                      titleTextStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'livvic',
                          letterSpacing: 0),
                      backgroundColor: Blue001,
                      foregroundColor: Colors.white),
                  elevatedButtonTheme: const ElevatedButtonThemeData(
                      style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(Blue001),
                          elevation: MaterialStatePropertyAll(10)
                          //surfaceTintColor: MaterialStatePropertyAll(Blue001),
                          )),
                  cardTheme: const CardTheme(
                      surfaceTintColor: Colors.white, color: Colors.white),
                  colorScheme: ColorScheme.fromSeed(seedColor: Blue001),
                  useMaterial3: true,
                  fontFamily: 'livvic',
                  textTheme: const TextTheme(
                    displayLarge: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                    displayMedium:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    displaySmall:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                    bodySmall: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        letterSpacing: 0),
                    bodyMedium: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0),
                    bodyLarge: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                    ),
                    labelSmall: TextStyle(
                        fontSize: 14,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  )),
              routerDelegate: RoutemasterDelegate(
                routesBuilder: (context) {
                  if (data.salonName.isNotEmpty) {
                    getToken();
                    getData(ref, data);
                    return loggedInRoute;
                  } else {
                    getData(ref, data);
                    print('dataaaaaauid ${data.cid}');
                    return unregisteredRoute;
                  }
                },
              ),
              routeInformationParser: const RoutemasterParser(),
            );
          },
          error: (error, stackTrace) {
            print('error $error');
            print('st $stackTrace');
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'Erazor Partner',
              theme: ThemeData(
                  scaffoldBackgroundColor: Colors.white,
                  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                    showSelectedLabels: true,
                    showUnselectedLabels: true,
                    selectedItemColor: Blue001,
                    //unselectedItemColor: Colors.black,
                    type: BottomNavigationBarType.fixed,
                    elevation: 10,
                    backgroundColor: Colors.white,
                  ),
                  bottomSheetTheme: const BottomSheetThemeData(
                      surfaceTintColor: Colors.white),
                  dialogTheme: const DialogTheme(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      surfaceTintColor: Colors.white,
                      backgroundColor: Colors.white),
                  floatingActionButtonTheme:
                      const FloatingActionButtonThemeData(
                          foregroundColor: Colors.white,
                          backgroundColor: Blue001),
                  appBarTheme: const AppBarTheme(
                      systemOverlayStyle: SystemUiOverlayStyle.light,
                      //color: Blue001,
                      titleTextStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'livvic',
                          letterSpacing: 0),
                      backgroundColor: Blue001,
                      foregroundColor: Colors.white),
                  elevatedButtonTheme: const ElevatedButtonThemeData(
                      style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(Blue001),
                          elevation: MaterialStatePropertyAll(10)
                          //surfaceTintColor: MaterialStatePropertyAll(Blue001),
                          )),
                  cardTheme: const CardTheme(
                      surfaceTintColor: Colors.white, color: Colors.white),
                  colorScheme: ColorScheme.fromSeed(seedColor: Blue001),
                  useMaterial3: true,
                  fontFamily: 'livvic',
                  textTheme: const TextTheme(
                    displayLarge: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                    displayMedium:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    displaySmall:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                    bodySmall: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        letterSpacing: 0),
                    bodyMedium: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0),
                    bodyLarge: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                    ),
                    labelSmall: TextStyle(
                        fontSize: 14,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  )),
              routerDelegate: RoutemasterDelegate(
                routesBuilder: (context) {
                  return loggedOutRoute;
                },
              ),
              routeInformationParser: const RoutemasterParser(),
            );
          },
          //ErrorText(error: error.toString()),
          loading: () => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Erazor Partner',
            theme: ThemeData(
                scaffoldBackgroundColor: Colors.white,
                bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                  showSelectedLabels: true,
                  showUnselectedLabels: true,
                  selectedItemColor: Blue001,
                  //unselectedItemColor: Colors.black,
                  type: BottomNavigationBarType.fixed,
                  elevation: 10,
                  backgroundColor: Colors.white,
                ),
                bottomSheetTheme:
                    const BottomSheetThemeData(surfaceTintColor: Colors.white),
                dialogTheme: const DialogTheme(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    surfaceTintColor: Colors.white,
                    backgroundColor: Colors.white),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                    foregroundColor: Colors.white, backgroundColor: Blue001),
                appBarTheme: const AppBarTheme(
                    systemOverlayStyle: SystemUiOverlayStyle.light,
                    //color: Blue001,
                    titleTextStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'livvic',
                        letterSpacing: 0),
                    backgroundColor: Blue001,
                    foregroundColor: Colors.white),
                elevatedButtonTheme: const ElevatedButtonThemeData(
                    style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(Blue001),
                        elevation: MaterialStatePropertyAll(10)
                        //surfaceTintColor: MaterialStatePropertyAll(Blue001),
                        )),
                cardTheme: const CardTheme(
                    surfaceTintColor: Colors.white, color: Colors.white),
                colorScheme: ColorScheme.fromSeed(seedColor: Blue001),
                useMaterial3: true,
                fontFamily: 'livvic',
                textTheme: const TextTheme(
                  displayLarge: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                  displayMedium:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  displaySmall:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                  bodySmall: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                      letterSpacing: 0),
                  bodyMedium: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0),
                  bodyLarge: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
                  labelSmall: TextStyle(
                      fontSize: 14,
                      letterSpacing: 0,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                )),
            home: const Scaffold(
              body: Center(
                child: Loader(),
              ),
            ),
          ),
        );
  }
}

/*
class PartnerApp extends ConsumerStatefulWidget {
  const PartnerApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PartnerAppState();
}

class _PartnerAppState extends ConsumerState<PartnerApp> {
  @override
  Widget build(BuildContext context) {
    ref.watch(salonProvider).whenData((value) =>
        ref.read(salonDetailsProvider.notifier).update((state) => value));
    final salon = ref.watch(salonDetailsProvider);
    return ref.watch(authStateChangeProvider).when(
          data: (data) => MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Erazor Partner',
            theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                useMaterial3: true,
                fontFamily: 'livvic'),
            routerDelegate: RoutemasterDelegate(
              routesBuilder: (context) {
                if (data != null && salon != null) {
                  return loggedInRoute;
                } else if (data != null && salon == null) {
                  return unregisteredRoute;
                } else {
                  return loggedOutRoute;
                }
              },
            ),
            routeInformationParser: const RoutemasterParser(),
          ),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }
}
*/




