import 'package:masjid/Values/Networking.dart';
import 'package:http/http.dart' as http;
var baseURL = 'https://www.jaamemasjid.org/app';

class WebConfig {
  static Future<dynamic> timeURL() async {
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://server10.yellowskydemo.com/portal/madni_masjid/api/api/getTime'));
    http.StreamedResponse response = await request.send();
    return response.stream.bytesToString();
  }

  static Future<dynamic> timeWithDateURL(String tomorrowDate) async {
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://server10.yellowskydemo.com/portal/madni_masjid/api/api/getTime/$tomorrowDate'));
    http.StreamedResponse response = await request.send();
    return response.stream.bytesToString();
  }

  static Future<dynamic> islamicTime(String currentDate) async {
    NetworkHelper networkHelper =
    NetworkHelper('http://api.aladhan.com/v1/gToH?date=$currentDate');
    var dashboard = await networkHelper.getSimpleData('http://api.aladhan.com/v1/gToH?date=$currentDate');
    return dashboard;
  }
}
