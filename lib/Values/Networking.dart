import 'package:http/http.dart' as http;
import 'dart:convert';

class NetworkHelper {
  NetworkHelper(this.path);

  var path;

  Future getData() async {
    var url =
    Uri.https('jaamemasjid.org',path);
    http.Response response = await http.get(url);
    if (response.statusCode == 200) {
      String data = response.body;
      return jsonDecode(data);
    } else {

    }
  }

  Future getSimpleData(String url) async {

    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      String data = response.body;
      return jsonDecode(data);
    } else {

    }
  }

  Future getIslamicData() async {
    var url =
    Uri.http('api.aladhan.com',path);
    http.Response response = await http.get(url);
    print('GetResponse--->${response.body}');
    if (response.statusCode == 200) {
      String data = response.body;
      return jsonDecode(data);
    } else {

    }
  }

}
