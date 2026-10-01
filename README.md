# Dateme (nome provisório)

Aplicativo Android de **autoconhecimento hormonal**, **100% offline e privado**. Você registra humor, desejos, pensamentos, impulsividade, sintomas e hábitos por botões, e o app cruza esses registros com as fases estimadas do ciclo para mostrar padrões pessoais.

> **Status:** em desenvolvimento (Fase 1). Uso pessoal, sem fins comerciais.
> **Aviso:** o app usa estimativas por calendário. Não é dispositivo médico, não diagnostica e não substitui acompanhamento profissional.

## Princípios

- **Privacidade total:** dados só no aparelho. Sem servidor, sem conta, sem analytics, sem permissão de internet.
- **Banco criptografado** (SQLCipher), com a chave no armazenamento seguro do Android.
- **Honestidade científica:** previsões são "tendências", nunca diagnósticos. Quando o ciclo é irregular, o app diz que não consegue prever em vez de inventar.
- **Registro rápido:** tudo por botões (exceto água, em ml), com anotação curta de até 50 palavras.
- **Recomendações controladas:** só ações de um catálogo do app podem ser sugeridas, e só com base nos padrões dos próprios registros.

## Stack

| Camada | Escolha |
|---|---|
| App | Flutter (Dart), somente Android |
| Banco | SQLite com SQLCipher (via `package:sqlite3` 3.x e build hooks) |
| Chave do banco | `flutter_secure_storage` |
| Análise | Código próprio, sem IA externa |
| Arquitetura | Monólito modular, sem backend |

## Estrutura do projeto

```
lib/
  main.dart
  data/        banco, repositórios, migrações
  domain/      regras de negócio (ciclo, fases, análises), Dart puro
    ciclo/     fase_ciclo, situacao_ciclo, calculadora_ciclo
  ui/          telas, widgets, tema
  services/    notificações, bloqueio, exportação
test/
  domain/ciclo/   testes automatizados do cálculo do ciclo
```

## Regras do ciclo (resumo)

- Dia 1 = primeiro dia de sangramento marcado. Novo ciclo após ≥ 7 dias sem sangramento. Escape (spotting) não inicia ciclo.
- Sem dados: ciclo padrão de 28 dias ("estimativa geral"). Com 3 ciclos ou mais: média dos 3 últimos.
- Ovulação estimada = duração do ciclo − 14 dias. Fases: menstrual, folicular, ovulatória (~3 dias) e lútea.
- Ciclo previsível: 21 a 35 dias, com variação de até 7 dias entre os últimos 3. Fora disso, sem previsão de fase.
- Mais de 90 dias sem menstruação: só análise por hábito.

## Como rodar

Requisitos: Flutter SDK, Android Studio (com SDK, Command-line Tools e NDK) e um celular Android com depuração USB ativada.

```bash
flutter pub get
flutter test        # testes do cálculo do ciclo
flutter run         # roda no celular conectado
```

O primeiro build baixa o SQLCipher pré-compilado do GitHub (requer internet na máquina de desenvolvimento).

## Configuração importante do banco

No `pubspec.yaml`, o SQLCipher é ativado por build hook:

```yaml
hooks:
  user_defines:
    sqlite3:
      source: sqlcipher
```

**Não adicionar** `sqlite3_flutter_libs` nem `sqlcipher_flutter_libs`: a primeira colide com o SQLCipher e a segunda não funciona mais com `sqlite3` 3.x.

## Roadmap

| Fase | Entrega | Situação |
|---|---|---|
| 1 | Projeto Flutter, banco criptografado, cálculo do ciclo com testes | **Em andamento** |
| 2 | Registro do dia com todos os blocos, anotação, água | Pendente |
| 3 | Calendário com filtros, fase atual, edição de dias passados | Pendente |
| 4 | Nuvem do dia, lembrete neutro, PIN/biometria, tema claro e escuro | Pendente |
| 5 | Análise por fase e infográficos | Pendente |
| 6 | Análise por hábito e catálogo de recomendações | Pendente |
| 7 | Exportar/importar, blocos próprios, lembrete de backup | Pendente |
| 8 | Ilustrações e polimento | Pendente |

### Fase 1: situação atual

- [x] Ambiente Flutter e app rodando no celular
- [x] Cálculo do ciclo e das fases, com testes automatizados
- [x] Teste de criptografia do banco no aparelho (`lib/data/teste_criptografia.dart`, descartável)
- [ ] Esquema de tabelas (blocos, opções, dias, registros, notas)
- [ ] Repositórios e testes do banco
- [ ] Remover o teste descartável de criptografia

## Decisões em aberto

- Nome definitivo do app (`dateme_app` é o nome do pacote por enquanto).
- SQLCipher ou SQLite3 Multiple Ciphers para o banco definitivo (decidir antes de criar dados reais).
- Coleção de ilustrações de licença livre (Fase 8).
- Regra de PIN esquecido (assumido: sem recuperação, biometria como alternativa).

## Aviso sobre dados

Este repositório não contém dados pessoais. O arquivo `teste_cripto.db` é gerado apenas no aparelho, em teste, e não é versionado.
