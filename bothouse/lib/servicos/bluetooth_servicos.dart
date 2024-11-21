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
      return devices;
    }
  }

  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      final bondedDevices = await bluetooth.getBondedDevices();
      if (!bondedDevices.any((d) => d.address == device.address)) {
        final bondResult = await bluetooth.bondDeviceAtAddress(device.address);
        if (bondResult != true) {
          return false;
        }
        await Future.delayed(const Duration(seconds: 2));
      }

      await _connection?.finish();

      _connection = await BluetoothConnection.toAddress(device.address)
        .timeout(const Duration(seconds: 15), onTimeout: () {
          throw Exception("Timeout ao tentar conectar ao dispositivo Bluetooth");
        });

      if (_connection?.isConnected ?? false) {
        connectedDevice = device;
        _connectionStateController.add(true);
        
        _connection?.input?.listen(
          (data) => {},
          onDone: () => _handleDisconnection(),
          onError: (error) {
            _handleDisconnection();
          },
          cancelOnError: true,
        );

        return true;
      }

      return false;
    } catch (e) {
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