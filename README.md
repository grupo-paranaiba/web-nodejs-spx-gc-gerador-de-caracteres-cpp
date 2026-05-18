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

- No próprio servidor: **http://localhost:3011**
- Na rede local (substitua pelo IP do Linux): **http://192.168.0.23:3011**

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

## Acesso na rede local (Linux)

O `docker-compose.yml` publica a porta **3011** em todas as interfaces (`0.0.0.0`). Se `http://192.168.0.23:3011` retornar **ERR_CONNECTION_REFUSED**, execute estes passos **no servidor Linux** (onde o Docker está rodando).

### 1. Container em execução e porta publicada

```bash
docker compose ps
docker port spx-gc 3011
ss -tlnp | grep 3011
```

Resultado esperado:

- Container `spx-gc` com status **Up**
- `0.0.0.0:3011` (ou `[::]:3011`) em **LISTEN**

### 2. App responde no próprio servidor

```bash
curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:3011/
curl -s -o /dev/null -w "%{http_code}\n" http://192.168.0.23:3011/
```

Ambos devem retornar **200**. Se `127.0.0.1` funcionar e `192.168.0.23` não, o problema é firewall ou interface de rede.

### 3. IP correto da máquina

```bash
ip -4 addr show
hostname -I
```

Confirme que **192.168.0.23** é o IP do adaptador em uso (Wi‑Fi ou Ethernet). Se o IP for outro, use esse na URL.

### 4. Firewall (causa mais comum no Linux)

**UFW (Ubuntu/Debian):**

```bash
sudo ufw status
sudo ufw allow 3011/tcp
sudo ufw reload
```

**firewalld (RHEL/CentOS/Fedora):**

```bash
sudo firewall-cmd --permanent --add-port=3011/tcp
sudo firewall-cmd --reload
```

### 5. Rebuild após alterações

Se o código ou o `docker-compose.yml` foi atualizado no servidor:

```bash
docker compose up -d --build
```

### 6. Cliente na mesma rede

O PC/celular que acessa deve estar na mesma rede (`192.168.0.x`) e sem VPN que isole o tráfego. Teste com ping:

```bash
ping 192.168.0.23
```

## Container em `Restarting` e porta não publicada

Se `docker compose ps` mostra **Restarting (1)** e `docker port spx-gc 3011` responde *no public port published*, o processo **está caindo antes de subir** — não é problema de IP/firewall ainda.

### Ver o erro

```bash
docker compose logs --tail 80 spx-gc
```

### Causas frequentes

| Sintoma nos logs | Solução |
|------------------|---------|
| `sed: can't read config.docker.json` | Imagem antiga — `git pull` e `docker compose build --no-cache` (entrypoint gera config via Node) |
| `exec ... entrypoint.sh failed` | Rebuild: `docker compose up -d --build` (imagem sem conversão CRLF) |
| `Is a directory` em `config.json` | Volume corrompido — ver abaixo |
| `EADDRINUSE` / porta em uso | Outro processo na 3011: `ss -tlnp \| grep 3011` |
| `Unexpected end of JSON input` / `CATASTROPHIC FAILURE` | `config.json` vazio ou corrompido no volume — ver abaixo |

### Corrigir volume `spx_data` corrompido

Às vezes `config.json` virou **pasta** no volume (mount antigo). No servidor:

```bash
docker compose down

docker run --rm \
  -v web-nodejs-spx-gc-gerador-de-caracteres-cpp_spx_data:/spx-data \
  alpine sh -c 'ls -la /spx-data; rm -rf /spx-data/config.json'

docker compose up -d --build
docker compose logs -f spx-gc
```

O nome do volume pode variar. Liste com `docker volume ls | grep spx`.

Se quiser **zerar tudo** (perde projetos e config):

```bash
docker compose down -v
docker compose up -d --build
```

### Conferir que subiu

```bash
docker compose ps          # STATUS: Up
docker port spx-gc 3011    # 0.0.0.0:3011 -> 3011/tcp
curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:3011/
```
