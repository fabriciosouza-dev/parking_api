# Parking API - Instruções de Instalação

## Requisitos

- Docker
- Docker Compose

## Instalação e Execução

### Método Manual

1. Inicie a aplicação:
   ```
   docker compose up -d
   ```

2. Execute os testes:
   ```
   docker compose run app bundle exec rspec
   ```

3. Para parar a aplicação:
   ```
   docker compose down
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

## Exemplos de Uso com cURL

### Registrar Entrada
```
curl -X POST -d '{"plate": "AAA-1234"}' -H 'Content-type: application/json' http://localhost:3000/parking
```

### Registrar Pagamento
```
curl -X PUT http://localhost:3000/parking/[ID_RETORNADO]/pay
```

### Registrar Saída
```
curl -X PUT http://localhost:3000/parking/[ID_RETORNADO]/out
```

### Obter Histórico
```
curl http://localhost:3000/parking/AAA-1234
```

## Solução de Problemas

### Erro de conexão com o MongoDB
Se você encontrar erros relacionados à conexão com o MongoDB, verifique se:
1. O container do MongoDB está em execução
2. A URL de conexão no arquivo `config/database.rb` está configurada para `mongo:27017`

### Erro ao iniciar a aplicação
Se a aplicação não iniciar corretamente:
1. Verifique os logs com `docker compose logs -f`
2. Certifique-se de que todas as dependências estão instaladas com `docker compose run app bundle install`

### Conflito de portas
Se houver conflito na porta 3000:
1. Pare qualquer serviço que esteja usando essa porta
2. Ou modifique o arquivo `docker-compose.yml` para usar outra porta
