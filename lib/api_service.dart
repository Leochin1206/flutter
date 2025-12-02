import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/sensores/';
  static const String temperaturasUrl = 'http://10.0.2.2:8000/temperaturas/';

  static Future<List<dynamic>> listarSensores() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao carregar sensores');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  static Future<String> cadastrarSensor(Map<String, dynamic> dados) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(dados),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return "Cadastro realizado!";
      } else {
        return "Erro: ${response.body}";
      }
    } catch (e) {
      return "Erro de conexão: $e";
    }
  }

  static Future<String> atualizarSensor(int id, Map<String, dynamic> dados) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$id'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(dados),
      );
      if (response.statusCode == 200) {
        return "Atualizado com sucesso!";
      } else {
        return "Erro: ${response.body}";
      }
    } catch (e) {
      return "Erro de conexão: $e";
    }
  }

  static Future<List<dynamic>> getTemperaturas(int id, String de, String ate) async {
    final response = await http.post(
      Uri.parse(temperaturasUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "sensor_id": id,
        "de": de,
        "ate": ate
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao carregar gráfico');
    }
  }
}