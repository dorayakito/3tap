# 3Tap

Utilitario leve e nativo para macOS que roda na barra de menus e converte toques de tres dedos no trackpad no comando Enter/Return.

---

## Recursos

- **Execucao em Segundo Plano**: Opera exclusivamente na barra de menus (LSUIElement), sem ocupar espaco no Dock.
- **Deteccao Precisa de Gestos**: Integra-se diretamente a API nativa privada MultitouchSupport para capturar eventos de contato no trackpad (integrado ou Magic Trackpad).
- **Filtro Inteligente de Toque**: Aplica validacao de duracao maxima e deslocamento espacial minimo para diferenciar toques intencionais de gestos de rolagem, zoom ou arraste.
- **Desempenho e Eficiencia**: Desenvolvido em Swift e Objective-C/C nativo, com baixo consumo de CPU e memoria.
- **Persistencia e Resiliencia**: Suporte a inicializacao automatica no login do macOS atraves de SMAppService, com recuperacao do listener apos repouso/despertar.

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

## Configuracao de Persistencia (macOS 13+)

Use a opcao **Iniciar com o Sistema** no menu do 3Tap. No macOS 13 ou superior, o aplicativo usa `SMAppService`.

Nao mantenha simultaneamente um LaunchAgent manual com o mesmo identificador, pois isso pode iniciar duas copias. Se voce configurou a versao antiga manualmente, remova-a uma vez:

```bash
launchctl bootout gui/$(id -u) "$HOME/Library/LaunchAgents/com.victor.3tap.plist" 2>/dev/null || true
rm -f "$HOME/Library/LaunchAgents/com.victor.3tap.plist"
```

Para versoes antigas do macOS, o aplicativo ainda pode usar um LaunchAgent como fallback. Nao crie esse arquivo manualmente no macOS 13+.

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
