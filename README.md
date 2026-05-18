# SPX Solo — Gerador de Caracteres

SPX Graphics Controller (SPX Solo) para gerenciamento e controle de gráficos HTML em produção ao vivo.

## Requisitos (Docker)

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/) (incluído no Docker Desktop)

## Executar com Docker

Na raiz do repositório:

```bash
docker compose up -d
```

A aplicação ficará disponível em:

**http://localhost:3011**

### Parar o container

```bash
docker compose down
```

Os dados da aplicação **permanecem** no volume Docker `spx_data` (projetos, configuração, templates e logs). Ao subir novamente com `docker compose up -d`, tudo é restaurado.

### Ver logs

```bash
docker compose logs -f
```

### Rebuild após alterações no código

```bash
docker compose up -d --build
```

### Remover container e apagar todos os dados

```bash
docker compose down -v
```

O parâmetro `-v` remove o volume `spx_data`. Use apenas se quiser começar do zero.

## Dados persistentes

O volume `spx_data` armazena:

| Caminho no volume | Conteúdo |
|-------------------|----------|
| `config.json` | Configuração do servidor (porta, idioma, usuário, etc.) |
| `DATAROOT/` | Projetos e rundowns |
| `ASSETS/` | Templates HTML, plugins, mídia |
| `LOG/` | Logs de acesso |

Coloque templates em `ASSETS/templates` (pela interface web ou copiando arquivos para o volume).

## Configuração padrão (primeira execução)

- **Porta:** 3011
- **Idioma:** português (`portuguese.json`)
- **Usuário:** `admin`
- **Senha:** vazia (altere em Configurações após o primeiro acesso)

Para mudar a porta, edite `SPX_PORT` e o mapeamento em `docker-compose.yml` (ex.: `"8080:8080"`) e ajuste `general.port` em `config.json` se o arquivo já existir no volume.

## Executar sem Docker (desenvolvimento)

```bash
npm install
npm run dev
```

Por padrão o servidor usa a porta **5656** quando rodado diretamente com Node.js (sem Docker).
