import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:weather/weather.dart';

void main() {
  runApp(MyApp());
}

const priColor = Color(0xFF1be374);
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
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    if (!_locationCheceked) {
      _getLocation();
      print(address);
    }
    print(address);
  }

  String _location = "BRAK";
  String _locationLatStr = "BRAK";
  String _locationLongStr = "BRAK";
  double _locationLat = 0;
  double _locationLong = 0;
  String _weatherStr = "BRAK";
  bool _locationCheceked = false;

  var _decodedCoords;
  String address;

  Future<void> _showMyDialogLocation() async {
    var addressDialog = address;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Lokalizacja'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Obecna lokalizajca to:'),
                Text(
                  '$addressDialog',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Odśiweż'),
              onPressed: () {
                _getLocation();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

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

  Future sleep1() {
    return new Future.delayed(const Duration(seconds: 4), () => "4");
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
      key: _scaffoldKey,
      drawer: ClipRRect(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(35), bottomRight: Radius.circular(35)),
          child: Drawer(
            child: ListView(
              children: [
                new Container(
                  child: new DrawerHeader(
                      child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 40, 0, 0),
                    child: Text(
                      "vibe check",
                      style: TextStyle(color: whiteColor, fontSize: 45),
                    ),
                  )),
                  color: priColor,
                ),
                new Container(
                  color: Colors.blueAccent,
                  child: new Column(),
                )
              ],
            ),
          )),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            IconButton(
                icon: Icon(Icons.menu),
                color: priColor,
                onPressed: () => _scaffoldKey.currentState.openDrawer()),
            IconButton(
                icon: Icon(Icons.calendar_today),
                color: priColor,
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => CalendarPage()));
                }),
            IconButton(
                icon: Icon(Icons.notifications),
                color: priColor,
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => NotificationsPage()));
                }),
            Spacer(),
            IconButton(
                icon: Icon(Icons.wb_sunny_rounded, color: priColor),
                onPressed: () {
                  _getWeather();
                }),
            IconButton(
                icon: Icon(Icons.location_on, color: priColor),
                onPressed: () {
                  _showMyDialogLocation();
                }),
            IconButton(
                icon: Icon(Icons.help), color: priColor, onPressed: () {}),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.theater_comedy),
        onPressed: () {},
        backgroundColor: priColor,
        elevation: 0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      appBar: AppBar(
        automaticallyImplyLeading: false, // ukrycie Hamburgera u góry
        actions: <Widget>[Container()],
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
            Text('$_weatherStr'),
          ],
        ),
      ),
    );
  }
}

class NotificationsPage extends StatefulWidget {
  NotificationsPage({Key key}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: priColor,
        ),
      ),
    );
  }
}

class CalendarPage extends StatefulWidget {
  CalendarPage({Key key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(),
    );
  }
}
