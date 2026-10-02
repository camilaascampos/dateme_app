import 'fase_ciclo.dart';
import 'situacao_ciclo.dart';

class _Grupo {
  final DateTime inicio;
  DateTime fim;
  _Grupo(this.inicio) : fim = inicio;
}

/// Recebe os dias de sangramento (SEM os de escape/spotting).
class CalculadoraCiclo {
  static const int diasSemSangramentoParaNovoCiclo = 7;
  static const int duracaoPadrao = 28;
  static const int duracaoMinima = 21;
  static const int duracaoMaxima = 35;
  static const int variacaoMaxima = 7;
  static const int duracaoFaseLutea = 14;
  static const int limiteSemMenstruacao = 90;
  static const int ciclosParaMedia = 3;

  final List<DateTime> _dias;

  CalculadoraCiclo(Iterable<DateTime> diasDeSangramento)
      : _dias = _normalizar(diasDeSangramento);

  static List<DateTime> _normalizar(Iterable<DateTime> dias) {
    final unicos = <DateTime>{
      for (final d in dias) DateTime.utc(d.year, d.month, d.day),
    };
    return unicos.toList()..sort();
  }

  List<_Grupo> _grupos(DateTime ate) {
    final grupos = <_Grupo>[];
    DateTime? anterior;
    for (final d in _dias) {
      if (d.isAfter(ate)) break;
      final novoCiclo = anterior == null ||
          d.difference(anterior).inDays - 1 >= diasSemSangramentoParaNovoCiclo;
      if (novoCiclo) {
        grupos.add(_Grupo(d));
      } else {
        grupos.last.fim = d;
      }
      anterior = d;
    }
    return grupos;
  }

  SituacaoCiclo situacaoEm(DateTime data) {
    final hoje = DateTime.utc(data.year, data.month, data.day);
    final grupos = _grupos(hoje);
    if (grupos.isEmpty) {
      return const SituacaoCiclo(estado: EstadoPrevisao.semDados);
    }

    final atual = grupos.last;
    final diaDoCiclo = hoje.difference(atual.inicio).inDays + 1;
    final diasSem = hoje.difference(atual.fim).inDays;

    SituacaoCiclo semFase(EstadoPrevisao estado, {int? duracao}) =>
        SituacaoCiclo(
          estado: estado,
          inicioCiclo: atual.inicio,
          diaDoCiclo: diaDoCiclo,
          duracaoCiclo: duracao,
          diasSemMenstruacao: diasSem,
        );

    if (diasSem > limiteSemMenstruacao) {
      return semFase(EstadoPrevisao.semMenstruacao);
    }

    // Duração dos ciclos já completos (início a início)
    final duracoes = <int>[
      for (var i = 1; i < grupos.length; i++)
        grupos[i].inicio.difference(grupos[i - 1].inicio).inDays,
    ];

    EstadoPrevisao estado;
    int duracao;
    if (duracoes.length < ciclosParaMedia) {
      estado = EstadoPrevisao.estimativaGeral;
      duracao = duracaoPadrao;
    } else {
      final ultimas = duracoes.sublist(duracoes.length - ciclosParaMedia);
      final menor = ultimas.reduce((a, b) => a < b ? a : b);
      final maior = ultimas.reduce((a, b) => a > b ? a : b);
      final previsivel = menor >= duracaoMinima &&
          maior <= duracaoMaxima &&
          (maior - menor) <= variacaoMaxima;
      if (!previsivel) return semFase(EstadoPrevisao.imprevisivel);
      estado = EstadoPrevisao.previsivel;
      duracao = (ultimas.reduce((a, b) => a + b) / ultimas.length).round();
    }

    if (diaDoCiclo > duracaoMaxima) {
      return semFase(EstadoPrevisao.imprevisivel, duracao: duracao);
    }

    final menstrualFim = atual.fim.difference(atual.inicio).inDays + 1;
    final diaOvulacao = duracao - duracaoFaseLutea;

    final FaseCiclo fase;
    if (diaDoCiclo <= menstrualFim) {
      fase = FaseCiclo.menstrual;
    } else if (diaDoCiclo <= diaOvulacao - 2) {
      fase = FaseCiclo.folicular;
    } else if (diaDoCiclo <= diaOvulacao + 1) {
      fase = FaseCiclo.ovulatoria;
    } else {
      fase = FaseCiclo.lutea;
    }

    return SituacaoCiclo(
      estado: estado,
      inicioCiclo: atual.inicio,
      diaDoCiclo: diaDoCiclo,
      fase: fase,
      duracaoCiclo: duracao,
      diasSemMenstruacao: diasSem,
    );
  }
}