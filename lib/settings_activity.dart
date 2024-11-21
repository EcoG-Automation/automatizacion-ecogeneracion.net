import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsActivity extends StatefulWidget {
  const SettingsActivity({super.key});

  @override
  _SettingsActivityState createState() => _SettingsActivityState();
}

class _SettingsActivityState extends State<SettingsActivity> {
  final TextEditingController _innerRadiusController = TextEditingController();
  final TextEditingController _outerRadiusController = TextEditingController();
  final TextEditingController _insulationThicknessController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _thermalConductivityPipeController = TextEditingController();
  final TextEditingController _thermalConductivityInsulationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _innerRadiusController.text = prefs.getString('innerRadius') ?? '0.0327';
      _outerRadiusController.text = prefs.getString('outerRadius') ?? '0.045';
      _insulationThicknessController.text = prefs.getString('insulationThickness') ?? '0.01';
      _lengthController.text = prefs.getString('length') ?? '4.5';
      _thermalConductivityPipeController.text = prefs.getString('thermalConductivityPipe') ?? '0.24';
      _thermalConductivityInsulationController.text = prefs.getString('thermalConductivityInsulation') ?? '0.036';
    });
  }

  void _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('innerRadius', _innerRadiusController.text);
    prefs.setString('outerRadius', _outerRadiusController.text);
    prefs.setString('insulationThickness', _insulationThicknessController.text);
    prefs.setString('length', _lengthController.text);
    prefs.setString('thermalConductivityPipe', _thermalConductivityPipeController.text);
    prefs.setString('thermalConductivityInsulation', _thermalConductivityInsulationController.text);

    Navigator.pop(context); // Regresar a MainActivity
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuraciones')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Radio Interno
            TextField(
              controller: _innerRadiusController,
              decoration: const InputDecoration(labelText: "Radio Interno de Tubería (m), default: 0.0327"),
            ),
            // Radio Externo
            TextField(
              controller: _outerRadiusController,
              decoration: const InputDecoration(labelText: "Radio Externo de Tubería (m), default: 0.045"),
            ),
            // Espesor del Aislante
            TextField(
              controller: _insulationThicknessController,
              decoration: const InputDecoration(labelText: "Espesor del Aislante (m), default: 0.01"),
            ),
            // Longitud de la Tubería
            TextField(
              controller: _lengthController,
              decoration: const InputDecoration(labelText: "Longitud de la Tubería (m), default: 4.5"),
            ),
            // Conductividad Térmica de la Tubería
            TextField(
              controller: _thermalConductivityPipeController,
              decoration: const InputDecoration(labelText: "Conductividad Térmica de la Tubería (W/m·K), default: ppr"),
            ),
            // Conductividad Térmica del Aislante
            TextField(
              controller: _thermalConductivityInsulationController,
              decoration: const InputDecoration(labelText: "Conductividad Térmica del Aislante (W/m·K), default: rubatex"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveSettings,
              child: const Text("Guardar Configuraciones"),
            ),
          ],
        ),
      ),
    );
  }
}