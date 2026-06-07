/// Categorias possíveis para um alimento (em quais refeições ele aparece).
enum CategoriaAlimento {
  cafe('Café'),
  almoco('Almoço'),
  janta('Janta');

  const CategoriaAlimento(this.rotulo);
  final String rotulo;

  static CategoriaAlimento porNome(String nome) =>
      CategoriaAlimento.values.firstWhere((c) => c.name == nome);
}

/// Tipo do alimento.
enum TipoAlimento {
  bebida('Bebida'),
  proteina('Proteína'),
  carboidrato('Carboidrato'),
  fruta('Fruta'),
  grao('Grão');

  const TipoAlimento(this.rotulo);
  final String rotulo;

  static TipoAlimento porNome(String nome) =>
      TipoAlimento.values.firstWhere((t) => t.name == nome);
}

/// Modelo de um alimento cadastrado.
class Alimento {
  Alimento({
    required this.id,
    required this.nome,
    required this.categorias,
    required this.tipo,
    this.fotoPath,
  });

  final String id;
  final String nome;

  /// Um alimento pode pertencer a uma ou mais categorias (café/almoço/janta).
  final List<CategoriaAlimento> categorias;
  final TipoAlimento tipo;
  final String? fotoPath;

  String get categoriasTexto => categorias.isEmpty
      ? 'Sem categoria'
      : categorias.map((c) => c.rotulo).join(', ');

  /// Linha para o banco SQLite (listas viram texto separado por vírgula).
  Map<String, dynamic> toMap() => {
        'id': id,
        'nome': nome,
        'categorias': categorias.map((c) => c.name).join(','),
        'tipo': tipo.name,
        'fotoPath': fotoPath,
      };

  factory Alimento.fromMap(Map<String, dynamic> map) => Alimento(
        id: map['id'] as String,
        nome: map['nome'] as String,
        categorias: (map['categorias'] as String)
            .split(',')
            .where((s) => s.isNotEmpty)
            .map(CategoriaAlimento.porNome)
            .toList(),
        tipo: TipoAlimento.porNome(map['tipo'] as String),
        fotoPath: map['fotoPath'] as String?,
      );
}
