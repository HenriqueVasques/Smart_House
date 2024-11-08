    // lib/widgets/bluetooth_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../servicos/bluetooth_servicos.dart';

class BluetoothDialog extends StatefulWidget {
  const BluetoothDialog({Key? key}) : super(key: key);

  @override
  State<BluetoothDialog> createState() => _BluetoothDialogState();
}

class _BluetoothDialogState extends State<BluetoothDialog> {
  final BluetoothServicos _bluetoothServicos = BluetoothServicos();
  List<BluetoothDevice> _devices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _iniciarBusca();
  }

  Future<void> _iniciarBusca() async {
    try {
      await _bluetoothServicos.inicializarBluetooth();
      final devices = await _bluetoothServicos.buscarDispositivos();
      setState(() {
        _devices = devices;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao buscar dispositivos: $e'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Dispositivos Disponíveis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_devices.isEmpty)
              const Text('Nenhum dispositivo encontrado')
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _devices.length,
                  itemBuilder: (context, index) {
                    final device = _devices[index];
                    return ListTile(
                      title: Text(device.name ?? 'Dispositivo desconhecido'),
                      subtitle: Text(device.address),
                      onTap: () async {
                        try {
                          await _bluetoothServicos.conectarDispositivo(device);
                          if (mounted) {
                            Navigator.pop(context, true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Conectado a ${device.name}'))
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erro ao conectar: $e'))
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        ),
      ),
    );
  }
}