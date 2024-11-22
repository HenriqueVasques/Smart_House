import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothServicos {
  // Instâncias e variáveis
  FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;
  BluetoothDevice? connectedDevice;
  BluetoothConnection? _connection;
  bool _isConnected = false;
  Timer? _keepAliveTimer;
  static const Duration RECONNECT_DELAY = Duration(milliseconds: 500);
  static const Duration KEEP_ALIVE_INTERVAL = Duration(seconds: 10);

  // Controllers para streams
  final _connectionStateController = StreamController<bool>.broadcast();
  Stream<bool> get connectionState => _connectionStateController.stream;

  final _responseController = StreamController<String>.broadcast();
  Stream<String> get deviceResponse => _responseController.stream;

  // Permissões necessárias
  Future<void> requestPermissions() async {
    await Permission.bluetooth.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    await Permission.location.request();
  }

  // Método para verificar se o Bluetooth está ligado
  Future<bool> isBluetoothEnabled() async {
    return await bluetooth.isEnabled ?? false;
  }

  // Método para ligar o Bluetooth
  Future<bool> enableBluetooth() async {
    return await bluetooth.requestEnable() ?? false;
  }

  // Método para escanear dispositivos
  Future<List<BluetoothDevice>> scanDevices() async {
    await requestPermissions();

    if (!(await isBluetoothEnabled())) {
      await enableBluetooth();
    }

    List<BluetoothDevice> devices = await bluetooth.getBondedDevices();

    try {
      print('Iniciando descoberta de dispositivos...');
      StreamSubscription? discoverySubscription =
          bluetooth.startDiscovery().listen(
        (r) {
          final device = r.device;
          print(
              'Dispositivo encontrado: ${device.name ?? "Sem nome"} (${device.address})');
          if (!devices.any((d) => d.address == device.address)) {
            devices.add(device);
          }
        },
        onError: (error) {
          print('Erro durante a descoberta: $error');
        },
        cancelOnError: true,
      );

      await Future.delayed(const Duration(seconds: 12));
      await discoverySubscription.cancel();
      print('Descoberta finalizada. Total de dispositivos: ${devices.length}');

      return devices;
    } catch (e) {
      print('Erro ao escanear dispositivos: $e');
      return devices;
    }
  }

    // Conecta ao dispositivo
  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      connectedDevice = device;
      _connection = await BluetoothConnection.toAddress(device.address)
          .timeout(const Duration(seconds: 5));

      if (_connection?.isConnected ?? false) {
        _isConnected = true;
        _connectionStateController.add(true);
        _setupListener();
        _startKeepAlive();
        return true;
      }

      return false;
    } catch (e) {
      print('Erro ao conectar: $e');
      return false;
    }
  }

  Future<bool> _establishConnection() async {
    if (connectedDevice == null) return false;

    try {
      _connection = await BluetoothConnection.toAddress(connectedDevice!.address)
          .timeout(const Duration(seconds: 5));

      if (_connection?.isConnected ?? false) {
        print('Conexão estabelecida com sucesso');
        _isConnected = true;
        _connectionStateController.add(true);

        // Configurar listener e iniciar keep-alive
        _setupListener();
        _startKeepAlive();
        
        return true;
      }

      return false;
    } catch (e) {
      print('Erro ao estabelecer conexão: $e');
      return false;
    }
  }

  // Método que configura o listener de dados recebidos
  
  // Configura o listener para dados recebidos
  void _setupListener() {
    _connection?.input?.listen(
      (data) {
        String response = ascii.decode(data).trim();
        print('Recebido do Arduino: $response');
        if (response == "K") {
          sendCommand("A");
          print('Respondido com "A"');
        } else {
          print('Mensagem desconhecida: $response');
        }
      },
      onError: (error) {
        print('Erro na conexão: $error');
        _stopKeepAlive();
      },
      onDone: () {
        print('Conexão encerrada pelo dispositivo');
        _stopKeepAlive();
      },
      cancelOnError: false,
    );
  }




  // Iniciar o keep-alive
  void _startKeepAlive() {
    _keepAliveTimer = Timer.periodic(KEEP_ALIVE_INTERVAL, (timer) async {
      if (_isConnected && (_connection?.isConnected ?? false)) {
        print('Enviando A');
        await sendCommand('A');
      } else {
        print('Conexão perdida, encerrando keep-alive');
        _stopKeepAlive();
      }
    });
  }

  // Parar o keep-alive
  void _stopKeepAlive() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = null;
  }

  // Método genérico para enviar comandos
 Future<void> sendCommand(String command) async {
    try {
      _connection?.output.add(ascii.encode(command));
      await _connection?.output.allSent;
    } catch (e) {
      print('Erro ao enviar comando: $e');
    }
  }


Future<void> turnOnLED() async {
    if (_isConnected) {
      await sendCommand('L');
    }
  }

  // Enviar comando para desligar LED
  Future<void> turnOffLED() async {
    if (_isConnected) {
      await sendCommand('D');
    }
  }


  // Método para verificar se está conectado
   bool get isConnected => _isConnected;
}