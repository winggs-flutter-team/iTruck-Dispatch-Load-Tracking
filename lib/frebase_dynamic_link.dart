import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:itruck_dispatch/models/delivery_model.dart';
import 'package:itruck_dispatch/models/load_model.dart';
import 'package:itruck_dispatch/models/pickup_model.dart';
import 'package:itruck_dispatch/views/dispatcher/screens/login_screen.dart';
import 'package:itruck_dispatch/views/dispatcher/screens/map_screen.dart';
import 'package:itruck_dispatch/views/driver/screens/login_screen.dart';

FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

class FirebaseDynamicLinkService {
  // static Future<String> createDynamicLink(bool  short, StoryData storyData) async{
  //   String _linkMessage;

  //   final DynamicLinkParameters parameters = DynamicLinkParameters(
  //     uriPrefix: 'Write your uriPrefix here',
  //     link: Uri.parse('Link you want to parse'),
  //     androidParameters: AndroidParameters(
  //       packageName: 'your package name',
  //       minimumVersion: 125,
  //     ),
  //   );

  //   Uri url;
  //   if (short) {
  //     final ShortDynamicLink shortLink = await parameters.buildShortLink();
  //     url = shortLink.shortUrl;
  //   } else {
  //     url = await parameters.buildUrl();
  //   }

  //   _linkMessage = url.toString();
  //   return _linkMessage;
  // }
// https://loadtracking.page.link/map?load=
  Future<String> createdynamiclinkformap(
      String load, String sl, String dl) async {
    final dynamicLinkParams = DynamicLinkParameters(
      link:
          Uri.parse("https://itruckdispatch.com/map?load=$load&sl=$sl&dl=$dl"),
      uriPrefix: "https://loadtracking.page.link",
      androidParameters: const AndroidParameters(
        packageName: "com.loadtracking.itruckdispatchinc",
        // minimumVersion: 30,
      ),
      // iosParameters: const IOSParameters(
      //   bundleId: "com.example.app.ios",
      //   appStoreId: "123456789",
      //   minimumVersion: "1.0.1",
      // ),
      // googleAnalyticsParameters: const GoogleAnalyticsParameters(
      //   source: "twitter",
      //   medium: "social",
      //   campaign: "example-promo",
      // ),
      // socialMetaTagParameters: SocialMetaTagParameters(
      //   title: "Example of a Dynamic Link",
      //   imageUrl: Uri.parse("https://example.com/image.png"),
      // ),
    );

    final dynamicLink =
        await FirebaseDynamicLinks.instance.buildShortLink(dynamicLinkParams);
    return dynamicLink.shortUrl.toString();
  }

  static Future<void> initDynamicLink(BuildContext context) async {
    FirebaseDynamicLinks.instance.onLink.listen(
        (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink.link;
      print(deepLink.toString());
      if (deepLink.pathSegments.contains('dispatcher')) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => DispatcherLoginScreen()));
      } else if (deepLink.pathSegments.contains('map')) {
        var sourcelocation;
        String data = deepLink.toString().split('?')[1];
        String loaddocid = data.split('&')[0].replaceAll('load=', '');
        LoadModel? load;
        await FirebaseFirestore.instance
            .collection('/Loads')
            .doc(loaddocid)
            .get()
            .then((value) async {
          load = await LoadModel()
              .loadModelfromJson(value.data() as Map, value.reference);
        });

        String sl = data.split('&')[1].replaceAll('sl=', '');
        String dl = data.split('&')[2].replaceAll('dl=', '');
        if (sl.startsWith('p_')) {
          PickupModel source = load!.pickups!.firstWhere(
              (element) => element.docref!.id == sl.replaceAll('p_', ''));

          var des;
          if (dl.characters.first == 'p_') {
            des = load!.pickups!.firstWhere(
                (element) => element.docref!.id == dl.replaceAll('p_', ''));
          } else {
            des = load!.deliveries!.firstWhere(
                (element) => element.docref!.id == dl.replaceAll('d_', ''));
          }
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DispatcherMapScreen(
                      load: load!,
                      source: source,
                      destination: des,
                      onlymap: true)));
        } else if (sl.startsWith('d_')) {
          DeliveryModel source = load!.deliveries!.firstWhere(
              (element) => element.docref!.id == sl.replaceAll('d_', ''));

          var des;

          des = load!.deliveries!.firstWhere(
              (element) => element.docref!.id == dl.replaceAll('d_', ''));

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DispatcherMapScreen(
                        load: load!,
                        source: source,
                        destination: des,
                        onlymap: true,
                      )));
        } else {
          var des = load!.pickups!.firstWhere(
              (element) => element.docref!.id == dl.replaceAll('p_', ''));
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DispatcherMapScreen(
                      load: load!,
                      source: load!.currentlocation,
                      destination: des,
                      onlymap: true)));
        }
      } else {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => DriverLoginScreen()));
      }
    }, onError: (e) async {
      print('link error');
    });

    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    try {
      if (data != null) {
        final Uri deepLink = data.link;
        if (deepLink.pathSegments.contains('dispatcher')) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => DispatcherLoginScreen()));
        } else if (deepLink.pathSegments.contains('map')) {
          var sourcelocation;
          String data = deepLink.toString().split('?')[1];
          String loaddocid = data.split('&')[0].replaceAll('load=', '');
          LoadModel? load;
          await FirebaseFirestore.instance
              .collection('/Loads')
              .doc(loaddocid)
              .get()
              .then((value) async {
            load = await LoadModel()
                .loadModelfromJson(value.data() as Map, value.reference);
          });

          String sl = data.split('&')[1].replaceAll('sl=', '');
          String dl = data.split('&')[2].replaceAll('dl=', '');
          if (sl.startsWith('p_')) {
            PickupModel source = load!.pickups!.firstWhere(
                (element) => element.docref!.id == sl.replaceAll('p_', ''));

            var des;
            if (dl.characters.first == 'p_') {
              des = load!.pickups!.firstWhere(
                  (element) => element.docref!.id == dl.replaceAll('p_', ''));
            } else {
              des = load!.deliveries!.firstWhere(
                  (element) => element.docref!.id == dl.replaceAll('d_', ''));
            }
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DispatcherMapScreen(
                        load: load!,
                        source: source,
                        destination: des,
                        onlymap: true)));
          } else if (sl.startsWith('d_')) {
            DeliveryModel source = load!.deliveries!.firstWhere(
                (element) => element.docref!.id == sl.replaceAll('d_', ''));

            var des;

            des = load!.deliveries!.firstWhere(
                (element) => element.docref!.id == dl.replaceAll('d_', ''));

            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DispatcherMapScreen(
                        load: load!,
                        source: source,
                        destination: des,
                        onlymap: true)));
          } else {
            var des = load!.pickups!.firstWhere(
                (element) => element.docref!.id == dl.replaceAll('p_', ''));
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DispatcherMapScreen(
                        load: load!,
                        source: load!.currentlocation,
                        destination: des,
                        onlymap: true)));
          }
        } else {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => DriverLoginScreen()));
        }
      }
    } catch (e) {
      print('No deepLink found');
    }
  }
}
