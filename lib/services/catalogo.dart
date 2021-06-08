import 'package:australti_ecommerce_app/global/enviroments.dart';
import 'package:australti_ecommerce_app/responses/category_store_response.dart';
import 'package:australti_ecommerce_app/responses/message_error_response.dart';
import 'package:australti_ecommerce_app/responses/store_categories_response.dart';
import 'package:australti_ecommerce_app/store_product_concept/store_product_data.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

class StoreCategoiesService with ChangeNotifier {
  ProfileStoreCategory _catalogo;
  ProfileStoreCategory get catalogo => this._catalogo;

  set catalogo(ProfileStoreCategory valor) {
    this._catalogo = valor;
    // notifyListeners();
  }

  final _storage = new FlutterSecureStorage();

  Future getMyCategoriesProducts(String uid) async {
    // this.authenticated = true;

    final token = await this._storage.read(key: 'token');
    final urlFinal =
        ('${Environment.apiUrl}/api/catalogo/catalogos/products/user/$uid');

    final resp = await http.get(Uri.parse(urlFinal),
        headers: {'Content-Type': 'application/json', 'x-token': token});

    if (resp.statusCode == 200) {
      // final roomResponse = roomsResponseFromJson(resp.body);
      final catalogoResponse = storeCategoriesResponseFromJson(resp.body);
      // this.rooms = roomResponse.rooms;

      return catalogoResponse;
    } else {
      final respBody = errorMessageResponseFromJson(resp.body);

      return respBody;
    }
  }

  Future createCatalogo(ProfileStoreCategory category) async {
    // this.authenticated = true;

    final urlFinal = ('${Environment.apiUrl}/api/catalogo/new');

    final token = await this._storage.read(key: 'token');

    final resp = await http.post(Uri.parse(urlFinal),
        body: jsonEncode(category),
        headers: {'Content-Type': 'application/json', 'x-token': token});

    if (resp.statusCode == 200) {
      // final roomResponse = roomsResponseFromJson(resp.body);
      final catalogoResponse = categoryResponseFromJson(resp.body);
      // this.rooms = roomResponse.rooms;

      return catalogoResponse;
    } else {
      final respBody = errorMessageResponseFromJson(resp.body);

      return respBody;
    }
  }

  Future editCatalogo(ProfileStoreCategory catalogo) async {
    // this.authenticated = true;

    final token = await this._storage.read(key: 'token');
    final urlFinal = ('${Environment.apiUrl}/api/catalogo/update/catalogo');

    final resp = await http.post(Uri.parse(urlFinal),
        body: jsonEncode(catalogo),
        headers: {'Content-Type': 'application/json', 'x-token': token});

    if (resp.statusCode == 200) {
      // final roomResponse = roomsResponseFromJson(resp.body);
      final catalogoResponse = categoryResponseFromJson(resp.body);
      // this.rooms = roomResponse.rooms;

      return catalogoResponse;
    } else {
      final respBody = errorMessageResponseFromJson(resp.body);

      return respBody;
    }
  }

  Future deleteCatalogo(String catalogoId) async {
    final token = await this._storage.read(key: 'token');

    final urlFinal = ('${Environment.apiUrl}/api/catalogo/delete/$catalogoId');

    try {
      await http.delete(Uri.parse(urlFinal),
          headers: {'Content-Type': 'application/json', 'x-token': token});

      return true;
    } catch (e) {
      return false;
    }
  }

  Future updatePositionCatalogo(List<ProfileStoreCategory> catalogos) async {
    // this.authenticated = true;

    final urlFinal = ('${Environment.apiUrl}/api/catalogo/update/position');

    final token = await this._storage.read(key: 'token');

    //final data = {'name': name, 'email': description, 'uid': uid};
    var map = {'catalogos': catalogos, 'user': ""};

    final resp = await http.post(Uri.parse(urlFinal),
        body: json.encode(map),
        headers: {'Content-Type': 'application/json', 'x-token': token});

    if (resp.statusCode == 200) {
      // this.rooms = roomResponse.rooms;

      return true;
    } else {
      final respBody = jsonDecode(resp.body);
      return respBody['msg'];
    }
  }
}