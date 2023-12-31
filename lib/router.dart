import 'package:erazor_partner/ui/GoogleMaps.dart';
import 'package:erazor_partner/ui/MainScreen.dart';
import 'package:erazor_partner/ui/LoginScreen.dart';
import 'package:erazor_partner/ui/SignupScreen.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

final loggedOutRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: LoginScreen()),
});

final unregisteredRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: SignupScreen()),
  '/google_maps': (_) => const MaterialPage(child: GoogleMapScreen()),
});

final loggedInRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: MainScreen()),
});
