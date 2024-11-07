import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'settings_activity.dart'; // Importa el archivo de configuraciones

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Punto de Rocío',

      //NORMAL THEME
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Color(0xFF42A5F5),
        brightness: Brightness.light, // Modo claro

        appBarTheme: AppBarTheme(
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
            backgroundColor: Color(0xFF4064B4), // Color del texto en el botón
          ),
        ),
      ),



      //DARK THEME

      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Color(0xFF42A5F5),
        brightness: Brightness.dark, // Modo oscuro


        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blueGrey[900], // Color de fondo del AppBar en modo oscuro
          titleTextStyle: TextStyle(
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
      home: MainActivity(),
    );
  }
}

class MainActivity extends StatefulWidget {
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
      double u_agua = (exp(-6.944)*exp(2036.8/TfluidoK))/1000;
      double p_agua = 999.83952-0.0678*Tfluido-0.0002*pow(Tfluido,2);
      double v_agua = u_agua/p_agua;
    double V_agua = Qfluido/(pi*pow(innerRadius,2)) ;
    double Re_agua = V_agua*(2*innerRadius)/v_agua;
    String Flujo_del_agua ;
    if (Re_agua < 2300) {
    Flujo_del_agua = "Laminar";
    } else if (Re_agua > 4000) {
    Flujo_del_agua = "Turbulento";
    } else {
    Flujo_del_agua = "Zona de transición";
    }
    double Cp_agua = 4186;
    double K_agua = 0.58388 + 0.00083 * Tfluido;
    double Pr_agua = Cp_agua*u_agua/K_agua;
    double Nu_agua = 0;

    // Verificar las condiciones
    if (Re_agua > 10000 && Pr_agua < 160 && Pr_agua > 0.7 &&
    (length / (2 * innerRadius)) > 10) {
    Nu_agua = 0.023 * pow(Re_agua, 0.8) * pow(Pr_agua, 0.4);
    } else {
    //System.out.println("Las condiciones no se cumplen.");
      setState(() {
        _pipeTempResult =
        "Valores fuera de rango (Re_agua > 10000 && Pr_agua < 160 && Pr_agua > 0.7 && (length / (2 * innerRadius)) > 10)";
      });
    return;
    }

    double h_agua = Nu_agua*K_agua/(2*innerRadius);
    double temp2K = temp2 + 273.15;
    double u_aire = 0.00001827*((291.15+120)/(temp2K+120))*pow(temp2K/291.15,1.5);
    double p_aire = 101325/(286.9*temp2K);
    double K_aire = 0.024+0.00005*temp2;
    double Cp_aire = 1012;
    double Pr_aire = Cp_aire*u_aire/K_aire;
    double v_aire = u_aire/p_aire;
    double Re_aire = Vaire*(2*(outerRadius+insulationThickness))/v_aire;

    String Flujo_del_aire ;
    if (Re_aire < 2300) {
    Flujo_del_aire = "Laminar";
    } else if (Re_aire > 4000) {
    Flujo_del_aire = "Turbulento";
    } else {
    Flujo_del_aire = "Zona de transición";
    }

    double Nu_aire =0.3+((0.62*pow(Re_aire,0.5)*pow(Pr_aire,0.33333333333333333333333333333333))/(pow(1 + pow(0.4/Pr_aire,0.66666666666666666666666666666667),0.25)))*pow(1 + pow(Re_aire/282000,0.625),0.8);
    double h_aire = Nu_aire*K_aire/(2*(insulationThickness+outerRadius)) ;

    double R_conv_agua = 1/(h_agua*A1);
    double R_cond_tub = log(outerRadius/innerRadius)/(2*pi*length*thermalConductivityPipe);
    double R_cond_aislante = log((insulationThickness+outerRadius)/outerRadius)/(2*pi*length*thermalConductivityInsulation);
    double R_conv_aire = 1/(h_aire*A3);
    double Rt = R_conv_agua+R_cond_tub+R_cond_aislante+R_conv_aire;
    double dQ_dt = (temp2-Tfluido)/Rt;

    double T_tuberia = dQ_dt*(R_conv_agua+R_cond_tub+R_cond_aislante)+Tfluido;






    // Resultado final
      setState(() {
        // Actualiza el resultado con el cálculo real
        _pipeTempResult =
        "Temperatura del exterior de la tuberia con el aislante: ${T_tuberia.toStringAsFixed(2)} °C"; // Reemplaza con el valor calculado real.
        // Muestra imágenes si es necesario.
        // Si T_tuberia <= Td, muestra imagen condicionalmente.
        _showImage = T_tuberia <= Td;
        _showImage2 = T_tuberia > Td;
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
        title: Text(
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
                decoration: InputDecoration(labelText: "Temperatura(°C)"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _humController,
                decoration: InputDecoration(labelText: "Humedad(%)"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _newTempController,
                decoration: InputDecoration(labelText: "Nueva Temperatura(°C)"),
                keyboardType: TextInputType.number,
              ),
              ElevatedButton(
                onPressed: _calculateDewPoint,
                child: Text("Calcular punto de rocío"),
              ),
              SizedBox(height: 20),
              Text(_result),
              Text(_dewPoint),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsActivity()));
                },
                child: Text("Configuraciones"),
              ),

              // Campos adicionales
              TextField(
                controller: _fluidTempController,
                decoration: InputDecoration(labelText: "Temperatura del fluido(°C), default: 7"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _flowRateController,
                decoration: InputDecoration(labelText: "Caudal(m³/s), default: 0.009318422"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _airVelocityController,
                decoration: InputDecoration(labelText: "Velocidad del aire(m/s), default: 0.1"),
                keyboardType: TextInputType.number,
              ),


              ElevatedButton(
                onPressed: _calculatePipeTemperature,
                child: Text("Calcular temperatura de la tubería"),
              ),
              SizedBox(height: 20),
              Text(_pipeTempResult),
              if (_showImage)
                Image.asset("assets/tuberia_cond.png"),
              if (_showImage2)
                Image.asset("assets/tuberia_sec.png"),
              SizedBox(height: 20), // Espacio entre el resultado y el texto
              Text(
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