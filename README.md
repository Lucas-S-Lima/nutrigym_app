# NutriGym (meu_app)

Aplicativo de nutrição desenvolvido com **Dart + Flutter** para cadastrar usuários, alimentos e montar cardápios diários (café, almoço e janta), com persistência local em SQLite.

Funciona em **Android, iOS, Web, Linux, Windows e macOS** — o acesso ao banco se adapta automaticamente à plataforma.

## Funcionalidades

- Login/cadastro de conta
- Cadastro e consulta de **usuários**, **alimentos** e **cardápios**
- Seleção de foto (avatar de usuário e foto de alimento) via câmera/galeria
- Compartilhamento de cardápio
- Persistência local com SQLite (`nutrigym.db`)

## Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) — testado com **Flutter 3.41.9 (stable)**
- Dart SDK **^3.11.5** (já incluso no Flutter)
- Para rodar em mobile: Android Studio / Xcode com um emulador ou dispositivo
- Para rodar em desktop Linux: dependências do `sqlite3` (`sudo apt install libsqlite3-dev`)

Verifique se o ambiente está pronto:

```bash
flutter doctor
```

## Como rodar

1. Instale as dependências:

   ```bash
   flutter pub get
   ```

2. Liste os dispositivos disponíveis:

   ```bash
   flutter devices
   ```

3. Execute o app (em um dispositivo/emulador conectado):

   ```bash
   flutter run
   ```

   Para escolher uma plataforma específica:

   ```bash
   flutter run -d chrome     # Web
   flutter run -d linux      # Desktop Linux
   flutter run -d windows    # Desktop Windows
   flutter run -d macos      # Desktop macOS
   ```

## Testes

```bash
flutter test
```

Os testes usam um banco SQLite **em memória** (via `sqflite_common_ffi`), então não dependem do dispositivo.

## Build de produção

```bash
flutter build apk        # Android
flutter build ios        # iOS
flutter build web        # Web
flutter build linux      # Linux
flutter build windows    # Windows
flutter build macos      # macOS
```

## Estrutura do projeto

```
lib/
├── main.dart                 # Ponto de entrada e tema do app
├── models/                   # Modelos: usuario, alimento, cardapio
├── screens/                  # Telas (login, home, cadastro, consulta, etc.)
├── services/                 # app_store, database_helper, formatador
└── widgets/                  # Componentes reutilizáveis (seletor de foto, avatar)
assets/
└── images/logo.png           # Logo do app
test/                         # Testes de widget e screenshots
```

## Principais dependências

- `sqflite` / `sqflite_common_ffi` / `sqflite_common_ffi_web` — banco SQLite multiplataforma
- `shared_preferences` — persistência de sessão/login
- `image_picker` — seleção de fotos
- `share_plus` — compartilhamento
- `uuid` — geração de identificadores
- `path` — manipulação de caminhos do banco
