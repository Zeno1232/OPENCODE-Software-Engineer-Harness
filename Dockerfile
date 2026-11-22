# eclipse-temurin é uma alternativa ao openjdk (deprecated)
# 21 é a versão do java
# jammy ao invés de alpine pois é mais compatível e testado para java
FROM eclipse-temurin:21-jdk-jammy

WORKDIR /harness

# ao adicionar um user não estamos a trabalhar com as permissões
# de um root (que são todas), o que torna muito mais seguro
# --disabled-password torna automático (não fica à espera de pass)
# --gecos ignora recolha de dados adicionais
# --uid 10001 atribui um id fixo (10001) o que evita conflitos de permissões
RUN adduser --disabled-password --gecos "" --uid 10001 harnessuser

# cria pom.xml na diretoria . (atual)
# run descarrega dependências DURANTE o build
# flag -B significa batch mode = modo não iterativo, logo maven assume opções
# predifinidas ao invés de perguntar
COPY pom.xml .
RUN mvn -B dependency:go-offline

COPY src ./src

# dá permissão total ao harnessuser relativamente à pasta harness
# -R signfica recursivo logo o comando aplica-se a tudo o que está dentro da pasta
RUN chown -R harnessuser:harnessuser /harness

# muda para este user
USER harnessuser

# quando o container inicia corre estes comandos
CMD ["mvn", "clean", "test"]