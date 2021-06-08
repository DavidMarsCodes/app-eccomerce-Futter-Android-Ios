import 'dart:async';
import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:animations/animations.dart';
import 'package:australti_ecommerce_app/authentication/auth_bloc.dart';
import 'package:australti_ecommerce_app/bloc_globals/bloc_location/bloc/my_location_bloc.dart';
import 'package:australti_ecommerce_app/bloc_globals/notitification.dart';

import 'package:australti_ecommerce_app/models/store.dart';
import 'package:australti_ecommerce_app/preferences/user_preferences.dart';
import 'package:australti_ecommerce_app/responses/store_categories_response.dart';
import 'package:australti_ecommerce_app/routes/routes.dart';
import 'package:australti_ecommerce_app/services/catalogo.dart';
import 'package:australti_ecommerce_app/sockets/socket_connection.dart';
import 'package:australti_ecommerce_app/store_principal/store_principal_bloc.dart';
import 'package:australti_ecommerce_app/store_product_concept/store_product_bloc.dart';
import 'package:australti_ecommerce_app/theme/theme.dart';
import 'package:australti_ecommerce_app/widgets/delete_alert_modal.dart';
import 'package:australti_ecommerce_app/widgets/layout_menu.dart';
import 'package:australti_ecommerce_app/widgets/modal_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:universal_platform/universal_platform.dart';

class PrincipalPage extends StatefulWidget {
  @override
  _PrincipalPageState createState() => _PrincipalPageState();
}

class _PrincipalPageState extends State<PrincipalPage>
    with WidgetsBindingObserver {
  SocketService socketService;

  bool isWeb = UniversalPlatform.isWeb;
  // final notificationService = new NotificationService();
  final prefs = new AuthUserPreferences();

  Store storeAuth;
  AnimationController animation;
  bool isCancelLocation = false;

  @override
  initState() {
    this.socketService = Provider.of<SocketService>(context, listen: false);

    final authService = Provider.of<AuthenticationBLoC>(context, listen: false);

    storeAuth = authService.storeAuth;

    storeAuth = authService.storeAuth;

    categoriesStoreProducts();

    if (!isWeb) locationStatus();
    if (!isWeb) WidgetsBinding.instance.addObserver(this);

    super.initState();

    // getNotificationsActive();

    //  this.socketService.socket?.on('principal-message', _listenMessage);
    /*  this
        .socketService
        .socket
        ?.on('principal-notification', _listenNotification); */
  }

/* 
  void getNotificationsActive() async {
    var notifications =
        await notificationService.getNotificationByUser(profile.user.uid);

    final notifiModel = Provider.of<NotificationModel>(context, listen: false);
    int number = notifiModel.numberNotifiBell;
    number = notifications.subscriptionsNotifi.length;
    notifiModel.numberNotifiBell = number;

    if (number >= 2) {
      final controller = notifiModel.bounceControllerBell;
      controller.forward(from: 0.0);
    }

    int numberMessages = notifiModel.number;
    numberMessages = notifications.messagesNotifi.length;
    notifiModel.number = numberMessages;

  }
 */
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // this.socketService.socket.off('principal-message');
    super.dispose();
  }

  void categoriesStoreProducts() async {
    final storeService =
        Provider.of<StoreCategoiesService>(context, listen: false);

    final StoreCategoriesResponse resp =
        await storeService.getMyCategoriesProducts(storeAuth.user.uid);

    final productsBloc =
        Provider.of<TabsViewScrollBLoC>(context, listen: false);

    print(resp);

    if (resp.ok) {
      productsBloc.storeCategoriesProducts = resp.storeCategoriesProducts;

      print(productsBloc.storeCategoriesProducts);
    }
  }

  bool _isDialogShowing = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final isGranted = await Permission.location.isGranted;

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    final isPermanentlyDenied = await Permission.location.isPermanentlyDenied;

    if (state == AppLifecycleState.resumed) {
      if (isGranted && serviceEnabled) {
        //myLocationBloc.initPositionLocation();

        if (_isDialogShowing) {
          setState(() {
            _isDialogShowing = false;
          });
          Navigator.pop(context);
        }
      } else if (!serviceEnabled) {
        if (!_isDialogShowing) showModalGpsLocation();
        _isDialogShowing = true;
        //Navigator.pop(context);
      } else if (serviceEnabled && isPermanentlyDenied) {
        //if (_isDialogShowing) Navigator.pop(context);
      }
    }

    if (state == AppLifecycleState.inactive) {}
  }
/*   void _listenMessage(dynamic payload) {
    final notifiModel = Provider.of<NotificationModel>(context, listen: false);
    int numberMessages = notifiModel.number;
    numberMessages++;
    notifiModel.number = numberMessages;

    if (numberMessages >= 2) {
      final controller = notifiModel.bounceController;
      controller.forward(from: 0.0);
    }
  } */

  /*  void _listenNotification(dynamic payload) {
    final currentPage =
        Provider.of<MenuModel>(context, listen: false).currentPage;
    if (currentPage != 4) {
      final notifiModel =
          Provider.of<NotificationModel>(context, listen: false);
      int number = notifiModel.numberNotifiBell;
      number++;
      notifiModel.numberNotifiBell = number;

      if (number >= 2) {
        final controller = notifiModel.bounceControllerBell;
        controller.forward(from: 0.0);
      }
    }
  } */

  void showModalGpsLocation() async {
    _isDialogShowing = true;

    showAlertPermissionGpsModalMatCup(
        'Permitir Ubicación',
        'Para encontrar las tiendas y enviar tus pedidos en tu ubicación',
        'Permitir',
        context, () async {
      await Geolocator.openAppSettings();

      Navigator.pop(context);
    }, () {
      Navigator.pop(context);

      _isDialogShowing = false;
    });
  }

  void locationStatus() async {
    final isGranted = await Permission.location.isGranted;
    //final isPermanentlyDenied = await Permission.location.isPermanentlyDenied;
    final isDenied = await Permission.location.isDenied;
    final isPermanentlyDenied = await Permission.location.isPermanentlyDenied;

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (isDenied) {
      final status = await Permission.location.request();

      if (prefs.locationCurrent || prefs.locationSearch) {
      } else {
        accessGps(status);
      }
    } else if (isGranted && serviceEnabled) {
      if (prefs.locationCurrent || prefs.locationSearch) {
      } else {
        accessGps(PermissionStatus.granted);
      }
    } else if (isGranted && !serviceEnabled) {
    } else if (!serviceEnabled) {
      setState(() {
        _isDialogShowing = true;
      });
      showModalGpsLocation();
      //  showMaterialCupertinoBottomSheetLocation(context, 'hello', 'hello2');

      /*  final status = await Permission.location.request();
      print(status);
      accessGps(status); */
    } else if (isPermanentlyDenied) {
      final status = await Permission.location.request();

      accessGps(status);
    }
  }

  void accessGps(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        Timer(new Duration(milliseconds: 300), () {
          showMaterialCupertinoBottomSheetLocation(context, 'hello', 'hello2',
              () {
            myLocationBloc.initPositionLocation();
            Navigator.pop(context);
          }, () {
            Navigator.pop(context);
          });
        });

        break;

      case PermissionStatus.denied:
        showMaterialCupertinoBottomSheetLocation(context, 'hello', 'hello2',
            () {
          showModalGpsLocation();
        }, () {
          Navigator.pop(context);
        });

        setState(() {
          _isDialogShowing = true;
        });

        break;
      case PermissionStatus.restricted:
      case PermissionStatus.permanentlyDenied:
        showMaterialCupertinoBottomSheetLocation(context, 'hello', 'hello2',
            () {
          showModalGpsLocation();
        }, () {
          Navigator.pop(context);
        });
        // openAppSettings();

        break;
      default:
    }
  }

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final ValueNotifier<bool> notifierBottomBarVisible = ValueNotifier(true);
  int currentIndex = 0;
  bool isVisible = true;

  @override
  Widget build(BuildContext context) {
    final currentPage = Provider.of<MenuModel>(context).currentPage;

    final currentTheme = Provider.of<ThemeChanger>(context);

    final _onFirstPage = (currentPage == 0) ? true : false;

    return SafeArea(
        child: Scaffold(
            // endDrawer: PrincipalMenu(),
            body: Stack(
      children: [
        PageTransitionSwitcher(
          duration: Duration(milliseconds: 500),
          reverse: _onFirstPage,
          transitionBuilder: (Widget child, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return SharedAxisTransition(
              fillColor: currentTheme.currentTheme.scaffoldBackgroundColor,
              transitionType: SharedAxisTransitionType.horizontal,
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          },
          child: pageRouter[currentPage].page,
        ),
        _PositionedMenu(),
      ],
    )));
  }
}

class _PositionedMenu extends StatefulWidget {
  @override
  __PositionedMenuState createState() => __PositionedMenuState();
}

int currentIndex = 0;

class __PositionedMenuState extends State<_PositionedMenu> {
  @override
  Widget build(BuildContext context) {
    double widthView = MediaQuery.of(context).size.width;

    final appTheme = Provider.of<ThemeChanger>(context).currentTheme;
    final bloc = Provider.of<StoreBLoC>(context);

    if (widthView > 500) {
      widthView = widthView - 300;
    }

    final currentPage =
        Provider.of<MenuModel>(context, listen: false).currentPage;
    final authService = Provider.of<AuthenticationBLoC>(context);

    return Positioned(
        bottom: 0,
        child: IgnorePointer(
          ignoring: !bloc.isVisible,
          child: Container(
            height: 100,
            width: widthView,
            child: Row(
              children: [
                Spacer(),
                FadeIn(
                  duration: Duration(milliseconds: 200),
                  animate: bloc.isVisible,
                  child: GridLayoutMenu(
                      show: bloc.isVisible,
                      backgroundColor: appTheme.scaffoldBackgroundColor,
                      activeColor: appTheme.accentColor,
                      inactiveColor: Colors.white,
                      items: [
                        GLMenuButton(
                            icon: (currentPage == 0)
                                ? Icons.home
                                : Icons.home_outlined,
                            onPressed: () {
                              if (bloc.isVisible) _onItemTapped(0);
                            }),
                        GLMenuButton(
                            icon: (currentPage == 1)
                                ? Icons.favorite
                                : Icons.favorite_outline,
                            onPressed: () {
                              // if (bloc.isVisible) _onItemTapped(1);
                            }),
                        GLMenuButton(
                            icon: (currentPage == 2)
                                ? Icons.store
                                : Icons.store_outlined,
                            onPressed: () {
                              if (authService.storeAuth.user.uid == '0') {
                                authService.redirect = 'vender';
                                Navigator.push(
                                    context, onBoardCreateStoreRoute());
                              } else if (bloc.isVisible) _onItemTapped(2);
                            }),
                        GLMenuButton(
                            icon: (currentPage == 3)
                                ? Icons.notifications
                                : Icons.notifications_outlined,
                            onPressed: () {
                              if (bloc.isVisible) _onItemTapped(3);
                            }),
                      ]),
                ),
                Spacer(),
              ],
            ),
          ),
        ));
  }

  void _onItemTapped(int index) {
    setState(() {
      currentIndex = index;

      Provider.of<MenuModel>(context, listen: false).currentPage = currentIndex;

      if (currentIndex == 4) {
        Provider.of<NotificationModel>(context, listen: false)
            .numberNotifiBell = 0;
      }
    });
  }
}

class BNBCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(0, 20); // Start
    path.quadraticBezierTo(size.width * 0.20, 0, size.width * 0.35, 0);
    path.quadraticBezierTo(size.width * 0.40, 0, size.width * 0.40, 20);
    path.arcToPoint(Offset(size.width * 0.60, 20),
        radius: Radius.circular(20.0), clockwise: false);
    path.quadraticBezierTo(size.width * 0.60, 0, size.width * 0.65, 0);
    path.quadraticBezierTo(size.width * 0.80, 0, size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 20);
    canvas.drawShadow(path, Colors.black, 5, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class MenuModel with ChangeNotifier {
  int _currentPage = 0;
  int _lastPage = 0;

  int get currentPage => this._currentPage;

  set currentPage(int value) {
    this._currentPage = value;
    notifyListeners();
  }

  int get lastPage => this._lastPage;

  set lastPage(int value) {
    this._lastPage = value;
    notifyListeners();
  }
}