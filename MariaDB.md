mysql (ou mariadb) -> o programa CLIENT. Liga-se a um mysqld já a
    correr (local ou remoto), autentica-se com user+password, e a
    partir daí envia comandos SQL para esse servidor processar.

mysqld -> o programa SERVER. Fica sempre a correr (daemon), à
    escuta de ligações. Recebe os comandos SQL enviados pelo client,
    acede/altera as tabelas de dados, e devolve resultados.