/// Modelo de um cardápio montado para um usuário.
///
/// Guarda os IDs dos alimentos escolhidos para cada refeição:
/// - café: 3 opções
/// - almoço: 5 opções
/// - janta: 4 opções
class Cardapio {
  Cardapio({
    required this.id,
    required this.usuarioId,
    required this.cafeIds,
    required this.almocoIds,
    required this.jantaIds,
  });

  final String id;
  final String usuarioId;
  final List<String> cafeIds;
  final List<String> almocoIds;
  final List<String> jantaIds;

  static const int qtdCafe = 3;
  static const int qtdAlmoco = 5;
  static const int qtdJanta = 4;

  /// Linha para o banco SQLite (listas de ids viram texto separado por vírgula).
  Map<String, dynamic> toMap() => {
        'id': id,
        'usuarioId': usuarioId,
        'cafeIds': cafeIds.join(','),
        'almocoIds': almocoIds.join(','),
        'jantaIds': jantaIds.join(','),
      };

  factory Cardapio.fromMap(Map<String, dynamic> map) => Cardapio(
        id: map['id'] as String,
        usuarioId: map['usuarioId'] as String,
        cafeIds: _split(map['cafeIds'] as String),
        almocoIds: _split(map['almocoIds'] as String),
        jantaIds: _split(map['jantaIds'] as String),
      );

  static List<String> _split(String valor) =>
      valor.split(',').where((s) => s.isNotEmpty).toList();
}
