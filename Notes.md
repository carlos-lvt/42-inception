# Docker Compose

## Constrói a imagem
- A imagem é construída por camadas, com base no Dockerfile.
- É constituída por camadas de acordo com os comandos no Dockerfile.
- É algo que tem tudo o que precisa para correr uma app, e mais tarde vai ser instanciada.
- Posso copiar ficheiros do host para lá — a imagem vai criar a cópia.
- Posso definir permissões — a imagem vai guardar essas permissões.
  - **MAS:** se o path for definido como volume em runtime, as permissões
    guardadas são descartadas, ficando com o dono da pasta no host.
    Por isso, preciso de as mudar novamente (`chown`) dentro do entrypoint.
- etc.

## Constrói o container
- O container é um espaço físico baseado na imagem criada.
- No momento de execução:
  - O Docker associa o container à rede definida.
  - O Docker monta os volumes definidos.
    - Basicamente, associa o path do container ao path no host(tipo bind mount)
  - O Docker monta os secrets.
    - Basicamente, cria um path no container com uma **cópia** do
      ficheiro secret que está no host.

## Container a correr
- O container inicia sempre com o comando definido em `CMD` ou
  `ENTRYPOINT`, ficando esse comando como **PID 1**.
- **Problema do daemon, no caso do MariaDB:**
  - Preciso de correr um script, porque preciso de criar a base de
    dados e definir os logins.
    - **Porquê?** Porque, se corresse o `mysqld` normalmente, ele
      ficaria logo à escuta, sem a base de dados que preciso já
      configurada.
  - **Problema do script:** o script torna-se o PID 1, e o `mysqld`
    fica como processo filho.
    - Quando o script termina, o PID 1 desaparece, e o container
      morre — mesmo que o `mysqld` estivesse saudável.
    - Solução: depois de criar a BD e definir tudo, uso `exec` no
      fim do script, para o `mysqld` **substituir** o script e passar
      a ser ele mesmo o PID 1.

## Daemon
Um programa que corre continuamente, em segundo plano (sem interação direta do utilizador), 
tipicamente à escuta de pedidos. Quem o gere (se reinicia, quando arranca) varia consoante o ambiente — numa máquina normal, 
é frequentemente o systemd; dentro de um container Docker, é o próprio Docker (via restart: policy) que assume esse papel, 
e o processo tem de ser o PID 1 para o Docker conseguir geri-lo corretamente.


# MariaDB
- Nada mais é que um servidor preparado para servir conteúdo ligado
  a bases de dados.

- **mysqld**
  - É o *server* — um programa do tipo *daemon*. Internamente, fica
    num loop contínuo, à escuta de ligações numa porta (3306).
  - Este loop é interno ao próprio programa (não é um hack tipo
    `while true`/`tail -f` escrito por mim) — é o comportamento
    normal e esperado de um servidor de base de dados.
  - No meu container, corre como PID 1 (via `exec`), em foreground.

- **mysql** (ou `mariadb`)
  - É o lado do **cliente**. É onde se escrevem os comandos SQL,
    enviados ao `mysqld` para interpretar e executar.
  - **NOTA:** antes de enviar comandos, o cliente precisa de fazer
    login, e o server valida essas credenciais.
  - **EXCEÇÃO:** numa instalação fresca, o `root` ainda não tem
    password — a primeira ligação não a exige. É nessa primeira
    ligação que defino a password do root.

- Caso: faco tudo com docker compose mas quero adicionar uma database nova antes de ficar a escuta
	- tenho de ter um script
		- vai correr sem abrir as portas e vai estar em background
		- acedo a dB e passo os comandos
		- no fim do script
			- fecho este processo