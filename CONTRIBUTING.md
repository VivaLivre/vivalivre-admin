# 🤝 Guia de Contribuição — VivaLivre Admin

Este documento define o fluxo de trabalho Git obrigatório para todos que desenvolvem no portal administrativo VivaLivre. **Nenhum código vai direto para a `main`.**

---

## 🌿 Estrutura de Branches

```
main          ← Produção. Somente Pull Requests vindos de develop.
│
└── develop   ← Área de testes/integração. Branch padrão de trabalho.
      │
      ├── feature/dashboard-stats
      ├── feature/moderar-locais
      ├── fix/login-erro-401
      └── chore/atualizar-flutter
```

| Branch | Finalidade | Quem pode publicar |
|---|---|---|
| `main` | Versão estável de produção | Somente via PR aprovado de `develop` |
| `develop` | Integração e testes | Somente via PR aprovado de `feature/*` ou `fix/*` |
| `feature/*` | Nova funcionalidade | Desenvolvedor, a partir de `develop` |
| `fix/*` | Correção de bug | Desenvolvedor, a partir de `develop` |
| `chore/*` | Tarefas técnicas (deps, config) | Desenvolvedor, a partir de `develop` |
| `hotfix/*` | Correção urgente em produção | A partir de `main`, merge em `main` E `develop` |

---

## 🚀 Fluxo de Trabalho Diário

### 1. Criar uma branch para a sua tarefa

Sempre a partir de `develop` (nunca de `main`):

```bash
git checkout develop
git pull origin develop          # garante que está atualizado

# Escolha o prefixo correto:
git checkout -b feature/nome-da-feature
git checkout -b fix/nome-do-bug
git checkout -b chore/nome-da-tarefa
```

### 2. Desenvolver e commitar

Use mensagens de commit no padrão **Conventional Commits**:

```bash
git add .
git commit -m "feat: adiciona grid de estatísticas no dashboard"
git commit -m "fix: resolve loop infinito no token interceptor"
git commit -m "chore: atualiza pacotes para flutter 3.24"
```

| Prefixo | Quando usar |
|---|---|
| `feat:` | Nova funcionalidade |
| `fix:` | Correção de bug |
| `chore:` | Atualização de dependências, configurações |
| `docs:` | Mudanças na documentação |
| `style:` | Formatação, sem mudança de lógica |
| `refactor:` | Refatoração de código |
| `test:` | Adição ou correção de testes |
| `ci:` | Configuração de CI/CD |

### 3. Publicar a branch e abrir PR para `develop`

```bash
git push origin feature/nome-da-feature
```

Em seguida, acesse o GitHub e abra um **Pull Request**:
- **De:** `feature/nome-da-feature`
- **Para:** `develop`

### 4. Revisão e merge em `develop`

Após revisão, faça o merge em `develop`.

### 5. Promover `develop` → `main` (Release)

Quando `develop` estiver estável e testado:

```bash
git checkout main
git pull origin main
git merge develop
git push origin main
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin --tags
```

---

## 🚑 Hotfix (Correção Urgente em Produção)

```bash
git checkout main
git pull origin main
git checkout -b hotfix/descricao-do-bug

# ... corrigir o bug ...

git commit -m "fix: corrige crash na listagem de banheiros"

# Merge em MAIN
git checkout main
git merge hotfix/descricao-do-bug
git push origin main
git tag -a v1.0.1 -m "Hotfix v1.0.1"
git push origin --tags

# Merge também em DEVELOP para não perder a correção
git checkout develop
git merge hotfix/descricao-do-bug
git push origin develop

# Deletar branch de hotfix
git branch -d hotfix/descricao-do-bug
git push origin --delete hotfix/descricao-do-bug
```

---

## 📋 Regras Obrigatórias

> [!CAUTION]
> **Proibido** fazer `git push` diretamente para `main`. Sempre use Pull Request.

> [!IMPORTANT]
> Toda branch deve sair de `develop`, não de `main`.

> [!WARNING]
> Antes de criar uma branch, sempre faça `git pull origin develop` para evitar conflitos.

> [!TIP]
> Delete branches locais após o merge: `git branch -d feature/nome-da-feature`

---

## 🏷️ Versionamento (SemVer)

O projeto segue **Semantic Versioning**: `MAJOR.MINOR.PATCH`

---

## 💻 Setup Inicial para Novos Devs

```bash
# 1. Clonar
git clone https://github.com/VivaLivre/vivalivre-admin.git
cd vivalivre-admin

# 2. Instalar dependências Flutter
flutter pub get

# 3. Confirmar que está na branch develop
git checkout develop

# 4. Rodar o app (Web)
flutter run -d chrome
```
