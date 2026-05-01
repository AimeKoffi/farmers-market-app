# Farmers Market Platform — Application Mobile (Flutter Web)

Plateforme de gestion des ventes agricoles en Côte d'Ivoire.  
**Flutter 3 · Riverpod · Go Router · Hive (offline)**

---

## Liens de soumission

| Élément | Lien |
|---------|------|
| Application (GitHub Pages) | _à renseigner après déploiement_ |
| API (Render) | _à renseigner après déploiement_ |

---

## Workflow complet : Tests → Déploiement

```
┌──────────────────────────────────────────────────────────────────────┐
│  ÉTAPE 1 — Pousser les deux dépôts sur GitHub                        │
│  ÉTAPE 2 — Lancer les tests (API + Flutter)                          │
│  ÉTAPE 3 — Déployer le backend sur Render                            │
│  ÉTAPE 4 — Déployer le frontend sur GitHub Pages                     │
│  ÉTAPE 5 — Vérifier les URLs et soumettre                            │
└──────────────────────────────────────────────────────────────────────┘
```

---

## ÉTAPE 1 — Pousser sur GitHub

### Structure des dépôts

Créer **deux dépôts GitHub publics** :

| Dépôt | Contenu |
|-------|---------|
| `farmers-market-api` | Ce dossier Laravel |
| `farmers-market-app` | Ce dossier Flutter |

### Commandes

```bash
# Backend
cd farmers-market-api
git init
git add .
git commit -m "feat: initial Laravel API — farmers market platform"
git remote add origin https://github.com/<ton-username>/farmers-market-api.git
git push -u origin main

# Frontend
cd farmers_market_app
git init
git add .
git commit -m "feat: initial Flutter app — farmers market POS"
git remote add origin https://github.com/<ton-username>/farmers-market-app.git
git push -u origin main
```

---

## ÉTAPE 2 — Lancer les tests

> À faire avant de déployer pour valider que tout fonctionne.

### Tests API Laravel

```bash
cd farmers-market-api
composer install
php artisan test
```

Résultat attendu :
```
Tests:    26 passed
Duration: ~3s
```

### Tests Flutter

```bash
cd farmers_market_app
flutter pub get
flutter test
```

Résultat attendu :
```
00:XX +16: All tests passed!
```

### Alternative : tests entièrement dans Docker (sans PHP ni Flutter installés)

```bash
cd farmers_market_app

# Tests API
docker compose -f docker-compose.test.yml run --rm api-test

# Tests Flutter
docker compose -f docker-compose.test.yml run --rm flutter-test
```

---

## ÉTAPE 3 — Déployer le backend sur Render

**Prérequis :** dépôt `farmers-market-api` poussé sur GitHub.

### 3.1 Créer le service Render

1. Aller sur [render.com](https://render.com) → Se connecter
2. Cliquer **New +** → **Blueprint**
3. Connecter GitHub → sélectionner `farmers-market-api`
4. Render lit `render.yaml` et prépare :
   - **Web Service** (Docker PHP Laravel)
   - **PostgreSQL** gratuit
5. Cliquer **Apply** → **Confirm**

### 3.2 Attendre le build initial (5–10 min)

Surveiller les logs Render → quand on voit :
```
✅ Setup complet — données de démo seedées
🚀 Serveur démarré sur le port 10000
```

### 3.3 Récupérer l'URL de l'API

Dans Render → farmers-market-api → **Settings** :
```
https://farmers-market-api-xxxx.onrender.com
```

### 3.4 Vérifier

```bash
curl https://farmers-market-api-xxxx.onrender.com/api/health
# {"status":"ok"}
```

---

## ÉTAPE 4 — Déployer le frontend sur GitHub Pages

**Prérequis :** dépôt `farmers-market-app` poussé sur GitHub + URL Render obtenue.

### 4.1 Activer GitHub Pages

1. Sur GitHub → dépôt `farmers-market-app`
2. **Settings** → **Pages** (menu gauche)
3. Source : sélectionner **GitHub Actions**
4. Sauvegarder

### 4.2 Configurer l'URL de l'API

1. Sur GitHub → dépôt `farmers-market-app`
2. **Settings** → **Secrets and variables** → **Actions** → onglet **Variables**
3. Cliquer **New repository variable**
4. Renseigner :
   - **Name :** `API_URL`
   - **Value :** `https://farmers-market-api-xxxx.onrender.com/api`
     _(remplacer `xxxx` par ton vrai identifiant Render)_
5. Cliquer **Add variable**

### 4.3 Déclencher le déploiement

```bash
# Option A : pousser un commit (le workflow se déclenche automatiquement)
git commit --allow-empty -m "chore: trigger GitHub Pages deployment"
git push

# Option B : déclencher manuellement
# GitHub → dépôt → Actions → "Deploy Flutter Web → GitHub Pages" → Run workflow
```

### 4.4 Récupérer l'URL GitHub Pages

Après le build (~3–5 min) :  
**Settings** → **Pages** → URL affichée :
```
https://<ton-username>.github.io/farmers-market-app/
```

### 4.5 Vérifier

Ouvrir l'URL dans le navigateur → l'écran de login Flutter doit apparaître.

Se connecter avec :
```
Email    : operator@farmersmarket.ci
Password : password
```

---

## ÉTAPE 5 — Soumettre

Soumettre sur le portail : [xpertbotacademy.online/project-submission](https://xpertbotacademy.online/project-submission)

**Deux soumissions séparées :**

| Soumission | Liens à fournir |
|-----------|-----------------|
| **Backend** | URL GitHub `farmers-market-api` · URL Render |
| **Frontend** | URL GitHub `farmers-market-app` · URL GitHub Pages |

---

## Développement local avec Docker

```bash
# Cloner les deux dépôts côte à côte
git clone <url-backend>  farmers-market-api
git clone <url-frontend> farmers_market_app

cd farmers_market_app
docker compose up --build
```

| Service | URL |
|---------|-----|
| Application Flutter | http://localhost |
| API Laravel | http://localhost:8080 |

> Première construction : 10–15 min. Suivantes : quasi-instantanées.

```bash
docker compose down       # arrêter
docker compose down -v    # arrêter + supprimer les données
```

---

## Développement local sans Docker

```bash
# Backend
cd farmers-market-api
composer install && cp .env.example .env
php artisan key:generate && php artisan migrate:fresh --seed
php artisan serve   # http://localhost:8000

# Frontend (dans un autre terminal)
cd farmers_market_app
flutter pub get
flutter run -d chrome
```

---

## Architecture du projet Flutter

```
lib/
├── core/
│   ├── constants/      # URLs API, clés de stockage
│   ├── network/        # Client HTTP Dio + intercepteur token
│   ├── router/         # Navigation Go Router (guards auth)
│   └── theme/          # Thème Material 3 (vert forêt #2D6A4F)
├── data/
│   └── services/       # Couche API : auth, farmer, product, transaction, repayment
└── presentation/
    ├── providers/      # État Riverpod : auth, farmer search, panier
    ├── screens/        # Login, Farmer Search, Products, Checkout, Repayment
    └── widgets/        # AppButton, OfflineBanner, StatusBadge

web/
├── index.html          # Point d'entrée Flutter Web
└── 404.html            # Redirect SPA pour GitHub Pages

.github/workflows/
└── deploy-pages.yml    # CI/CD : flutter test → flutter build web → GitHub Pages

docker-compose.yml      # Stack complète locale (db + api + app)
docker-compose.test.yml # Tests isolés en containers
```

## Fonctionnalités

| Feature | Statut |
|---------|--------|
| Authentification Sanctum (token) | ✅ |
| Recherche agriculteur (id / tél.) | ✅ |
| Création de profil agriculteur | ✅ |
| Catalogue produits + filtres catégories | ✅ |
| Panier + caisse (cash / crédit + intérêts) | ✅ |
| Contrôle limite de crédit | ✅ |
| Résumé des dettes (FIFO) | ✅ |
| Remboursement en commodités (kg → FCFA) | ✅ |
| Support hors-ligne (Hive + file de sync) | ✅ |
| Bannière connectivité temps-réel | ✅ |
