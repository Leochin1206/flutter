import 'package:flutter/material.dart';
import '../api_service.dart';

class TelaEditarSensor extends StatefulWidget {
  final Map<String, dynamic> sensor;
  const TelaEditarSensor({super.key, required this.sensor});

  @override
  State<TelaEditarSensor> createState() => _TelaEditarSensorState();
}

class _TelaEditarSensorState extends State<TelaEditarSensor> {
  late TextEditingController txtLocal;
  late TextEditingController txtTipo;
  late TextEditingController txtLat;
  late TextEditingController txtLong;
  late TextEditingController txtResp;
  late TextEditingController txtObs;
  late bool isAtivo;

  @override
  void initState() {
    super.initState();
    txtLocal = TextEditingController(text: widget.sensor['localSensor']);
    txtTipo = TextEditingController(text: widget.sensor['tipo']);
    txtLat = TextEditingController(text: widget.sensor['latitude'].toString());
    txtLong = TextEditingController(text: widget.sensor['longitude'].toString());
    txtResp = TextEditingController(text: widget.sensor['responsavel']);
    txtObs = TextEditingController(text: widget.sensor['observacao']);
    isAtivo = (widget.sensor['status_operacional'] == 1);
  }

  Future<void> _salvar() async {
    final msg = await ApiService.atualizarSensor(widget.sensor['id'], {
      "localSensor": txtLocal.text,
      "tipo": txtTipo.text,
      "latitude": double.tryParse(txtLat.text) ?? widget.sensor['latitude'],
      "longitude": double.tryParse(txtLong.text) ?? widget.sensor['longitude'],
      "responsavel": txtResp.text,
      "observacao": txtObs.text,
      "status_operacional": isAtivo ? 1 : 0 
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      
      if (msg.contains("✅")) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Sensor")),
      body: SingleChildScrollView( 
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(controller: txtLocal, decoration: const InputDecoration(labelText: "Local")),
            const SizedBox(height: 10),
            TextFormField(controller: txtTipo, decoration: const InputDecoration(labelText: "Tipo")),
            const SizedBox(height: 10),
            
            Row(
              children: [
                Expanded(child: TextFormField(controller: txtLat, decoration: const InputDecoration(labelText: "Latitude"))),
                const SizedBox(width: 10),
                Expanded(child: TextFormField(controller: txtLong, decoration: const InputDecoration(labelText: "Longitude"))),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(controller: txtResp, decoration: const InputDecoration(labelText: "Responsável")),
            const SizedBox(height: 10),
            TextFormField(controller: txtObs, decoration: const InputDecoration(labelText: "Observação")),
            const SizedBox(height: 20),
            
            SwitchListTile(
              title: const Text("Status Operacional"),
              subtitle: Text(isAtivo ? "Ativo (Recebendo dados)" : "Inativo"),
              value: isAtivo,
              onChanged: (val) => setState(() => isAtivo = val),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _salvar,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text("SALVAR ALTERAÇÕES"),
            )
          ],
        ),
      ),
    );
  }
}