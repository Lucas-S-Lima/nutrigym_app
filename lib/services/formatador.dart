import '../models/alimento.dart';
import '../models/cardapio.dart';
import 'app_store.dart';

/// Funções utilitárias para transformar modelos em texto legível,
/// usadas tanto na consulta quanto no compartilhamento.
class Formatador {
  const Formatador._();

  static String alimento(Alimento a) {
    return 'Alimento: ${a.nome}\n'
        'Categoria: ${a.categoriasTexto}\n'
        'Tipo: ${a.tipo.rotulo}';
  }

  static List<String> nomesAlimentos(List<String> ids) {
    final store = AppStore.instance;
    return ids
        .map((id) => store.alimentoPorId(id)?.nome)
        .whereType<String>()
        .toList();
  }

  static String cardapio(Cardapio c) {
    final store = AppStore.instance;
    final usuario = store.usuarioPorId(c.usuarioId);
    final nome = usuario?.nome ?? 'Usuário';

    String refeicao(String titulo, List<String> ids) {
      final nomes = nomesAlimentos(ids);
      if (nomes.isEmpty) return '$titulo:\n  - (vazio)';
      return '$titulo:\n${nomes.map((n) => '  - $n').join('\n')}';
    }

    return 'Cardápio de $nome\n\n'
        '${refeicao('Café da manhã', c.cafeIds)}\n\n'
        '${refeicao('Almoço', c.almocoIds)}\n\n'
        '${refeicao('Janta', c.jantaIds)}';
  }
}
