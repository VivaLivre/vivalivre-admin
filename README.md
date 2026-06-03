# 💙 VivaLivre — Admin Portal

> Portal de administração web para gestão da plataforma VivaLivre.

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=flat-square&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?style=flat-square&logo=dart&logoColor=white)](https://dart.dev)
[![BLoC](https://img.shields.io/badge/BLoC-State_Management-blueviolet?style=flat-square)](https://bloclibrary.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)](LICENSE)

---

## 📖 Sobre o Admin Portal

**VivaLivre Admin** é uma aplicação web desenvolvida em **Flutter**, seguindo rigorosamente os princípios da **Clean Architecture** e gerência de estado via **BLoC**. Serve como painel de controle administrativo para a plataforma VivaLivre, focada no suporte a pacientes com Doenças Inflamatórias Intestinais (DII).

Este portal permite que os administradores gerenciem a plataforma de forma eficiente e centralizada.

---

## 🎯 Responsabilidades Principais

- Moderação e aprovação de novos locais (banheiros acessíveis) sugeridos por utilizadores.
- Gestão de utilizadores da plataforma.
- Configurações do sistema e parâmetros de moderação.
- Monitoramento de dados e denúncias.

---

## 🛠️ Stack Tecnológico

| Camada | Tecnologia | Propósito |
|---|---|---|
| **Linguagem** | Dart 3+ | Linguagem cliente otimizada |
| **Framework** | Flutter Web | UI declarativa e responsiva |
| **Gerência de Estado**| BLoC | Previsibilidade e separação de lógicas |
| **Arquitetura** | Clean Architecture | Escalabilidade e manutenção |
| **Requisições HTTP** | Dio | Comunicação com o backend Go |
| **Injeção de Dependência**| Provider / RepositoryProvider | Distribuição de instâncias |
| **Armazenamento Local**| SharedPreferences | Gestão de tokens de sessão (JWT) |

---

## ⚙️ Configuração Local

### Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) — Versão 3.19 ou superior
- [Google Chrome](https://www.google.com/chrome/) — Para execução do projeto web

### Passo a Passo

**1. Clone o repositório**
```bash
git clone https://github.com/VivaLivre/vivalivre-admin.git
cd vivalivre-admin
```

**2. Instale as dependências**
```bash
flutter pub get
```

**3. Execute o servidor de desenvolvimento**
```bash
flutter run -d chrome
```

O aplicativo estará disponível no navegador.

---

## 🏗️ Arquitetura

O projeto segue rigorosamente o padrão **Clean Architecture**, com separação clara entre as camadas:

```
lib/
├── core/                        # Utilidades centrais, network, interceptors
│   └── network/
│       └── token_interceptor.dart
│
├── features/                    # Módulos funcionais da aplicação
│   ├── auth/                    # Autenticação
│   ├── dashboard/               # Painel principal
│   ├── moderation/              # Moderação de banheiros
│   ├── settings/                # Configurações
│   └── users/                   # Gestão de utilizadores
│
└── main.dart                    # Ponto de entrada (Injeções e Rotas)
```

**Estrutura Interna de uma Feature:**
- `data/` — Modelos, DTOs e Implementações de Repositórios.
- `domain/` — Entidades de Negócio e Interfaces de Repositório.
- `presentation/` — BLoC (State/Events), Pages e Widgets.

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Por favor, siga as regras do projeto:

1. **Faça um fork** do projeto.
2. **Crie uma branch** a partir de `develop`:
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feat/sua-feature
   ```
3. Realize suas implementações seguindo estritamente a Clean Architecture.
4. **Commit semântico**:
   ```bash
   git commit -m "feat(moderation): adicionar filtros de locais"
   ```
5. Faça o push e abra um Pull Request.

---

<div align="center">

Feito com 💙 por **Gabriel José de Souza** para a comunidade DII brasileira.

*"Toda pessoa com DII merece viver com liberdade e dignidade."*

</div>
