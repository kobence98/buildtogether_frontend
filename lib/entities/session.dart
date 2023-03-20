import 'dart:convert';
import 'dart:typed_data';
import 'package:http/browser_client.dart';

import 'package:http/http.dart' as http;

import 'package:universal_html/html.dart' as html;

class Session {
  Map<String, String> headers = {};
  String domainName = 'https://innoservice.ubulstudio.com:8080';

  http.Client client = http.Client();

  // String domainName = 'https://10.0.2.2:8087';
  Future<dynamic> get(String url) async {
    http.Response response =
        await client.get(Uri.parse(domainName + url), headers: headers);
    getCookie('JSESSIONID');
    return response;
  }

  Future<dynamic> postLogin(String url, dynamic data) async {
    headers.clear();
    if (client is BrowserClient)
      (client as BrowserClient).withCredentials = true;
    http.Response response = await client.post(Uri.parse(domainName + url), headers: headers, body: data);

    // headers.clear();
    // headers.addAll({'withCredentials': 'true'});
    // http.Response response =
    // await http.post(Uri.parse(domainName + url), body: data, headers: headers);
    return response;
  }

  Future<dynamic> post(String url, dynamic data) async {
    http.Response response = await client.post(Uri.parse(domainName + url),
        body: jsonEncode(data), headers: headers);
    return response;
  }

  Future<dynamic> postJson(String url, dynamic data) async {
    Map<String, String> newHeaders = headers;
    newHeaders.addAll({'Content-type': 'application/json'});
    http.Response response = await client.post(Uri.parse(domainName + url),
        body: jsonEncode(data), headers: headers);
    return response;
  }

  Future<dynamic> postDomainJson(String url, Map<String, String?> data) async {
    data.addAll({'domain': domainName});
    Map<String, String> newHeaders = headers;
    newHeaders.addAll({'Content-type': 'application/json'});
    http.Response response = await client.post(Uri.parse(domainName + url),
        body: jsonEncode(data), headers: headers);
    return response;
  }

  void updateCookie(http.Response response) {
    String? rawCookie = response.headers['Set-Cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      headers['cookie'] =
          (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
  }

  Future<dynamic> sendMultipart(
      String url, Map<String, String> params, Uint8List bytes) async {
    var request =
        new http.MultipartRequest("POST", Uri.parse(domainName + url));
    params.forEach((key, value) {
      request.fields[key] = value;
    });

    request.files.add(new http.MultipartFile.fromBytes(
        'multipartImage', List.from(bytes),
        filename: 'multipartImage'));

    request.headers.addAll(
      {
        'Content-Type': 'application/json',
      },
    );
    return await request.send();
  }

  Future<dynamic> delete(String url) async {
    headers.remove('Content-type');
    http.Response response = await client.delete(Uri.parse(domainName + url),
        body: Map<String, dynamic>(), headers: headers);
    return response;
  }

  String getCookie(String key) {

    String? cookies = html.document.cookie;
    List<String> listValues = cookies != null && cookies.isNotEmpty ? cookies.split(";") : [];
    String matchVal = "";
    for (int i = 0; i < listValues.length; i++) {
      List<String> map = listValues[i].split("=");
      String _key = map[0].trim();
      String _val = map[1].trim();
      if (key == _key) {
        matchVal = _val;
        break;
      }
    }
    return matchVal;
  }
}
