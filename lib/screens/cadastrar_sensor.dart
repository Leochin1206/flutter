import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../api_service.dart';
import 'listar_sensores.dart';

class TelaCadastroSensor extends StatefulWidget {
  const TelaCadastroSensor({super.key});

  @override
  State<TelaCadastroSensor> createState() => _TelaCadastroSensorState();
}

class _TelaCadastroSensorState extends State<TelaCadastroSensor> {
  final _formKey = GlobalKey<FormState>();
  final txtLocal = TextEditingController();
  final txtTipo = TextEditingController();
  final txtMac = TextEditingController();
  final txtLat = TextEditingController();
  final txtLong = TextEditingController();
  final txtResp = TextEditingController();
  final txtObs = TextEditingController();
  bool isAtivo = true;
  bool isLoading = false;

  Future<void> _obterGPS() async {
    setState(() => isLoading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      txtLat.text = position.latitude.toString();
      txtLong.text = position.longitude.toString();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erro GPS: $e")));
      }
    }
    setState(() => isLoading = false);
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final msg = await ApiService.cadastrarSensor({
      "localSensor": txtLocal.text,
      "tipo": txtTipo.text,
      "macAddress": txtMac.text,
      "latitude": double.tryParse(txtLat.text) ?? 0.0,
      "longitude": double.tryParse(txtLong.text) ?? 0.0,
      "responsavel": txtResp.text,
      "observacao": txtObs.text,
      "status_operacional": isAtivo ? 1 : 0, 
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    if (msg.contains("✅")) {
      _limpar();
    }
  }

  void _limpar() {
    txtLocal.clear();
    txtTipo.clear();
    txtMac.clear();
    txtLat.clear();
    txtLong.clear();
    txtResp.clear();
    txtObs.clear();
    setState(() => isAtivo = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cadastrar Sensor")),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                "Menu",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text("Listar Sensores"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TelaListarSensores()),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: txtLocal,
                decoration: const InputDecoration(labelText: "Local"),
                validator: (v) => v!.isEmpty ? "Campo obrigatório" : null,
              ),
              TextFormField(
                controller: txtTipo,
                decoration: const InputDecoration(labelText: "Tipo"),
              ),
              TextFormField(
                controller: txtMac,
                decoration: const InputDecoration(labelText: "MAC Address"),
              ),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: txtLat,
                      decoration: const InputDecoration(labelText: "Latitude"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: txtLong,
                      decoration: const InputDecoration(labelText: "Longitude"),
                    ),
                  ),
                  IconButton(
                    icon: isLoading
                        ? const CircularProgressIndicator()
                        : const Icon(Icons.gps_fixed),
                    onPressed: _obterGPS,
                  ),
                ],
              ),

              TextFormField(
                controller: txtResp,
                decoration: const InputDecoration(labelText: "Responsável"),
              ),
              TextFormField(
                controller: txtObs,
                decoration: const InputDecoration(labelText: "Observação"),
              ),

              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text("Sensor Ativo?"),
                subtitle: Text(isAtivo ? "Operacional" : "Inativo"),
                value: isAtivo,
                onChanged: (val) => setState(() => isAtivo = val),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvar,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("CADASTRAR"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
