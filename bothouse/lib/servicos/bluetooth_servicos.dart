// lib/servicos/bluetooth_servicos.dart
import 'dart:typed_data';


import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothServicos {
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? _connection;
  
  Future<bool> get isEnabled async => await _bluetooth.isEnabled ?? false;

  
  Future<void> inicializarBluetooth() async {
    try {
      // Verifica se o Bluetooth está ligado
      bool isEnabled = await _bluetooth.isEnabled ?? false;
      if (!isEnabled) {
        // Solicita ao usuário para ligar o Bluetooth
        await _bluetooth.requestEnable();
      }
    } catch (e) {
      print('Erro ao inicializar Bluetooth: $e');
      rethrow;
    }
  }

  Future<List<BluetoothDevice>> buscarDispositivos() async {
    List<BluetoothDevice> devices = [];
    try {
      // Inicia a descoberta de dispositivos
      _bluetooth.startDiscovery().listen(
        (BluetoothDiscoveryResult result) {
          // Adiciona dispositivo se ainda não estiver na lista
          if (!devices.contains(result.device)) {
            devices.add(result.device);
          }
        },
        onDone: () {
          print('Busca de dispositivos concluída');
        },
        onError: (error) {
          print('Erro na busca de dispositivos: $error');
        }
      );
      
      // Aguarda alguns segundos para a busca
      await Future.delayed(const Duration(seconds: 10));
      return devices;
    } catch (e) {
      print('Erro ao buscar dispositivos: $e');
      rethrow;
    }
  }

  Future<void> conectarDispositivo(BluetoothDevice device) async {
    try {
      _connection = await BluetoothConnection.toAddress(device.address);
      print('Conectado ao dispositivo: ${device.name}');
      
      // Configura listener para dados recebidos
      _connection?.input?.listen(
        (data) {
          print('Dados recebidos: ${String.fromCharCodes(data)}');
        },
        onDone: () {
          print('Conexão finalizada');
          _connection?.finish();
        },
        onError: (error) {
          print('Erro na conexão: $error');
          _connection?.finish();
        }
      );
    } catch (e) {
      print('Erro ao conectar ao dispositivo: $e');
      rethrow;
    }
  }

  Future<void> desconectar() async {
    try {
      await _connection?.close();
      _connection = null;
    } catch (e) {
      print('Erro ao desconectar: $e');
      rethrow;
    }
  }

  Future<void> enviarDados(String dados) async {
    try {
     _connection?.output.add(Uint8List.fromList(dados.codeUnits));
      await _connection?.output.allSent;
    } catch (e) {
      print('Erro ao enviar dados: $e');
      rethrow;
    }
  }

  bool get isConnected => _connection?.isConnected ?? false;
}