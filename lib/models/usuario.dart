/// Gênero do usuário.
enum Genero {
  masculino('Masculino'),
  feminino('Feminino'),
  outro('Outro'),
  naoInformado('Prefiro não informar');

  const Genero(this.rotulo);
  final String rotulo;

  static Genero porNome(String? nome) => Genero.values.firstWhere(
        (g) => g.name == nome,
        orElse: () => Genero.naoInformado,
      );
}

/// Modelo de um usuário cadastrado no aplicativo.
class Usuario {
  Usuario({
    required this.id,
    required this.nome,
    required this.dataNascimento,
    required this.genero,
    this.fotoPath,
  });

  final String id;
  final String nome;
  final DateTime dataNascimento;
  final Genero genero;

  /// Caminho local da foto escolhida (pode ser nulo).
  final String? fotoPath;

  /// Idade calculada em função da data de nascimento.
  int get idade {
    final hoje = DateTime.now();
    var anos = hoje.year - dataNascimento.year;
    final aindaNaoFezAniversario = hoje.month < dataNascimento.month ||
        (hoje.month == dataNascimento.month && hoje.day < dataNascimento.day);
    if (aindaNaoFezAniversario) {
      anos--;
    }
    return anos;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'nome': nome,
        'dataNascimento': dataNascimento.toIso8601String(),
        'genero': genero.name,
        'fotoPath': fotoPath,
      };

  factory Usuario.fromMap(Map<String, dynamic> map) => Usuario(
        id: map['id'] as String,
        nome: map['nome'] as String,
        dataNascimento: DateTime.parse(map['dataNascimento'] as String),
        genero: Genero.porNome(map['genero'] as String?),
        fotoPath: map['fotoPath'] as String?,
      );
}
