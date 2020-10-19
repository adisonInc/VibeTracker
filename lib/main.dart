import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:weather/weather.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

const priColor = Color(0xFF32db7e);
const mediColor = Color(0xFFf2e200);
const worstColor = Color(0xFFff4c30);
const worseColor = Color(0xFFff9f30);
const betterColor = Color(0xFFaaff00);
const bestColor = Color(0xFFF33ff00);
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
    }
    if (!_weatherCheceked) {
      _getWeather();
    }
    _calendarController = CalendarController();
    _getDay();
  }

  @override
  void dispose() {
    _controller.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  String _location = "BRAK";
  String _locationLatStr = "BRAK";
  String _locationLongStr = "BRAK";
  double _locationLat = 0;
  double _locationLong = 0;
  String _weatherFeel = "BRAK";
  String _weatherTemp = "BRAK";
  String _weatherCloud = "BRAK";
  String _weatherPress = "BRAK";
  bool _locationCheceked = false;
  bool _weatherCheceked = false;
  CalendarController _calendarController;
  var _decodedCoords;
  String address;
  var now;
  var formatter;
  String formattedDate;
  var formattedDateSub;
  var nowSub;
  var formatterSub;
  var formattedDateAdd;
  var nowAdd;
  var formatterAdd;
  final _controller = TextEditingController();

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
      _weatherFeel = "${w.tempFeelsLike}";
      _weatherTemp = "${w.temperature}";
      _weatherCloud = "${w.cloudiness}";
      _weatherPress = "${w.pressure}";
    });
  }

  void _getDay() {
    setState(() {
      now = new DateTime.now();
      formatter = new DateFormat('dd');
      formattedDate = formatter.format(now);
      nowSub = new DateTime.now().subtract(new Duration(days: 1));
      formatterSub = new DateFormat('dd');
      formattedDateSub = formatter.format(nowSub);
      nowAdd = new DateTime.now().add(new Duration(days: 1));
      formatterAdd = new DateFormat('dd');
      formattedDateAdd = formatter.format(nowAdd);
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
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    flex: 1,
                    child: Container(
                      width: MediaQuery.of(context).size.width / 5,
                      height: MediaQuery.of(context).size.height / 10,
                      color: priColor,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 38, 0),
                              child: Text(
                                "$formattedDateSub",
                                style: TextStyle(
                                    color: whiteColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                              child: Text(
                                "Wczoraj",
                                style: TextStyle(
                                    color: whiteColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      width: MediaQuery.of(context).size.width / 4,
                      height: MediaQuery.of(context).size.height / 8,
                      color: priColor,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 40, 0),
                              child: Text(
                                "$formattedDate",
                                style: TextStyle(
                                    color: whiteColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Dzisiaj",
                                style: TextStyle(
                                    color: whiteColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      width: MediaQuery.of(context).size.width / 5,
                      height: MediaQuery.of(context).size.height / 10,
                      color: priColor,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 38, 0),
                              child: Text(
                                "$formattedDateAdd",
                                style: TextStyle(
                                    color: whiteColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Jutro",
                                style: TextStyle(
                                    color: whiteColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Spacer(
              flex: 1,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 25),
              child: Text(
                "Jak sie dzisiaj czujesz?",
                style: TextStyle(
                    color: priColor, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ClipOval(
                  child: Material(
                    color: worstColor, // button color
                    child: InkWell(
                      // inkwell color
                      child: SizedBox(width: 56, height: 56),
                      onTap: () {},
                    ),
                  ),
                ),
                ClipOval(
                  child: Material(
                    color: worseColor, // button color
                    child: InkWell(
                      // inkwell color
                      child: SizedBox(
                        width: 56,
                        height: 56,
                      ),
                      onTap: () {},
                    ),
                  ),
                ),
                ClipOval(
                  child: Material(
                    color: mediColor, // button color
                    child: InkWell(
                      // inkwell color
                      child: SizedBox(
                        width: 56,
                        height: 56,
                      ),
                      onTap: () {},
                    ),
                  ),
                ),
                ClipOval(
                  child: Material(
                    color: betterColor, // button color
                    child: InkWell(
                      // inkwell color
                      child: SizedBox(
                        width: 56,
                        height: 56,
                      ),
                      onTap: () {},
                    ),
                  ),
                ),
                ClipOval(
                  child: Material(
                    color: bestColor, // button color
                    child: InkWell(
                      // inkwell color
                      child: SizedBox(
                        width: 56,
                        height: 56,
                      ),
                      onTap: () {},
                    ),
                  ),
                )
              ],
            ),
            Spacer(
              flex: 1,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
              child: Text(
                "Co cie dzisiaj spotkało?",
                style: TextStyle(
                    color: priColor, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: TextFormField(
                controller: _controller,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    focusColor: priColor,
                    hoverColor: priColor),
              ),
            ),
            Spacer(
              flex: 1,
            ),
            Row(
              children: [
                Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: Text(
                      "Pogda dzisiaj:",
                      style: TextStyle(
                          color: priColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    )),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: RichText(
                text: TextSpan(
                  text: "Temp. Odzczuwalna: ",
                  style: TextStyle(fontSize: 20, color: Colors.black),
                  children: <TextSpan>[
                    TextSpan(
                        text: '$_weatherFeel\n',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: priColor)),
                    TextSpan(
                      text: 'Temperatura: ',
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                    TextSpan(
                        text: '$_weatherTemp\n',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: priColor)),
                    TextSpan(
                      text: 'Zachmurzenie: ',
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                    TextSpan(
                        text: '$_weatherCloud%\n',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: priColor)),
                    TextSpan(
                      text: 'Ciśnienie: ',
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                    TextSpan(
                        text: '$_weatherPress hPa\n',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: priColor)),
                  ],
                ),
              ),
            ),
            Spacer(
              flex: 1,
            ),
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
