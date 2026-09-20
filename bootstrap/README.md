# gh-governance-bootstrap

GuKi Chat kampanyasında kurulan repo **ayarlarını** (dosya değil) başka bir GitHub
reposuna uygulayan script. Dosya tarafı (issue şablonları, CODEOWNERS,
dependabot.yml, workflow'lar) bunun kapsamında değil — o kısım için bir template
repo kullan.

## Kullanım

```bash
./setup.sh --repo OWNER/NAME                     # her özelliği tek tek sorar
./setup.sh --repo OWNER/NAME --dry-run           # hiçbir şeyi uygulamadan önizler
./setup.sh --repo OWNER/NAME --yes               # sormadan hepsini uygular
./setup.sh --repo OWNER/NAME \
  --with-codeql --without-labels \
  --required-check "Quality" --required-check "Conventional Commits"
```

`--with-X` / `--without-X` verilmeyen her özellik, `--yes` yoksa interaktif
olarak sorulur. `ruleset` özelliği en az bir `--required-check` ister — repo'nun
gerçek GitHub Actions job adı (ör. `Quality`), tahmini isim değil.

## Özellikler

- `merge_settings` — squash-only merge, boş kare mesaj, merge sonrası branch silme
- `security_alerts` — Dependabot vulnerability alerts + otomatik güvenlik PR'ları
- `codeql` — GitHub code scanning default setup (CodeQL). **Private repo'da
  ücretsiz değil** (GitHub Advanced Security gerektirir).
- `labels` — `security` / `dependencies` etiketleri (yoksa ekler)
- `ruleset` — main branch'i için: PR zorunlu, thread çözümü zorunlu, verilen
  check'ler zorunlu, repo sahibi için bypass

## Kapsam dışı (bilerek)

- Issue şablonları, CODEOWNERS, CODE_OF_CONDUCT, dependabot.yml, workflow'lar —
  bunlar dosya, bir template repo'dan otomatik geliyor.
- `scripts/merge-pr.mjs`, `merge-attribution-audit.yml` — proje-spesifik
  (Node/npm script'i), elle taşınmalı.
- Organizasyon private repo'larında code/secret scanning için GitHub Team +
  Advanced Security eklentisi gerekiyor; bu script sadece API çağrısını yapar,
  planın buna izin verip vermediğini kontrol etmez.
