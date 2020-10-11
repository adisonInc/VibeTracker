import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:weather/weather.dart';

void main() {
  runApp(MyApp());
}

const priColor = Color(0xFF66ffad);
const whiteColor = Colors.white;

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Code week (vibe check)',
      theme: ThemeData(
        primaryColor: priColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _location = "BRAK";
  String _locationLatStr = "BRAK";
  String _locationLongStr = "BRAK";
  double _locationLat = 0;
  double _locationLong = 0;
  String _weatherStr = "BRAK";

  var _decodedCoords;
  String address;

  void _getLocation() async {
    Position position =
        await getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
    setState(() {
      _location = "${position.latitude}, ${position.longitude}";
      _locationLatStr = "${position.latitude}";
      _locationLongStr = "${position.longitude}";
      _locationLat = double.parse(_locationLatStr);
      _locationLong = double.parse(_locationLongStr);
    });
    _getAdress();
  }

  void _getAdress() async {
    final coordinates = new Coordinates(_locationLat, _locationLong);
    _decodedCoords =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = _decodedCoords.first;
    print("${first.featureName} : ${first.addressLine}");
    setState(() {
      address = "${first.addressLine}";
    });
  }

  void _getWeather() async {
    WeatherFactory wf = new WeatherFactory("045cc58f70b079bf695858508c7ea0ba",
        language: Language.POLISH);
    Weather w = await wf.currentWeatherByLocation(_locationLat, _locationLong);
    setState(() {
      _weatherStr =
          "Temperatura Odzcuwalna: ${w.tempFeelsLike}\nTemperatura: ${w.temperature}\nZachmurzenie ${w.cloudiness}\nCiśnienie ${w.pressure}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            IconButton(
                icon: Icon(Icons.menu), color: priColor, onPressed: () {}),
            Spacer(),
            IconButton(
                icon: Icon(Icons.cloud, color: priColor),
                onPressed: () {
                  _getWeather();
                }),
            IconButton(
                icon: Icon(Icons.location_on, color: priColor),
                onPressed: () {
                  _getLocation();
                }),
            IconButton(
                icon: Icon(Icons.help), color: priColor, onPressed: () {}),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.home),
        onPressed: () {},
        backgroundColor: priColor,
        elevation: 0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      appBar: AppBar(
        title: Text(
          "code week (vibecheck)",
          style: TextStyle(color: whiteColor),
        ),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$_location',
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              '$address',
              style: Theme.of(context).textTheme.headline4,
            ),
            Text('$_weatherStr'),
          ],
        ),
      ),
    );
  }
}
