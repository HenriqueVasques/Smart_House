import 'dart:async';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothServicos {
  FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;
  BluetoothDevice? connectedDevice;
  BluetoothConnection? _connection;
  
  final _connectionStateController = StreamController<bool>.broadcast();
  Stream<bool> get connectionState => _connectionStateController.stream;

  Future<void> requestPermissions() async {
    await Permission.bluetooth.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    await Permission.location.request();
  }

  Future<List<BluetoothDevice>> scanDevices() async {
    await requestPermissions();
    
    if (!(await bluetooth.isEnabled ?? false)) {
      await bluetooth.requestEnable();
    }

    List<BluetoothDevice> devices = await bluetooth.getBondedDevices();
    
    try {
      StreamSubscription? discoverySubscription = bluetooth.startDiscovery().listen(
        (r) {
          if (!devices.any((device) => device.address == r.device.address)) {
            devices.add(r.device);
          }
        },
        cancelOnError: true,
      );

      await Future.delayed(const Duration(seconds: 12));
      await discoverySubscription.cancel();

      return devices;
    } catch (e) {
      print('Erro ao buscar dispositivos: $e');
      return devices;
    }
  }

  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      // Verifica pareamento, faz pareamento se necessário
      final bondedDevices = await bluetooth.getBondedDevices();
      if (!bondedDevices.any((d) => d.address == device.address)) {
        final bondResult = await bluetooth.bondDeviceAtAddress(device.address);
        if (bondResult != true) {
          print('Falha no pareamento');
          return false;
        }
        await Future.delayed(const Duration(seconds: 2));
      }

      // Fecha conexão existente
      await _connection?.finish();

      // Tenta conexão única
      _connection = await BluetoothConnection.toAddress(device.address)
        .timeout(const Duration(seconds: 15));

      if (_connection?.isConnected ?? false) {
        connectedDevice = device;
        _connectionStateController.add(true);
        
        // Configura listener de recepção de dados
        _connection?.input?.listen(
          (data) => print('Dados recebidos: $data'),
          onDone: () => _handleDisconnection(),
          onError: (error) {
            print('Erro na conexão: $error');
            _handleDisconnection();
          },
          cancelOnError: true,
        );

        return true;
      }

      return false;
    } catch (e) {
      print('Erro de conexão: $e');
      return false;
    }
  }

  void _handleDisconnection() {
    _connection = null;
    connectedDevice = null;
    _connectionStateController.add(false);
  }

  Future<void> desconectar() async {
    await _connection?.finish();
    _handleDisconnection();
  }

  Future<void> dispose() async {
    await desconectar();
    await _connectionStateController.close();
  }
}