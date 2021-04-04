import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:youtube_diegoveloper_challenges/grocery_store/grocery_store_bloc.dart';

import 'grocery_provider.dart';
import 'grocery_store_cart.dart';
import 'grocery_store_list.dart';

const backgroundColor = Color(0XFFF6F5F2);
const cartBarHeight = 120.0;
const _panelTransition = Duration(milliseconds: 500);

class GroceryStoreHome extends StatefulWidget {
  @override
  _GroceryStoreHomeState createState() => _GroceryStoreHomeState();
}

class _GroceryStoreHomeState extends State<GroceryStoreHome> {
  final bloc = GroceryStoreBLoC();
  double get toolBarHeight => kToolbarHeight;

  void _onVerticalGesture(DragUpdateDetails details) {
    if (details.primaryDelta < -7) {
      bloc.changeToCart();
    } else if (details.primaryDelta > 12) {
      bloc.changeToNormal();
    }
  }

  double _getTopForWhitePanel(GroceryState state, Size size) {
    if (state == GroceryState.normal) {
      return -cartBarHeight +
          toolBarHeight -
          MediaQuery.of(context).padding.bottom;
    } else if (state == GroceryState.cart) {
      return -(size.height - toolBarHeight - cartBarHeight / 2) -
          MediaQuery.of(context).padding.bottom;
    }
    return 0.0;
  }

  double _getTopForBlackPanel(GroceryState state, Size size) {
    if (state == GroceryState.normal) {
      return size.height -
          cartBarHeight -
          MediaQuery.of(context).padding.bottom;
    } else if (state == GroceryState.cart) {
      return cartBarHeight / 2 - MediaQuery.of(context).padding.bottom;
    }
    return size.height;
  }

  double _getTopForAppBar(GroceryState state) {
    if (state == GroceryState.normal) {
      return 0.0;
    } else if (state == GroceryState.cart) {
      return -cartBarHeight;
    }
    return -toolBarHeight;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GroceryProvider(
      bloc: bloc,
      child: AnimatedBuilder(
          animation: bloc,
          builder: (context, _) {
            return SafeArea(
              bottom: false,
              child: Scaffold(
                backgroundColor: Colors.black,
                body: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: _panelTransition,
                      curve: Curves.decelerate,
                      left: 0,
                      right: 0,
                      top: _getTopForWhitePanel(bloc.groceryState, size),
                      height: size.height - toolBarHeight,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(
                            30,
                          ),
                          bottomRight: Radius.circular(
                            30,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Container(),
                        ),
                      ),
                    ),
                    AnimatedPositioned(
                      curve: Curves.decelerate,
                      duration: _panelTransition,
                      left: 0,
                      right: 0,
                      top: _getTopForBlackPanel(bloc.groceryState, size),
                      height: size.height - toolBarHeight,
                      child: GestureDetector(
                        onVerticalDragUpdate: _onVerticalGesture,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          color: Colors.black,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: AnimatedSwitcher(
                                  duration: _panelTransition,
                                  child: SizedBox(
                                    height: toolBarHeight,
                                    child: bloc.groceryState ==
                                            GroceryState.normal
                                        ? Row(
                                            children: [
                                              Text(
                                                'Cart',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                ),
                                              ),
                                              Expanded(
                                                child: SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 8.0),
                                                    child: Row(
                                                      children: List.generate(
                                                        bloc.cart.length,
                                                        (index) => Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      8.0),
                                                          child: Stack(
                                                            children: [
                                                              Hero(
                                                                tag:
                                                                    'list_${bloc.cart[index].product.name}details',
                                                                child:
                                                                    CircleAvatar(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white,
                                                                  backgroundImage:
                                                                      AssetImage(
                                                                    bloc
                                                                        .cart[
                                                                            index]
                                                                        .product
                                                                        .image,
                                                                  ),
                                                                ),
                                                              ),
                                                              Positioned(
                                                                right: 0,
                                                                child:
                                                                    CircleAvatar(
                                                                  radius: 10,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .red,
                                                                  child: Text(
                                                                    bloc
                                                                        .cart[
                                                                            index]
                                                                        .quantity
                                                                        .toString(),
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              CircleAvatar(
                                                backgroundColor:
                                                    Color(0xFFF4C459),
                                                child: Text(
                                                  bloc
                                                      .totalCartElements()
                                                      .toString(),
                                                ),
                                              ),
                                            ],
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                ),
                              ),
                              Expanded(child: GroceryStoreCart()),
                            ],
                          ),
                        ),
                      ),
                    ),
                    AnimatedPositioned(
                      curve: Curves.decelerate,
                      duration: _panelTransition,
                      left: 0,
                      right: 0,
                      top: _getTopForAppBar(bloc.groceryState),
                      child: _AppBarGrocery(),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}

const _blueColor = Color(0xFF0D1863);
const _greenColor = Color(0xFF2BBEBA);

class _AppBarGrocery extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15),
      height: 100,
      color: backgroundColor,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'Homepage',
            style: TextStyle(
              color: _blueColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          CircleAvatar(
            backgroundColor: _greenColor,
            radius: 17,
            child: ClipOval(
              child: Image.asset(
                'assets/logo.png',
                height: 30,
                fit: BoxFit.cover,
              ),
            ),
          )
        ],
      ),
    );
  }
}