enum FaseCiclo { menstrual, folicular, ovulatoria, lutea }

enum EstadoPrevisao {
  semDados,         // nenhuma menstruação registrada
  estimativaGeral,  // menos de 3 ciclos: usa 28 dias
  previsivel,       // 3+ ciclos regulares: usa a média dela
  imprevisivel,     // sem previsão segura de fase
  semMenstruacao,   // mais de 90 dias sem sangramento
}