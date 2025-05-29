# Parking API

API de controle de estacionamento desenvolvida em Ruby com MongoDB.

## Funcionalidades

- Registrar entrada de veículos
- Registrar pagamento
- Registrar saída (apenas após pagamento)
- Consultar histórico por placa

## Tecnologias Utilizadas

- Ruby (Rack)
- MongoDB
- Docker e Docker Compose
- RSpec para testes
- Factory Bot e Faker para testes

## Estrutura do Projeto

```
parking-api/
├── app/
│   ├── forms/
│   │   ├── base_form.rb
│   │   ├── parking_entry_form.rb
│   │   ├── parking_payment_form.rb
│   │   ├── parking_exit_form.rb
│   │   └── parking_history_form.rb
│   ├── models/
│   │   └── parking.rb
│   └── validators/
│       └── plate_validator.rb
├── config/
│   └── database.rb
├── spec/
│   ├── factories.rb
│   ├── forms/
│   │   ├── base_form_spec.rb
│   │   ├── parking_entry_form_spec.rb
│   │   ├── parking_payment_form_spec.rb
│   │   ├── parking_exit_form_spec.rb
│   │   └── parking_history_form_spec.rb
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

### Form Object

O padrão Form Object foi implementado para separar a lógica de validação e processamento de dados da lógica de negócios. Cada operação da API tem seu próprio Form Object:

- **ParkingEntryForm**: Valida e processa a entrada de um veículo
- **ParkingPaymentForm**: Valida e processa o pagamento
- **ParkingExitForm**: Valida e processa a saída de um veículo
- **ParkingHistoryForm**: Valida e busca o histórico por placa

### Validator

O padrão Validator foi implementado para encapsular a lógica de validação específica:

- **PlateValidator**: Valida o formato da placa (AAA-9999)

### Factory Pattern (para testes)

Utilizamos o Factory Bot para criar objetos de teste de forma consistente e fácil:

```ruby
parking = build(:parking)
parking_paid = build(:parking, :paid)
parking_left = build(:parking, :left)
```
