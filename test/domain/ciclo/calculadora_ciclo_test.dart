import 'package:flutter_test/flutter_test.dart';
import 'package:ciclo_app/domain/ciclo/calculadora_ciclo.dart';
import 'package:ciclo_app/domain/ciclo/fase_ciclo.dart';

DateTime d(int ano, int mes, int dia) => DateTime(ano, mes, dia);

List<DateTime> dias(int ano, int mes, int inicio, int fim) =>
    [for (var i = inicio; i <= fim; i++) d(ano, mes, i)];

void main() {
  test('sem dados não há previsão', () {
    final s = CalculadoraCiclo([]).situacaoEm(d(2026, 1, 10));
    expect(s.estado, EstadoPrevisao.semDados);
    expect(s.fase, isNull);
  });

  test('primeiro dia de sangramento: dia 1, menstrual, estimativa geral', () {
    final s = CalculadoraCiclo([d(2026, 1, 1)]).situacaoEm(d(2026, 1, 1));
    expect(s.estado, EstadoPrevisao.estimativaGeral);
    expect(s.diaDoCiclo, 1);
    expect(s.fase, FaseCiclo.menstrual);
    expect(s.duracaoCiclo, 28);
  });

  test('fases em um ciclo padrão de 28 dias', () {
    final calc = CalculadoraCiclo(dias(2026, 1, 1, 5));
    FaseCiclo? fase(int dia) => calc.situacaoEm(d(2026, 1, dia)).fase;
    expect(fase(5), FaseCiclo.menstrual);
    expect(fase(6), FaseCiclo.folicular);
    expect(fase(12), FaseCiclo.folicular);
    expect(fase(13), FaseCiclo.ovulatoria);
    expect(fase(15), FaseCiclo.ovulatoria);
    expect(fase(16), FaseCiclo.lutea);
    expect(fase(28), FaseCiclo.lutea);
  });

  test('7 dias sem sangramento iniciam novo ciclo; menos que isso, não', () {
    final novo = CalculadoraCiclo([d(2026, 1, 1), d(2026, 1, 9)])
        .situacaoEm(d(2026, 1, 9));
    expect(novo.inicioCiclo, DateTime.utc(2026, 1, 9));
    expect(novo.diaDoCiclo, 1);

    final mesmo = CalculadoraCiclo([d(2026, 1, 1), d(2026, 1, 8)])
        .situacaoEm(d(2026, 1, 8));
    expect(mesmo.inicioCiclo, DateTime.utc(2026, 1, 1));
    expect(mesmo.diaDoCiclo, 8);
    expect(mesmo.fase, FaseCiclo.menstrual);
  });

  test('3 ciclos regulares: previsível, usa a média', () {
    final calc = CalculadoraCiclo([
      d(2026, 1, 1), d(2026, 1, 29), d(2026, 2, 26), d(2026, 3, 26),
    ]);
    final s = calc.situacaoEm(d(2026, 3, 26));
    expect(s.estado, EstadoPrevisao.previsivel);
    expect(s.duracaoCiclo, 28);
    expect(s.fase, FaseCiclo.menstrual);
  });

  test('ciclos irregulares: sem previsão de fase', () {
    final calc = CalculadoraCiclo([
      d(2026, 1, 1), d(2026, 1, 20), d(2026, 3, 1), d(2026, 3, 20),
    ]);
    final s = calc.situacaoEm(d(2026, 3, 20));
    expect(s.estado, EstadoPrevisao.imprevisivel);
    expect(s.fase, isNull);
    expect(s.diaDoCiclo, 1);
  });

  test('passou de 35 dias sem nova menstruação: sem previsão de fase', () {
    final s = CalculadoraCiclo([d(2026, 1, 1)]).situacaoEm(d(2026, 2, 15));
    expect(s.estado, EstadoPrevisao.imprevisivel);
    expect(s.diaDoCiclo, 46);
    expect(s.fase, isNull);
  });

  test('mais de 90 dias sem menstruação', () {
    final s = CalculadoraCiclo([d(2026, 1, 1)]).situacaoEm(d(2026, 4, 15));
    expect(s.estado, EstadoPrevisao.semMenstruacao);
    expect(s.diasSemMenstruacao, 104);
  });
}
