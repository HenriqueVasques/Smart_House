// lib/widgets/bluetooth_dialog.dart

import 'package:bothouse/servicos/bluetooth_servicos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothDialog extends StatefulWidget {
  const BluetoothDialog({Key? key}) : super(key: key);

  @override
  _BluetoothDialogState createState() => _BluetoothDialogState();
}

class _BluetoothDialogState extends State<BluetoothDialog> {
  final BluetoothServicos _bluetoothServicos = BluetoothServicos();
  List<BluetoothDeviceWithStatus> _devices = [];
  bool _isScanning = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _scanDevices();
  }

  @override
  void dispose() {
    _bluetoothServicos.dispose();
    super.dispose();
  }

  Future<void> _scanDevices() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _devices.clear();
      _errorMessage = null;
    });

    try {
      final scannedDevices = await _bluetoothServicos.scanDevices();
      
      if (mounted) {
        setState(() {
          _devices = scannedDevices
              .map((device) => BluetoothDeviceWithStatus(
                    device: device,
                    connectionStatus: ConnectionStatus.notConnected,
                  ))
              .toList();
          _isScanning = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _errorMessage = 'Erro ao buscar dispositivos: $e';
        });
      }
    }
  }

  Future<void> _connectToDevice(BluetoothDeviceWithStatus deviceWithStatus) async {
    if (deviceWithStatus.connectionStatus == ConnectionStatus.connecting) {
      return;
    }

    setState(() {
      _errorMessage = null;
      deviceWithStatus.connectionStatus = ConnectionStatus.connecting;
    });

    try {
      final result = await _bluetoothServicos.connectToDevice(deviceWithStatus.device);

      if (mounted) {
        setState(() {
          if (result) {
            deviceWithStatus.connectionStatus = ConnectionStatus.connected;
            Navigator.of(context).pop(true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Conectado a ${deviceWithStatus.device.name ?? "dispositivo"}')),
            );
          } else {
            deviceWithStatus.connectionStatus = ConnectionStatus.unavailable;
            _errorMessage = 'Falha ao conectar ${deviceWithStatus.device.name ?? "dispositivo"}';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          deviceWithStatus.connectionStatus = ConnectionStatus.notConnected;
          _errorMessage = 'Erro de conexão: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Dispositivos Bluetooth'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade800),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            if (_isScanning)
              const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              )
            else if (_devices.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text('Nenhum dispositivo encontrado'),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _devices.length,
                  itemBuilder: (context, index) {
                    final deviceWithStatus = _devices[index];
                    final device = deviceWithStatus.device;
                    
                    return ListTile(
                      title: Text(device.name ?? 'Dispositivo sem nome'),
                      subtitle: Text(device.address),
                      trailing: _buildConnectionStatusWidget(deviceWithStatus),
                      onTap: deviceWithStatus.connectionStatus == ConnectionStatus.connecting
                          ? null
                          : () => _connectToDevice(deviceWithStatus),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isScanning ? null : _scanDevices,
          child: const Text('Reescanear'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }

  Widget _buildConnectionStatusWidget(BluetoothDeviceWithStatus deviceWithStatus) {
    switch (deviceWithStatus.connectionStatus) {
      case ConnectionStatus.connecting:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case ConnectionStatus.connected:
        return const Icon(Icons.check_circle, color: Colors.green);
      case ConnectionStatus.unavailable:
        return const Icon(Icons.error, color: Colors.red);
      default:
        return const SizedBox.shrink();
    }
  }
}

class BluetoothDeviceWithStatus {
  final BluetoothDevice device;
  ConnectionStatus connectionStatus;

  BluetoothDeviceWithStatus({
    required this.device,
    this.connectionStatus = ConnectionStatus.notConnected,
  });
}

enum ConnectionStatus {
  notConnected,
  connecting,
  connected,
  unavailable
}