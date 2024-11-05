import 'package:cloud_firestore/cloud_firestore.dart'; // Importa a biblioteca do Firestore para interagir com o banco de dados
import 'package:firebase_auth/firebase_auth.dart'; // Importa a biblioteca de autenticação do Firebase
import 'package:firebase_core/firebase_core.dart'; // Importa a biblioteca principal do Firebase para inicialização

Future<void> main() async {
  // Inicializar Firebase
  await Firebase.initializeApp(); // Inicializa o Firebase para poder utilizar seus serviços

  // Função para cadastrar um novo usuário
  Future<String> cadastrarUsuario(String nome, String email, String senha) async {
    try {
      // Cadastrar usuário no Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email, // Email do usuário
        password: senha, // Senha do usuário
      );

      String userId = userCredential.user!.uid; // Obtém o ID único do usuário criado

      // Adicionar detalhes do usuário no Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'nome': nome, // Nome do usuário
        'email': email, // Email do usuário
      });

      print("Usuário $nome cadastrado com sucesso!");
      return userId; // Retorna o ID do usuário para ser usado na função de adicionar cômodos
    } catch (e) {
      print("Erro ao cadastrar usuário: $e");
      return ''; // Retorna uma string vazia em caso de erro
    }
  }

  // Função para adicionar um cômodo e dispositivos para um usuário
  Future<void> adicionarComodo(String userId, String nomeComodo, List<String> dispositivos) async {
    try {
      // Adicionar cômodo na sub-coleção 'comodos' do usuário
      await FirebaseFirestore.instance.collection('users').doc(userId).collection('comodos').add({
        'nome': nomeComodo, // Nome do cômodo
        'dispositivos': dispositivos, // Lista de dispositivos no cômodo
      });

      print("Cômodo $nomeComodo adicionado com sucesso!");
    } catch (e) {
      print("Erro ao adicionar cômodo: $e");
    }
  }

  // Exemplo de uso - Listas de dispositivos para diferentes cômodos
  List<String> dispositivosSala = ['Lâmpada', 'TV'];
  List<String> dispositivosCozinha = ['Geladeira', 'Microondas'];
  List<String> dispositivosQuarto = ['Lâmpada', 'Ar-condicionado'];
  List<String> dispositivosBanheiro = ['Chuveiro', 'Torneira'];

  // Cadastrar e configurar usuários
  String userId1 = await cadastrarUsuario('Usuário 1', 'usuario1@example.com', 'senha_segura');
  if (userId1.isNotEmpty) {
    await adicionarComodo(userId1, 'Sala', dispositivosSala);
    await adicionarComodo(userId1, 'Cozinha', dispositivosCozinha);
  }

  String userId2 = await cadastrarUsuario('Usuário 2', 'usuario2@example.com', 'senha_segura');
  if (userId2.isNotEmpty) {
    await adicionarComodo(userId2, 'Quarto', dispositivosQuarto);
    await adicionarComodo(userId2, 'Banheiro', dispositivosBanheiro);
  }

  print('Todos os usuários foram cadastrados e configurados com sucesso!');
}
