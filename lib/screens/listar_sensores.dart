import 'package:flutter/material.dart';
import '../api_service.dart';
import 'editar_sensor.dart';
import 'graficos_sensor.dart';

class TelaListarSensores extends StatefulWidget {
  const TelaListarSensores({super.key});

  @override
  State<TelaListarSensores> createState() => _TelaListarSensoresState();
}

class _TelaListarSensoresState extends State<TelaListarSensores> {
  late Future<List<dynamic>> _listaSensores;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  void _carregarDados() {
    setState(() {
      _listaSensores = ApiService.listarSensores();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sensores Cadastrados")),
      body: FutureBuilder<List<dynamic>>(
        future: _listaSensores,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Erro: ${snapshot.error}"));
          }
          final lista = snapshot.data ?? [];
          
          if (lista.isEmpty) return const Center(child: Text("Nenhum sensor encontrado."));

          return ListView.builder(
            itemCount: lista.length,
            itemBuilder: (context, index) {
              final s = lista[index];
              final bool ativo = (s['status_operacional'] == 1);

              return Card(
                child: ListTile(
                  leading: Icon(Icons.sensors, color: ativo ? Colors.green : Colors.grey),
                  title: Text(s['localSensor'] ?? "Sem Local"),
                  subtitle: Text("${s['tipo']} - ${ativo ? 'Ativo' : 'Inativo'}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.analytics, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => TelaGraficos(sensor: s)));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () async {
                          final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => TelaEditarSensor(sensor: s)));
                          if (result == true) _carregarDados();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}