#!/usr/bin/env bash
set -euo pipefail

# Script para baixar imagens, gerar webp (se possível) e commitar para gh-pages
# Uso: salve como update-images.sh, torne executável (chmod +x update-images.sh) e execute na raiz do repo.

# Verifica se estamos dentro de um repositório git
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Erro: execute este script a partir da raiz do repositório git."
  exit 1
fi

REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

echo "Repositório: $REPO_ROOT"

# Garantir branch gh-pages local (usar remoto se existir)
if git show-ref --verify --quiet refs/heads/gh-pages; then
  echo "Switching to existing local branch gh-pages"
  git checkout gh-pages
else
  if git ls-remote --exit-code --heads origin gh-pages >/dev/null 2>&1; then
    echo "Branch gh-pages existe no remoto — fazendo checkout tracking"
    git fetch origin gh-pages
    git checkout -b gh-pages origin/gh-pages
  else
    echo "Criando nova branch local gh-pages"
    git checkout -b gh-pages
  fi
fi

# Puxa atualizações remotas se houver
if git rev-parse --abbrev-ref @{u} >/dev/null 2>&1; then
  echo "Fazendo git pull --rebase"
  git pull --rebase origin gh-pages || true
fi

# Criar pasta images
mkdir -p images
echo "Pasta images pronta: $(pwd)/images"

# URLs (Unsplash source — imagens aleatórias por palavra-chave)
declare -a urls=(
  "https://source.unsplash.com/1200x600/?health,wellness,walking"
  "https://source.unsplash.com/800x400/?health,wellness,walking"
  "https://source.unsplash.com/1200x630/?health,wellness"
  "https://source.unsplash.com/800x600/?healthy-food"
  "https://source.unsplash.com/800x600/?yoga,meditation"
  "https://source.unsplash.com/800x600/?exercise,stretching"
  "https://source.unsplash.com/800x600/?doctor,clinic,vaccine"
)

declare -a names=(
  "hero-1200.jpg"
  "hero-800.jpg"
  "og-image.jpg"
  "gallery-1.jpg"
  "gallery-2.jpg"
  "gallery-3.jpg"
  "clinic-1.jpg"
)

# Baixar imagens
echo "Iniciando downloads..."
for i in "${!urls[@]}"; do
  out="images/${names[i]}"
  echo "Baixando ${urls[i]} -> ${out}"
  # -fSL : follow redirects, fail on HTTP errors, show error; sobrescreve se já existir
  if curl -fSL "${urls[i]}" -o "$out"; then
    echo "OK: $out"
  else
    echo "Falha ao baixar ${urls[i]} (curl retornou erro), pulando..."
  fi
done

# Converter para webp se cwebp disponível
if command -v cwebp >/dev/null 2>&1; then
  echo "cwebp encontrado — convertendo JPGs para WebP (qualidade 80)"
  for fn in "${names[@]}"; do
    jpg="images/${fn}"
    webp="images/${fn%.*}.webp"
    if [ -f "$jpg" ]; then
      cwebp -q 80 "$jpg" -o "$webp" && echo "Convertido: $jpg -> $webp"
    fi
  done
else
  echo "cwebp não encontrado. Para converter para WebP instale 'webp' (Homebrew): brew install webp"
  echo "Pulando conversão para WebP."
fi

# Adicionar, commitar e push
echo "Adicionando imagens ao git..."
git add images || true

# Commit se houver mudanças
if git diff --staged --quiet; then
  echo "Nenhuma mudança para commitar (já estava atualizado)."
else
  git commit -m "Add health images (Unsplash) and webp versions" || true
fi

echo "Fazendo push para origin/gh-pages..."
git push -u origin gh-pages

echo "Concluído. Verifique images/ no repositório remoto e atualize a página se necessário."
