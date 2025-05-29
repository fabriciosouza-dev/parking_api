# Parking API

API de controle de estacionamento desenvolvida em Ruby com MongoDB.

## Funcionalidades

- Registrar entrada de veículos
- Registrar pagamento
- Registrar saída (apenas após pagamento)
- Consultar histórico por placa

## Tecnologias Utilizadas

- Ruby (Sinatra)
- MongoDB
- Docker e Docker Compose
- AASM (State Machine)
- RSpec para testes
- Factory Bot e Faker para testes

## Estrutura do Projeto

```
parking-api/
├── app/
│   ├── concerns/
│   │   └── plate_validatable.rb
│   ├── forms/
│   │   ├── base.rb
│   │   ├── parking_entry.rb
│   │   ├── parking_payment.rb
│   │   ├── parking_exit.rb
│   │   └── parking_history.rb
│   ├── models/
│   │   └── parking.rb
│   └── validators/
│       └── plate_validator.rb
├── config/
│   └── database.rb
├── spec/
│   ├── factories.rb
│   ├── forms/
│   │   ├── base_spec.rb
│   │   ├── parking_entry_spec.rb
│   │   ├── parking_payment_spec.rb
│   │   ├── parking_exit_spec.rb
│   │   └── parking_history_spec.rb
│   ├── models/
│   │   └── parking_spec.rb
│   ├── validators/
│   │   └── plate_validator_spec.rb
│   ├── app_spec.rb
│   └── spec_helper.rb
├── app.rb
├── config.ru
├── Dockerfile
├── docker-compose.yml
├── Gemfile
├── Gemfile.lock
├── INSTALL.md
├── README.md
├── setup.sh
├── run_tests.sh
└── test_api.sh
```

## Endpoints da API

### Registrar Entrada
```
POST /parking
{ "plate": "AAA-1234" }
```

### Registrar Pagamento
```
PUT /parking/:id/pay
```

### Registrar Saída
```
PUT /parking/:id/out
```

### Obter Histórico por Placa
```
GET /parking/:plate
```

## Instalação e Execução

### Manualmente

1. Inicie a aplicação:
   ```bash
   docker compose up -d
   ```

2. Execute os testes:
   ```bash
   docker compose run app bundle exec rspec
   ```

3. Para parar a aplicação:
   ```bash
   docker compose down
   ```

## Padrões de Projeto Utilizados

### State Machine

Utilizamos o padrão State Machine através da gem AASM para gerenciar o ciclo de vida do estacionamento:

- **Estados**: `entered` (inicial), `paid`, `exited`
- **Transições**: 
  - `pay`: de `entered` para `paid`
  - `exit`: de `paid` para `exited` ou de `entered` para `exited` (com período de tolerância)
- **Período de tolerância**: Permite saída sem pagamento se estiver dentro de 15 minutos da entrada

### Form Object

O padrão Form Object foi implementado para separar a lógica de validação e processamento de dados da lógica de negócios. Cada operação da API tem seu próprio Form Object:

- **ParkingEntry**: Valida e processa a entrada de um veículo
- **ParkingPayment**: Valida e processa o pagamento
- **ParkingExit**: Valida e processa a saída de um veículo
- **ParkingHistory**: Valida e busca o histórico por placa

### Concern

O padrão Concern foi utilizado para compartilhar funcionalidades entre diferentes classes:

- **PlateValidatable**: Compartilha a validação de formato de placa

### Factory Pattern (para testes)

Utilizamos o Factory Bot para criar objetos de teste de forma consistente e fácil:

```ruby
parking = build(:parking)
parking_paid = build(:parking, :paid)
parking_left = build(:parking, :left)
```
