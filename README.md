# 3Tap 🖐️ ↵

> Utility simples e leve para macOS que roda na barra de menus e converte **toques de 3 dedos no trackpad** no comando **Enter/Return**.

---

## Motivação

Este projeto nasceu de uma necessidade prática: a tecla **Enter/Return** física do meu **MacBook Pro M1** parou de funcionar. Em vez de depender de teclados virtuais na tela ou remapeamentos complexos de teclado, criei o **3Tap** para enviar o comando de `Enter` com um simples toque de 3 dedos no trackpad — o que facilitou demais o meu uso no dia a dia!

---

## Recursos

- **Execução em Segundo Plano**: Roda nativamente na barra de menus (sem ícone no Dock).
- **Detecção Precisa de Gestos**: Ouve toques no Trackpad (integrado de MacBooks ou Magic Trackpad) via `MultitouchSupport`.
- **Filtro Inteligente**: Diferencia toques rápidos de gestos de rolagem ou arraste para evitar disparos acidentais.
- **Leve e Rápido**: Escrito em Swift e C nativo com baixo consumo de memória.
- **Inicialização com o Sistema**: Opção no menu para iniciar automaticamente no login do macOS.

---

## Como Compilar e Instalar

### Requisitos
- macOS 13.0 (Ventura) ou superior
- Swift 5.9+ / Xcode Command Line Tools

### Compilando
Clone o repositório e execute o script de build:

```bash
git clone https://github.com/dorayakito/3tap.git
cd 3tap
./build.sh
```

Isso gerará o pacote `3Tap.app` compilado em modo Release.

### Instalando nas Aplicações
Para mover para a pasta de Aplicações e executar:

```bash
cp -R 3Tap.app /Applications/
open /Applications/3Tap.app
```

---

## Permissão de Acessibilidade

Para enviar comandos de teclado (`CGEvent`), o macOS exige permissão de **Acessibilidade**:

1. Clique no ícone `↵` do **3Tap** na barra de menus.
2. Clique em **"⚠️ Permissão de Acessibilidade Necessária!"**.
3. Em **Ajustes do Sistema > Privacidade e Segurança > Acessibilidade**, ative o **3Tap**.

---

## Licença

Este projeto é disponibilizado sob a licença [MIT](LICENSE).
