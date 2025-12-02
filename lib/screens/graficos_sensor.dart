import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:intl/intl.dart';
import '../api_service.dart';

class TelaGraficos extends StatefulWidget {
  final Map<String, dynamic> sensor;
  const TelaGraficos({super.key, required this.sensor});

  @override
  State<TelaGraficos> createState() => _TelaGraficosState();
}

class _TelaGraficosState extends State<TelaGraficos> {
  DateTime dataInicial = DateTime.now().subtract(const Duration(days: 1));
  DateTime dataFinal = DateTime.now();
  List<dynamic> dados = [];
  bool carregando = false;

  @override
  void initState() {
    super.initState();
    _buscarDados();
  }

  Future<void> _buscarDados() async {
    setState(() => carregando = true);
    try {
      final formato = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
      final res = await ApiService.getTemperaturas(
        widget.sensor['id'],
        formato.format(dataInicial),
        formato.format(dataFinal),
      );
      setState(() => dados = res);
    } catch (e) {
      print(e);
    }
    setState(() => carregando = false);
  }

  Future<void> _pickDate(bool isInicial) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isInicial) {
          dataInicial = picked;
        } else {
          dataFinal = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double ultimaLeitura = dados.isNotEmpty ? dados.last['valor'] : 0.0;

    return Scaffold(
      appBar: AppBar(title: Text("Gráficos: ${widget.sensor['localSensor']}")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => _pickDate(true), child: Text("De: ${DateFormat('dd/MM').format(dataInicial)}"))),
                const SizedBox(width: 10),
                Expanded(child: OutlinedButton(onPressed: () => _pickDate(false), child: Text("Até: ${DateFormat('dd/MM').format(dataFinal)}"))),
                IconButton(icon: const Icon(Icons.search), onPressed: _buscarDados),
              ],
            ),
            
            const SizedBox(height: 20),
            if (carregando) const CircularProgressIndicator(),

            if (!carregando && dados.isNotEmpty) ...[
              const Text("Última Temperatura", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(
                height: 200,
                child: SfRadialGauge(
                  axes: [
                    RadialAxis(
                      minimum: 0, maximum: 50,
                      ranges: [
                        GaugeRange(startValue: 0, endValue: 20, color: Colors.blue),
                        GaugeRange(startValue: 20, endValue: 30, color: Colors.green),
                        GaugeRange(startValue: 30, endValue: 50, color: Colors.red),
                      ],
                      pointers: [NeedlePointer(value: ultimaLeitura)],
                      annotations: [GaugeAnnotation(widget: Text("$ultimaLeitura °C", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), angle: 90, positionFactor: 0.5)],
                    )
                  ],
                ),
              ),

              const Divider(),
              const Text("Histórico", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              SizedBox(
                height: 300,
                child: LineChart(
                  LineChartData(
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: dados.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['valor'])).toList(),
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 4,
                        dotData: const FlDotData(show: true),
                      )
                    ],
                  ),
                ),
              ),
            ] else if (!carregando)
              const Text("Sem dados para exibir."),
          ],
        ),
      ),
    );
  }
}