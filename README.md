# 3Tap

Utilitario leve e nativo para macOS que roda na barra de menus e converte toques de tres dedos no trackpad no comando Enter/Return.

---

## Recursos

- **Execucao em Segundo Plano**: Opera exclusivamente na barra de menus (LSUIElement), sem ocupar espaco no Dock.
- **Deteccao Precisa de Gestos**: Integra-se diretamente a API nativa privada MultitouchSupport para capturar eventos de contato no trackpad (integrado ou Magic Trackpad).
- **Filtro Inteligente de Toque**: Aplica validacao de duracao maxima e deslocamento espacial minimo para diferenciar toques intencionais de gestos de rolagem, zoom ou arraste.
- **Desempenho e Eficiencia**: Desenvolvido em Swift e Objective-C/C nativo, com baixo consumo de CPU e memoria.
- **Persistencia e Resiliencia**: Suporte a inicializacao automatica no login do macOS atraves de SMAppService e configuracao resiliente com LaunchAgent (KeepAlive).

---

## Requisitos

- macOS 13.0 (Ventura) ou superior
- Apple Silicon ou Intel
- Xcode Command Line Tools (`swiftc` e `clang`)

---

## Compilacao e Instalacao Local

### 1. Compilar

Execute o script de build:

```bash
chmod +x build.sh
./build.sh
```

O script ira compilar os modulos nativos, criar o pacote `3Tap.app` e assinar o bundle localmente via `codesign`.

### 2. Instalar no Sistema

Mova o executavel para o diretorio de Aplicativos:

```bash
cp -R 3Tap.app /Applications/
open /Applications/3Tap.app
```

---

## Configuracao de Persistencia (LaunchAgent)

Para que o 3Tap inicie automaticamente com o sistema e seja reiniciado de forma resiliente caso o processo seja finalizado:

1. Crie o arquivo `~/Library/LaunchAgents/com.victor.3tap.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.victor.3tap</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Applications/3Tap.app/Contents/MacOS/3Tap</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>ProcessType</key>
    <string>Interactive</string>
</dict>
</plist>
```

2. Carregue o servico com o `launchctl`:

```bash
launchctl load -w ~/Library/LaunchAgents/com.victor.3tap.plist
```

---

## Permissoes do Sistema

Para sintetizar eventos de teclado (`CGEvent`), o macOS requer autorizacao de Acessibilidade:

1. Abra **Ajustes do Sistema > Privacidade e Seguranca > Acessibilidade**.
2. Habilite a permissao para o **3Tap**.

---

## Integracao Continua e Releases (GitHub Actions)

O projeto conta com uma esteira de automacao configurada em `.github/workflows/build-and-release.yml`:

- **Validacao de Build**: Executada automaticamente a cada push ou pull request na branch `main`.
- **Geracao de Artefato**: Compila e disponibiliza o arquivo `3Tap.zip` contendo o bundle pronto para uso.
- **Publicacao de Release**: Ao criar e enviar uma tag de versao (ex: `git tag v1.0.0 && git push origin v1.0.0`), a Action compila a aplicacao e publica uma nova Release no repositorio com os binarios anexados.

---

## Licenca

Este projeto e disponibilizado sob a licenca [MIT](LICENSE).
