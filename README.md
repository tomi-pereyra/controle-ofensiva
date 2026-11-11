# Controle de Ofensiva Diária (Streak App) 🔥

Aplicativo móvel minimalista em Flutter focado no acompanhamento e na manutenção de sequências de hábitos e metas diárias ininterruptas (*streaks*).

---

## 📱 Visão Geral e Funcionalidades do Aplicativo

### 1. Acompanhamento da Ofensiva Diária
- **Contador Dinâmico de Dias:** Exibe com destaque o número de dias seguidos de ofensiva.
- **Ícone de Chama Animada:** Identidade visual interativa com gradiente e efeitos de pulso e brilho (*glow*), mudando de estado visual quando o registro do dia é concluído.
- **Check-in com Toque Único:** Botão pulsante para validar o dia atual. Após o registro, o botão é desabilitado até a meia-noite do dia seguinte para evitar duplicações.
- **Feedback Comemorativo:** Exibição de modal comemorativo instantâneo sempre que uma nova insígnia é conquistada.

### 2. Gestão e Controle da Sequência
- **Desfazer Check-in:** Opção para cancelar um registro feito por engano no mesmo dia, recalculando a pontuação e liberando o botão para novo registro.
- **Zerar Ofensiva:** Permite reiniciar a contagem manualmente caso o usuário queira recomeçar sua sequência do zero.
- **Validação de Ciclo de Vida do App:** Quando o app retorna do segundo plano (*resumed*), a continuidade da ofensiva é automaticamente recalculada.

### 3. Sistema de Insígnias (Conquistas Nativas)
Catálogo com 7 marcos de consistência pré-programados:
- 🥉 **Faísca Inicial (3 dias):** Início da disciplina diária.
- ⚡ **Uma Semana Firme (7 dias):** Primeira semana completa.
- 🛡️ **Hábito em Construção (14 dias):** Duas semanas de consistência.
- 🏆 **Mestre do Mês (30 dias):** Um mês ininterrupto.
- 🎖️ **Inabalável (60 dias):** Dois meses de dedicação inabalável.
- 🌟 **Centenário Lendário (100 dias):** Marca de 100 dias seguidos.
- 💎 **Lenda Anual (365 dias):** Um ano inteiro sem falhar.

### 4. Metas e Recompensas Personalizadas
- **Criação de Metas Próprias:** Permite cadastrar incentivos com título, dias alvo e ícone temático (ex.: *"Jantar especial ao completar 15 dias"*).
- **Barra de Progresso Dinâmica:** Acompanhamento visual da porcentagem concluída para cada recompensa cadastrada.
- **Sinalização de Conquista:** Quando a ofensiva atinge ou ultrapassa a meta, a recompensa é destacada visualmente.
- **Exclusão de Metas:** Possibilidade de remover qualquer recompensa customizada.

### 5. Persistência e Modo Offline
- **100% Offline:** Não necessita de cadastro, login ou conexão com a internet.
- **Armazenamento Local:** Todas as informações (ofensiva, datas, insígnias desbloqueadas e recompensas) são persistidas localmente no dispositivo.

### 6. Design e Acessibilidade
- **Material 3:** Interface moderna seguindo as diretrizes de design do Material You.
- **Tema Claro e Escuro:** Suporte automático ao tema do sistema operacional (*Dark Mode* nativo).

---

## ⚙️ Documentação Técnica das Funções do Aplicativo

### 🧠 `StreakController` (`lib/controllers/streak_controller.dart`)
Gerenciador de estado reativo (`ChangeNotifier`) responsável pelas regras de negócio da ofensiva.

| Função / Método | Retorno | Descrição |
| :--- | :--- | :--- |
| `initialize()` | `Future<void>` | Carrega do armazenamento local a ofensiva atual, última data de check-in, insígnias conquistadas e recompensas. Executa a validação de data inicial. |
| `_normalizeDate(DateTime)` | `DateTime` | Zera as horas, minutos e segundos de uma data (00:00:00 local), garantindo comparações de calendário precisas e imunes a oscilações de horário. |
| `_validateStreakStatus()` | `void` | Aplica as regras de continuidade: verifica se a ofensiva já foi feita hoje, se foi feita ontem (ativa aguardando), ou se houve quebra de mais de 1 dia (zerando a ofensiva). |
| `performCheckIn()` | `Future<List<BadgeModel>>` | Valida o estado atual, incrementa a contagem de dias (+1), grava a data de hoje, avalia se novas insígnias foram atingidas e retorna a lista de insígnias recém-desbloqueadas. |
| `undoTodayCheckIn()` | `Future<void>` | Reverte o check-in realizado no dia de hoje: decrementa a pontuação em 1, ajusta a data do último registro para o dia anterior e reabre o botão de registro. |
| `resetStreak()` | `Future<void>` | Zera a pontuação para 0, limpa a data do último registro e notifica a interface. |
| `addCustomReward(...)` | `Future<void>` | Cadastra uma nova recompensa personalizada, ordena a lista por ordem crescente de dias necessários e salva localmente. |
| `removeCustomReward(String id)` | `Future<void>` | Remove uma recompensa personalizada pelo seu identificador e atualiza o armazenamento. |
| `refreshStatus()` | `void` | Força a reavaliação do status da ofensiva em relação ao relógio atual (acionado quando o app sai de segundo plano). |

---

### 💾 `StorageService` (`lib/services/storage_service.dart`)
Camada de abstração de dados e persistência no dispositivo usando `SharedPreferences`.

| Função / Método | Retorno | Descrição |
| :--- | :--- | :--- |
| `init()` | `Future<void>` | Inicializa a instância assíncrona do `SharedPreferences`. |
| `getStreak()` | `int` | Obtém o número de dias da ofensiva gravado localmente (padrão: `0`). |
| `saveStreak(int streak)` | `Future<void>` | Grava o número de dias da ofensiva. |
| `getLastCheckInDate()` | `DateTime?` | Recupera a data do último check-in formatada em `YYYY-MM-DD`. |
| `saveLastCheckInDate(DateTime date)` | `Future<void>` | Persiste a data no formato simplificado `YYYY-MM-DD` para isolar interferências de fuso ou horários parciais. |
| `getUnlockedBadges()` | `List<String>` | Retorna os IDs das insígnias que já foram desbloqueadas pelo usuário. |
| `saveUnlockedBadges(List<String>)` | `Future<void>` | Persiste a lista de IDs de insígnias desbloqueadas. |
| `getRewards()` | `List<RewardModel>` | Lê e desserializa a lista de recompensas gravadas em formato JSON. |
| `saveRewards(List<RewardModel>)` | `Future<void>` | Serializa a lista de recompensas para JSON e salva no armazenamento. |

---

### 🎨 Camada Visual e Widgets (`lib/views/`)

| Arquivo / Componente | Função Principal |
| :--- | :--- |
| **`HomeScreen`** | Tela inicial contendo a chama animada, o placar numérico da ofensiva, o botão de check-in diário e o menu de opções (desfazer/zerar). |
| **`RewardsScreen`** | Tela dividida em abas: **Insígnias** (grid com status de bloqueio/desbloqueio) e **Minhas Metas** (lista de metas com barra de progresso e botão flutuante para adicionar nova). |
| **`FlameIcon`** | Widget visual da chama com efeitos em gradiente (laranja e amarelo), brilho neon (*boxShadow*) e animação de escala/respiração. |
| **`CelebrationDialog`** | Modal comemorativo com ícone ampliado, confetes estilizados e detalhes da insígnia desbloqueada. |
| **`NewRewardDialog`** | Modal inferior (*bottom sheet*) com campos para nome da recompensa, dias necessários e seletor de ícones. |

---

### 📦 Modelos de Dados (`lib/models/`)

- **`BadgeModel`:** Estrutura imutável que define uma insígnia (ID, título, descrição, quantidade de dias exigida e ícone associado). Contém o catálogo estático `defaultBadges`.
- **`RewardModel`:** Modelo com suporte a serialização (`toMap` e `fromMap`) para armazenar metas criadas pelo usuário, incluindo persistência do código e da família do ícone selecionado.

---

## 📐 Regra de Negócio: Como a Ofensiva é Validada

```text
[Abertura do App ou Retorno do Background]
                    │
                    ▼
         Último Check-in existe?
          ├── Não ──> Ofensiva = 0 | Botão liberado
          └── Sim
               │
               ▼
   Diferença em dias (Hoje - Último):
    ├── 0 dias  ──> Concluído por hoje (botão bloqueado)
    ├── 1 dia   ──> Ofensiva mantida (botão liberado para hoje)
    └── >1 dias ──> Quebra de sequência! Ofensiva reiniciada para 0
```

---

## 📁 Estrutura de Pastas

```text
lib/
├── controllers/
│   └── streak_controller.dart     # Regras de negócio, cálculo de datas e reatividade (ChangeNotifier)
├── models/
│   ├── badge_model.dart          # Catálogo de insígnias pré-definidas (3, 7, 14, 30, 60, 100, 365)
│   └── reward_model.dart         # Modelo serializável para metas de recompensas personalizadas
├── services/
│   └── storage_service.dart      # Persistência local 100% offline via SharedPreferences & JSON
├── views/
│   ├── home_screen.dart          # Tela principal: chama animada, contador gigante e check-in
│   ├── rewards_screen.dart       # Aba de Insígnias e Minhas Recompensas (com progresso)
│   └── widgets/
│       ├── celebration_dialog.dart # Modal comemorativo ao desbloquear insígnias
│       ├── flame_icon.dart       # Ícone de chama com gradiente, glow e animação fluida
│       └── new_reward_dialog.dart # Modal inferior para cadastrar nova recompensa e escolher ícone
└── main.dart                     # Entrada do app, temas Material 3 e ciclo de vida (resumed)
```

---

## 🚀 Tecnologias e Dependências

- **[Flutter 3+](https://flutter.dev):** Framework multiplataforma.
- **[shared_preferences](https://pub.dev/packages/shared_preferences):** Armazenamento chave-valor assíncrono para persistência offline.
- **[flutter_animate](https://pub.dev/packages/flutter_animate):** Criação de animações declarativas e fluidas na interface.

---

## ⚡ Como Rodar o Projeto

1. Certifique-se de ter o Flutter 3+ instalado e configurado no seu ambiente.
2. No terminal da pasta do projeto, execute:
```bash
flutter pub get
flutter run
```
