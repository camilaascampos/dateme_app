import 'fase_ciclo.dart';

class SituacaoCiclo {
  final EstadoPrevisao estado;
  final DateTime? inicioCiclo;
  final int? diaDoCiclo;
  final FaseCiclo? fase;
  final int? duracaoCiclo;
  final int? diasSemMenstruacao;

  const SituacaoCiclo({
    required this.estado,
    this.inicioCiclo,
    this.diaDoCiclo,
    this.fase,
    this.duracaoCiclo,
    this.diasSemMenstruacao,
  });
}