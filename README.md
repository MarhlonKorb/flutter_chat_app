# Configuração do Ambiente Flutter com FVM e Android Studio

Este guia descreve como configurar o ambiente de desenvolvimento Flutter utilizando FVM (Flutter Version Management) e Android Studio, com emulador na versão 35 do Android.

## Pré-requisitos

Antes de começar, verifique se você tem os seguintes requisitos instalados:

1. **FVM**:
   - Para instalar o FVM, execute o seguinte comando:
     ```bash
     pub global activate fvm
     ```

2. **Android Studio**:
   - Baixe e instale o Android Studio do site oficial: [Android Studio](https://developer.android.com/studio).
   - Durante a instalação, certifique-se de incluir as opções para Android SDK e Android Virtual Device.

3. **Java Development Kit (JDK)**:
   - Instale o JDK 8 ou superior. A versão recomendada é o JDK 11. Você pode baixar o JDK do site da Oracle ou usar uma distribuição como o OpenJDK.

4. **SDK do Android**:
   - No Android Studio, instale o Android SDK e configure a versão 35 do SDK no SDK Manager.

## Configurando o FVM

1. **Definir a versão do Flutter**:
   - Para definir a versão específica do Flutter que você deseja usar, execute:
     ```bash
     fvm use 3.24.3   # Ex: fvm use stable
     ```

2. **Adicionar FVM ao seu projeto**:
   - Navegue até o diretório do seu projeto:
     ```bash
     cd nome_do_projeto
     ```
   - Crie um arquivo `.fvm/config.json` e adicione a versão do Flutter:
     ```json
     {
       "flutterVersion": 3.24.3
     }
     ```

## Configurando o Android Studio

1. **Iniciar o Android Studio**:
   - Abra o Android Studio e, na tela inicial, clique em "Open an existing Android Studio project".
   - Selecione o diretório do seu projeto Flutter.

2. **Configurar o SDK do Flutter**:
   - Vá para `File` > `Settings` (ou `Preferences` no macOS) > `Languages & Frameworks` > `Flutter`.
   - Defina o caminho do SDK do Flutter, que deve ser algo como:
     ```
     ~/.pub-cache/bin/fvm/flutter
     ```

3. **Criar um emulador**:
   - Vá para `Tools` > `AVD Manager` e clique em `Create Virtual Device`.
   - Selecione o dispositivo que você deseja emular e clique em `Next`.
   - Escolha a imagem do sistema para a versão 35 do Android e clique em `Next`.
   - Revise as configurações e clique em `Finish`.

## Executando o Aplicativo

1. **Executar o aplicativo**:
   - Para iniciar o emulador, volte para o Android Studio e inicie o AVD que você criou.
   - No terminal do seu projeto, execute:
     ```bash
     fvm flutter run
     ```

Comando para gerar a apk:
  - fvm flutter build apk
  - flutter build web

Para web:
Verifique se o suporte para web está ativado no Flutter usando:

flutter devices

Build local:

python -m http.server 8000
