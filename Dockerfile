FROM ruby:3.1-slim

WORKDIR /app

# Instalar dependências do sistema
RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Copiar Gemfile e instalar dependências
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copiar o código da aplicação
COPY . .

# Expor a porta que a aplicação vai usar
EXPOSE 3000

# Comando para iniciar a aplicação
CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "3000"]
