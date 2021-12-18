import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity/connectivity.dart';
import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/cart_controller.dart';
import 'package:efood_multivendor/controller/location_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/wishlist_controller.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


const sound=[
  'my_audio.mp3'
];

class SplashScreen extends StatefulWidget {
  final String orderID;
  SplashScreen({@required this.orderID});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  StreamSubscription<ConnectivityResult> _onConnectivityChanged;
  /*bool _looping = false;*/


  playSound() {
    AudioCache cache = new AudioCache();
    cache.play('audio/my_audio.mp3');
    print('Sounds play 1: ${cache.play('assets/audio/my_audio.mp3')}');
  }
  @override
  void initState() {
    playSound();
    super.initState();
    /*void onPress(){
      if (_looping == false) {
        setState(() {
          _looping = false;
          print("Sound: $playSound('assets/audio/my_audio.mp3')");
        });
      } else {
        playSound();
        print("Sound 3: $playSound('assets/audio/my_audio.mp3')");
      }
    }*/
    bool _firstTime = true;
    _onConnectivityChanged = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if(!_firstTime) 
      {
        bool isNotConnected = result != ConnectivityResult.wifi && result != ConnectivityResult.mobile;
        isNotConnected ? SizedBox() : ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: isNotConnected ? Colors.red : Colors.green,
          duration: Duration(seconds: isNotConnected ? 6000 : 3),
          content: Text(
            isNotConnected ? 'no_connection'.tr : 'connected'.tr,
            textAlign: TextAlign.center,
          ),
        ));
        if(!isNotConnected) {
          _route();
        }
      }
      _firstTime = false;
    });

    Get.find<SplashController>().initSharedData();
    Get.find<CartController>().getCartData();
    _route();

  }
  @override
  void dispose() {
    super.dispose();
    _onConnectivityChanged.cancel();
  }

  void _route() {
    Get.find<SplashController>().getConfigData().then((isSuccess) {
      if(isSuccess) {
        Timer(Duration(seconds: 1), () async {
          int _minimumVersion = 0;
          if(GetPlatform.isAndroid) {
            _minimumVersion = Get.find<SplashController>().configModel.appMinimumVersionAndroid;
          }else if(GetPlatform.isIOS) {
            _minimumVersion = Get.find<SplashController>().configModel.appMinimumVersionIos;
          }
          if(AppConstants.APP_VERSION < _minimumVersion || Get.find<SplashController>().configModel.maintenanceMode) {
            Get.offNamed(RouteHelper.getUpdateRoute(AppConstants.APP_VERSION < _minimumVersion));
          }else {
            if(widget.orderID != null) {
              Get.offNamed(RouteHelper.getOrderDetailsRoute(int.parse(widget.orderID)));
            }else {
              if (Get.find<AuthController>().isLoggedIn()) {
                Get.find<AuthController>().updateToken();
                await Get.find<WishListController>().getWishList();
                if (Get.find<LocationController>().getUserAddress() != null) {
                  Get.offNamed(RouteHelper.getInitialRoute());
                } else {
                  Get.offNamed(RouteHelper.getAccessLocationRoute('splash'));
                }
              } else {
                if (Get.find<SplashController>().showIntro()) {
                  if(AppConstants.languages.length > 1) {
                    Get.offNamed(RouteHelper.getLanguageRoute('splash'));
                  }else {
                    Get.offNamed(RouteHelper.getOnBoardingRoute());
                  }
                } else {
                  Get.offNamed(RouteHelper.getSignInRoute(RouteHelper.splash));
                }
              }
            }
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      key: _globalKey,
      body: Container(
          height: MediaQuery.of(context).size.height*1,
          child: InkWell(
              onTap: (){
                sound.map((e) => playSound());
                playSound();
                print('play sounds:');
               },
              child: Image.asset("assets/image/splash_screen.png",fit: BoxFit.cover,))
      ),

      // sound.map((e) => playSound())
    );
  }

    /*@override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      body: Container(
        height: MediaQuery.of(context).size.height*1,
        child: Image.asset('assets/audio/Ghanta.mp4',fit: BoxFit.fill,),
        *//*Image.asset(Images.user_splash,fit: BoxFit.fill),*//*
      ),
    );
  }*/
}
