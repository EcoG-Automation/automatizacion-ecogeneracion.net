import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'settings_activity.dart'; // Importa el archivo de configuraciones

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Punto de Rocío',

      //NORMAL THEME
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF42A5F5),
        brightness: Brightness.light, // Modo claro

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4064B4), // Color de fondo del AppBar en modo oscuro
          titleTextStyle: TextStyle(
            color: Colors.white, // Color del texto
            fontSize: 24, // Tamaño de la fuente
            fontWeight: FontWeight.bold,
          ), // Color del texto en el AppBar
        ),


        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF4064B4), // Color del texto en el botón
          ),
        ),
      ),



      //DARK THEME

      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF42A5F5),
        brightness: Brightness.dark, // Modo oscuro


        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blueGrey[900], // Color de fondo del AppBar en modo oscuro
          titleTextStyle: const TextStyle(
            color: Colors.white, // Color del texto
            fontSize: 24, // Tamaño de la fuente
            fontWeight: FontWeight.bold,
          ), // Color del texto en el AppBar
        ),


        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blueGrey[900], // Color del texto en el botón
          ),
        ),
      ),




      themeMode: ThemeMode.system, // Cambia entre claro y oscuro según la configuración del sistema
      home: const MainActivity(),
    );
  }
}

class MainActivity extends StatefulWidget {
  const MainActivity({super.key});

  @override
  _MainActivityState createState() => _MainActivityState();
}

class _MainActivityState extends State<MainActivity> {
  final TextEditingController _tempController = TextEditingController();
  final TextEditingController _humController = TextEditingController();
  final TextEditingController _newTempController = TextEditingController();
  final TextEditingController _fluidTempController = TextEditingController();
  final TextEditingController _flowRateController = TextEditingController();
  final TextEditingController _airVelocityController = TextEditingController();

  String _result = '';
  String _dewPoint = '';
  String _pipeTempResult = '';
  bool _showImage = false; // Variable para controlar la visibilidad de la imagen
  bool _showImage2 = false; // Variable para controlar la visibilidad de la imagen

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _tempController.text = prefs.getString('temp') ?? '26';
      _humController.text = prefs.getString('hum') ?? '60';
      _newTempController.text = prefs.getString('temp2') ?? '26';
      _fluidTempController.text = prefs.getString('fluidTemp') ?? '7';
      _flowRateController.text = prefs.getString('flowRate') ?? '0.009318422';
      _airVelocityController.text = prefs.getString('airVelocity') ?? '0.1';
    });
  }

  Future<void> _calculateDewPoint() async {
    double temp = double.tryParse(_tempController.text) ?? 0;
    double hum = double.tryParse(_humController.text) ?? 0;
    double temp2 = double.tryParse(_newTempController.text) ?? 0;

    // Cálculo del punto de rocío
    double Pv = (hum/100)*0.61078*exp((17.27*temp)/(temp + 237.3));
    double Pvs = 0.61078*exp((17.27*temp2)/(temp2 + 237.3));
    double hum2 = min(100*(Pv/Pvs),100);
    //punto de rocio
    double a = 17.368;
    double b = 238.88;
    double alpha = log(hum2/100) + (a*temp2)/(b+temp2);
    double result = (b*alpha)/(a-alpha); // Cambiado a double

    setState(() {
      _result = "Nueva humedad relativa: ${hum2.round()} %";
      _dewPoint = "Punto de rocío: ${result.toStringAsFixed(2)} °C";
    });

    // Guardar preferencias
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('temp', _tempController.text);
    prefs.setString('hum', _humController.text);
    prefs.setString('temp2', _newTempController.text);
    prefs.setString('fluidTemp', _fluidTempController.text);
    prefs.setString('flowRate', _flowRateController.text);
    prefs.setString('airVelocity', _airVelocityController.text);
  }

  void _calculatePipeTemperature() async {
    String num1String = _tempController.text;
    String num2String = _humController.text;
    String num3String = _newTempController.text;
    String numTfluido = _fluidTempController.text.isEmpty ? "7" : _fluidTempController.text;
    String numQfluido = _flowRateController.text.isEmpty ? "0.009318422" : _flowRateController.text;
    String numVaire = _airVelocityController.text.isEmpty ? "0.1" : _airVelocityController.text;

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    double innerRadius = double.tryParse(sharedPreferences.getString("innerRadius") ?? "0") ?? 0;
    double outerRadius = double.tryParse(sharedPreferences.getString("outerRadius") ?? "0") ?? 0;
    double insulationThickness = double.tryParse(sharedPreferences.getString("insulationThickness") ?? "0") ?? 0;
    double length = double.tryParse(sharedPreferences.getString("length") ?? "0") ?? 0;
    double thermalConductivityPipe = double.tryParse(sharedPreferences.getString("thermalConductivityPipe") ?? "0") ?? 0;
    double thermalConductivityInsulation = double.tryParse(sharedPreferences.getString("thermalConductivityInsulation") ?? "0") ?? 0;

    if (num1String.isNotEmpty && num2String.isNotEmpty && num3String.isNotEmpty &&
        numTfluido.isNotEmpty && numQfluido.isNotEmpty && numVaire.isNotEmpty) {

      // Convertir a doble
      double temp = double.parse(num1String);
      double hum = double.parse(num2String);
      double temp2 = double.parse(num3String);
      double Tfluido = double.parse(numTfluido);
      double Qfluido = double.parse(numQfluido);
      double Vaire = double.parse(numVaire);

      // Cálculos
      double A1 = 2 * pi * innerRadius * length;
      double A2 = 2 * pi * outerRadius * length;
      double A3 = 2 * pi * (outerRadius + insulationThickness) * length;

      // Calcular nueva humedad
      double Pv = (hum / 100) * 0.61078 * exp((17.27 * temp) / (temp + 237.3));
      double Pvs = 0.61078 * exp((17.27 * temp2) / (temp2 + 237.3));
      double hum2 = min(100 * (Pv / Pvs), 100);

      // Punto de rocío
      double a = 17.368;
      double b = 238.88;
      double alpha = log(hum2 / 100) + (a * temp2) / (b + temp2);
      double Td = (b * alpha) / (a - alpha);

      // Resistencias térmicas
      //calculamos los valores necesarios para las resistencias termicas
      double TfluidoK = Tfluido + 273.15;
      double uAgua = (exp(-6.944)*exp(2036.8/TfluidoK))/1000;
      double pAgua = 999.83952-0.0678*Tfluido-0.0002*pow(Tfluido,2);
      double vAgua = uAgua/pAgua;
    double VAgua = Qfluido/(pi*pow(innerRadius,2)) ;
    double reAgua = VAgua*(2*innerRadius)/vAgua;
    String flujoDelAgua ;
    if (reAgua < 2300) {
    flujoDelAgua = "Laminar";
    } else if (reAgua > 4000) {
    flujoDelAgua = "Turbulento";
    } else {
    flujoDelAgua = "Zona de transición";
    }
    double cpAgua = 4186;
    double kAgua = 0.58388 + 0.00083 * Tfluido;
    double prAgua = cpAgua*uAgua/kAgua;
    double nuAgua = 0;
    //vaire
    // Verificar las condiciones
    if (reAgua > 10000 && prAgua < 160 && prAgua > 0.7 &&
    (length / (2 * innerRadius)) > 10) {
    nuAgua = 0.023 * pow(reAgua, 0.8) * pow(prAgua, 0.4);
    } else {
    //System.out.println("Las condiciones no se cumplen.");
      setState(() {
        _pipeTempResult =
        "Valores fuera de rango (Re_agua > 10000 && Pr_agua < 160 && Pr_agua > 0.7 && (length / (2 * innerRadius)) > 10)";
      });
    return;
    }

    double hAgua = nuAgua*kAgua/(2*innerRadius);
    double temp2K = temp2 + 273.15;
    double uAire = 0.00001827*((291.15+120)/(temp2K+120))*pow(temp2K/291.15,1.5);
    double pAire = 101325/(286.9*temp2K);
    double kAire = 0.024+0.00005*temp2;
    double cpAire = 1012;
    double prAire = cpAire*uAire/kAire;
    double vAire = uAire/pAire;
    double reAire = Vaire*(2*(outerRadius+insulationThickness))/vAire;

    String flujoDelAire ;
    if (reAire < 2300) {
    flujoDelAire = "Laminar";
    } else if (reAire > 4000) {
    flujoDelAire = "Turbulento";
    } else {
    flujoDelAire = "Zona de transición";
    }

    double nuAire =0.3+((0.62*pow(reAire,0.5)*pow(prAire,0.33333333333333333333333333333333))/(pow(1 + pow(0.4/prAire,0.66666666666666666666666666666667),0.25)))*pow(1 + pow(reAire/282000,0.625),0.8);
    double hAire = nuAire*kAire/(2*(insulationThickness+outerRadius)) ;

    double rConvAgua = 1/(hAgua*A1);
    double rCondTub = log(outerRadius/innerRadius)/(2*pi*length*thermalConductivityPipe);
    double rCondAislante = log((insulationThickness+outerRadius)/outerRadius)/(2*pi*length*thermalConductivityInsulation);
    double rConvAire = 1/(hAire*A3);
    double Rt = rConvAgua+rCondTub+rCondAislante+rConvAire;
    double dqDt = (temp2-Tfluido)/Rt;

    double tTuberia = dqDt*(rConvAgua+rCondTub+rCondAislante)+Tfluido;






    // Resultado final
      setState(() {
        // Actualiza el resultado con el cálculo real
        _pipeTempResult =
        "Temperatura del exterior de la tuberia con el aislante: ${tTuberia.toStringAsFixed(2)} °C"; // Reemplaza con el valor calculado real.
        // Muestra imágenes si es necesario.
        // Si T_tuberia <= Td, muestra imagen condicionalmente.
        _showImage = tTuberia <= Td;
        _showImage2 = tTuberia > Td;
        // Puedes usar un Image widget y controlar su visibilidad.
      });

      // Guardar valores en SharedPreferences si es necesario.

    } else {
      setState(() {
        _pipeTempResult = "Por favor ingrese todos los valores.";
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Punto de Rocío',
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Image.asset("assets/logoecogeneracion1.png"), // Asegúrate de tener esta imagen en tu carpeta assets

              TextField(
                controller: _tempController,
                decoration: const InputDecoration(labelText: "Temperatura(°C)"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _humController,
                decoration: const InputDecoration(labelText: "Humedad(%)"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _newTempController,
                decoration: const InputDecoration(labelText: "Nueva Temperatura(°C)"),
                keyboardType: TextInputType.number,
              ),
              ElevatedButton(
                onPressed: _calculateDewPoint,
                child: const Text("Calcular punto de rocío"),
              ),
              const SizedBox(height: 20),
              Text(_result),
              Text(_dewPoint),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsActivity()));
                },
                child: const Text("Configuraciones"),
              ),

              // Campos adicionales
              TextField(
                controller: _fluidTempController,
                decoration: const InputDecoration(labelText: "Temperatura del fluido(°C), default: 7"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _flowRateController,
                decoration: const InputDecoration(labelText: "Caudal(m³/s), default: 0.009318422"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _airVelocityController,
                decoration: const InputDecoration(labelText: "Velocidad del aire(m/s), default: 0.1"),
                keyboardType: TextInputType.number,
              ),


              ElevatedButton(
                onPressed: _calculatePipeTemperature,
                child: const Text("Calcular temperatura de la tubería"),
              ),
              const SizedBox(height: 20),
              Text(_pipeTempResult),
              if (_showImage)
                Image.asset("assets/tuberia_cond.png"),
              if (_showImage2)
                Image.asset("assets/tuberia_sec.png"),
              const SizedBox(height: 20), // Espacio entre el resultado y el texto
              const Text(
                'Powered by Ronald', // Cambia esto por el texto que desees
                style: TextStyle(
                  fontSize: 16, // Tamaño de fuente
                  fontWeight: FontWeight.normal, // Peso de la fuente
                  color: Colors.black, // Color del texto
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}