#!/usr/bin/env bash
# Cria/atualiza páginas (index + pages/*), CSS e JS, adiciona ao git, comita e faz push para origin/gh-pages.
# Uso:
# 1) Salve como update-site-pages.sh na raiz do repositório
# 2) chmod +x update-site-pages.sh
# 3) ./update-site-pages.sh
set -euo pipefail

# Verifica que estamos num repo git
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Erro: execute este script a partir da raiz do repositório git."
  exit 1
fi

# Verifica configuração de usuário do git (evita erro no commit)
GIT_NAME="$(git config user.name 2>/dev/null || true)"
GIT_EMAIL="$(git config user.email 2>/dev/null || true)"
if [ -z "$GIT_NAME" ] || [ -z "$GIT_EMAIL" ]; then
  echo "Erro: seu git não tem user.name ou user.email configurado."
  echo "Configure com:"
  echo "  git config --global user.name \"Seu Nome\""
  echo "  git config --global user.email \"seu@email.com\""
  exit 1
fi

REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

echo "Repositório: $REPO_ROOT"

# Garantir branch gh-pages (usar remoto se existir)
if git show-ref --verify --quiet refs/heads/gh-pages; then
  echo "Checkout gh-pages (local existente)"
  git checkout gh-pages
else
  if git ls-remote --exit-code --heads origin gh-pages >/dev/null 2>&1; then
    echo "Branch gh-pages existe no remoto — criando branch local tracking"
    git fetch origin gh-pages
    git checkout -b gh-pages origin/gh-pages
  else
    echo "Criando nova branch local gh-pages"
    git checkout -b gh-pages
  fi
fi

# Atualizar com remoto se houver upstream
if git rev-parse --abbrev-ref @{u} >/dev/null 2>&1; then
  echo "Fazendo git pull --rebase origin gh-pages (se aplicável)"
  git pull --rebase origin gh-pages || true
fi

# Criar diretórios
mkdir -p css pages js images

echo "Criando/atualizando arquivos..."

cat > index.html <<'HTML'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <meta name="description" content="Cartilha digital sobre saúde e bem-estar: prevenção, tratamentos, atividade física, vacinas e relatos de recuperação." />
  <title>Saúde e Bem‑Estar – Cartilha Completa</title>

  <meta property="og:title" content="Saúde e Bem‑Estar – Cartilha Completa" />
  <meta property="og:description" content="Guia prático com orientações sobre prevenção, tratamentos, atividade física, vacinas e casos de melhora." />
  <meta property="og:type" content="website" />
  <meta property="og:url" content="https://igormtrabalho-code.github.io/super-duper-robot" />
  <meta property="og:image" content="https://igormtrabalho-code.github.io/super-duper-robot/images/og-image.jpg" />

  <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@300;400;600&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="/css/style.css">
</head>
<body>
  <a class="skip-link" href="#main-content">Pular para o conteúdo</a>

  <header class="site-header" role="banner">
    <div class="container header-inner">
      <h1 class="brand"><a href="/">Saúde & Bem‑Estar</a></h1>

      <nav class="main-nav" aria-label="Navegação principal">
        <ul>
          <li><a href="/">Início</a></li>
          <li><a href="/pages/atividade.html">Atividade Física</a></li>
          <li><a href="/pages/casos.html">Casos de Sucesso</a></li>
          <li><a href="#vacinas">Vacinas</a></li>
          <li><a href="/pages/contato.html">Enviar Relato</a></li>
        </ul>
      </nav>
    </div>
  </header>

  <main id="main-content" class="container" tabindex="-1">
    <section class="hero card" aria-labelledby="hero-title">
      <div class="hero-inner">
        <div class="hero-text">
          <h2 id="hero-title">Cartilha Digital sobre Saúde e Bem‑Estar</h2>
          <p class="lead">Prevenção, tratamentos, exercício físico e relatos reais de melhora — informações práticas para apoiar decisões de saúde.</p>
          <p><a class="btn" href="/pages/atividade.html">Guia de Atividade Física</a> <a class="btn ghost" href="/pages/casos.html">Ver Casos Reais</a></p>
        </div>

        <figure class="hero-figure" aria-hidden="true">
          <img src="/images/hero-800.jpg" alt="Pessoas caminhando ao ar livre, símbolo de saúde" loading="lazy" width="800" height="400">
          <figcaption class="sr-only">Caminhada ao ar livre como prática de saúde</figcaption>
        </figure>
      </div>
    </section>

    <section id="introducao" class="card">
      <h2>O que você encontra aqui</h2>
      <p>Conteúdos práticos e organizados para ajudar na prevenção e no tratamento de condições comuns, além de orientar sobre atividade física segura e apresentar relatos reais (anônimos) de quem melhorou sua saúde.</p>
      <ul>
        <li>Doenças mais frequentes: sintomas, prevenção e tratamento básico.</li>
        <li>Planos de treino e segurança para Academia e CrossFit.</li>
        <li>Protocolos de reabilitação leve (ex.: pós‑COVID, recondicionamento cardiorrespiratório).</li>
        <li>Casos de sucesso com resultados e aprendizados.</li>
        <li>Formulário para você enviar seu próprio relato.</li>
      </ul>
    </section>

    <section id="doencas" class="card">
      <h2>Doenças, Tratamentos e Recomendações Rápidas</h2>

      <article>
        <h3>Doenças Respiratórias</h3>
        <p>Sintomas iniciais comuns: tosse, congestão, febre e cansaço. Em casos graves: falta de ar, dor torácica ou confusão — procure emergência.</p>
        <h4>Prevenção</h4>
        <p>Vacinação, higiene das mãos, ventilação de ambientes e evitar contato próximo quando sintomático.</p>
        <h4>Tratamento em casa (leve a moderado)</h4>
        <ul>
          <li>Repouso e hidratação; antipiréticos se febre desconfortável.</li>
          <li>Controle de sintomas respiratórios com vaporização e fisioterapia respiratória quando indicada.</li>
          <li>Procure atenção se há piora: saturação baixa, falta de ar ou dor persistente.</li>
        </ul>
      </article>

      <article>
        <h3>Doenças Crônicas: Diabetes e Hipertensão</h3>
        <p>Ambas exigem monitorização e adesão ao tratamento. O pilar do controle inclui medicação, dieta e exercício.</p>
        <h4>Estratégias práticas</h4>
        <ul>
          <li>Monitore glicemia e pressão conforme orientação; mantenha um diário para discutir com seu médico.</li>
          <li>Planeje refeições com baixo índice glicêmico e redução de sódio.</li>
          <li>Inclua atividade física regular (30–60 min/dia moderada) e programas de fortalecimento 2x/semana.</li>
        </ul>
      </article>

      <article>
        <h3>Saúde Mental</h3>
        <p>Avalie sono, humor e funcionamento diário. Procure ajuda profissional quando sintomas persistirem. Estratégias complementares incluem atividade física regular, técnicas de relaxamento e apoio social.</p>
      </article>
    </section>

    <section id="atividade-intro" class="card">
      <h2>Atividade Física (resumo)</h2>
      <p>Para ver o guia completo com planos, exemplos práticos e protocolos de progressão clique em "Atividade Física" no menu.</p>
      <p><a class="btn" href="/pages/atividade.html">Ir para Guia Completo de Atividade Física</a></p>
    </section>

    <section id="casos-resumo" class="card">
      <h2>Casos de Sucesso (resumo)</h2>
      <p>Histórias reais mostram que intervenções simples e consistentes trazem resultado. Leia relatos completos na página de casos.</p>
      <p><a class="btn" href="/pages/casos.html">Ver Casos Completos</a></p>
    </section>

    <section id="vacinas" class="card">
      <h2>Vacinas: por que e quando</h2>
      <p>Vacinas reduzem risco de doenças graves. Siga o calendário do seu país e discuta doses e reforços com seu médico. Vacinas importantes: Influenza, COVID‑19 (segundo diretriz vigente), Hepatites, Tétano e HPV.</p>
    </section>

    <section id="recursos" class="card">
      <h2>Recursos e Referências</h2>
      <ul>
        <li>Ministério da Saúde</li>
        <li>Organização Mundial da Saúde (OMS)</li>
        <li>Sociedades médicas e associações de educação física</li>
      </ul>
    </section>

    <section id="contato" class="card">
      <h2>Envie seu relato</h2>
      <p>Quer compartilhar uma história de melhora? <a href="/pages/contato.html">Envie aqui</a> — podemos publicar relatos anônimos com sua autorização.</p>
    </section>
  </main>

  <footer class="site-footer">
    <div class="container">
      <p>Cartilha digital – Projeto de Extensão ADS | 2025</p>
      <p><small>Imagens de exemplo: Unsplash. Conteúdo informativo — procure profissionais para orientações individuais.</small></p>
    </div>
  </footer>
</body>
</html>
HTML

cat > pages/atividade.html <<'HTML'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Atividade Física — Guia Completo</title>
  <link rel="stylesheet" href="/css/style.css">
  <meta name="description" content="Guia detalhado sobre academia, crossfit, treinos funcionais, prevenção de lesões e protocolos de progressão." />
</head>
<body>
  <header class="site-header">
    <div class="container header-inner">
      <h1 class="brand"><a href="/">Saúde & Bem‑Estar</a></h1>
      <nav class="main-nav" aria-label="Navegação">
        <ul>
          <li><a href="/">Início</a></li>
          <li><a href="/pages/casos.html">Casos</a></li>
          <li><a href="/pages/contato.html">Enviar Relato</a></li>
        </ul>
      </nav>
    </div>
  </header>

  <main class="container">
    <section class="card">
      <h2>Atividade Física — Academia, CrossFit e Modalidades</h2>
      <p>Este capítulo traz orientações detalhadas para praticantes e iniciantes, segurança, exemplos de treinos e protocolos de progressão para recuperação e condicionamento.</p>

      <h3>Avaliação inicial</h3>
      <p>Antes de iniciar um programa de exercícios intensos, é recomendada uma avaliação médica e uma avaliação física com profissional de educação física. Questões importantes:</p>
      <ul>
        <li>Histórico de doenças e lesões</li>
        <li>Medicações em uso</li>
        <li>Nível de atividade atual e objetivos</li>
      </ul>

      <h3>Diretrizes gerais de segurança</h3>
      <ul>
        <li>Comece devagar e progrida gradualmente: 10% de aumento de volume/tempo por semana é uma referência segura.</li>
        <li>Priorize técnica: a execução correta reduz risco de lesões.</li>
        <li>Aqueça 8–12 minutos com mobilidade e ativação; faça desaquecimento e alongamento leve ao final.</li>
        <li>Inclua dias de recuperação ativa (caminhada, mobilidade) e sono adequado.</li>
      </ul>

      <h3>Modelos de treino</h3>
      <h4>Exemplo para iniciantes (8 semanas)</h4>
      <ol>
        <li>Semana 1–2: 3x/semana – treino total do corpo com 8–10 exercícios, 2 séries de 10–12 repetições, intensidade leve-moderada.</li>
        <li>Semana 3–4: 3–4x/semana – aumentar para 3 séries; incluir 2 sessões curtas de cardio (20 min).</li>
        <li>Semana 5–8: dividir treinos por grupos musculares, incorporar trabalho de potência e resistência.</li>
      </ol>

      <h4>CrossFit / Treino Funcional</h4>
      <p>CrossFit combina movimentos funcionais com intensidade. Para aproveitar benefícios e reduzir riscos:</p>
      <ul>
        <li>Domine movimentos básicos (agachamento, levantamento terra, puxada) antes de aumentar intensidade.</li>
        <li>Use variações com menor carga e concentre‑se na técnica.</li>
        <li>Periodize o treino: fases de base (força técnica), fases de intensidade controlada e fases de recuperação.</li>
      </ul>

      <h3>Protocolos de reabilitação leve (ex.: pós‑COVID ou descondicionamento)</h3>
      <p>Objetivo: recuperar capacidade funcional de forma gradual.</p>
      <ol>
        <li>Avaliação inicial (sintomas, saturação, limitação respiratória).</li>
        <li>Fase 1 (2–4 semanas): atividades leves (caminhadas curtas, mobilidade, respiração diafragmática).</li>
        <li>Fase 2 (4–8 semanas): aumentar duração e incluir exercícios de resistência leve e treino de força leve.</li>
        <li>Fase 3: treino estruturado com monitorização e progressão por profissional.</li>
      </ol>

      <figure class="media-placeholder">
        <img src="/images/gallery-3.jpg" alt="Pessoa se alongando" loading="lazy">
        <figcaption>Alongamento e mobilidade ajudam na prevenção de lesões.</figcaption>
      </figure>

      <h3>Adaptações para condições específicas</h3>
      <p>Para hipertensos: prefira exercícios aeróbicos moderados e monitore PA. Em diabetes: evitar hipoglicemia com planejamento de horário/alimentação.</p>

      <h3>Ferramentas e recursos</h3>
      <ul>
        <li>Procure um profissional (educador físico) para prescrição individualizada.</li>
        <li>Use aplicativos de treino e mantenha um diário com cargas, sensações e sono.</li>
      </ul>
    </section>
  </main>

  <footer class="site-footer">
    <div class="container">
      <p><a href="/">Voltar ao início</a></p>
    </div>
  </footer>
</body>
</html>
HTML

cat > pages/casos.html <<'HTML'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Casos de Sucesso — Relatos</title>
  <link rel="stylesheet" href="/css/style.css">
  <meta name="description" content="Relatos anônimos de pessoas que melhoraram a saúde com intervenções simples: dieta, atividade física e acompanhamento médico." />
</head>
<body>
  <header class="site-header">
    <div class="container header-inner">
      <h1 class="brand"><a href="/">Saúde & Bem‑Estar</a></h1>
      <nav class="main-nav" aria-label="Navegação">
        <ul>
          <li><a href="/">Início</a></li>
          <li><a href="/pages/atividade.html">Atividade Física</a></li>
          <li><a href="/pages/contato.html">Enviar Relato</a></li>
        </ul>
      </nav>
    </div>
  </header>

  <main class="container">
    <section class="card">
      <h2>Casos de Sucesso (detalhados)</h2>
      <p>Os relatos abaixo são redigidos de forma anônima e resumem intervenções, métricas e aprendizados práticos.</p>

      <article class="case">
        <h3>Paciente A — Controle de Diabetes Tipo 2</h3>
        <p><strong>Contexto:</strong> diagnóstico com HbA1c ~9%, sedentário e alimentação com excesso de carboidratos processados.</p>
        <p><strong>Intervenção:</strong> plano nutricional com redução de carboidratos simples, caminhada diária 30–40 min, musculação 2x/semana e início de medicação conforme orientação médica.</p>
        <p><strong>Resultado:</strong> após 6 meses HbA1c 6,8%; perda de 7 kg; maior energia. <em>Chaves:</em> acompanhamento multiprofissional e adesão ao plano.</p>
      </article>

      <article class="case">
        <h3>Paciente B — Recuperação Pós‑COVID</h3>
        <p><strong>Contexto:</strong> fadiga persistente e baixa capacidade aeróbica ~ 4 semanas pós infecção.</p>
        <p><strong>Intervenção:</strong> reabilitação respiratória (fisioterapia leve), caminhada progressiva e treino de força leve 3x/semana.</p>
        <p><strong>Resultado:</strong> ganho gradual de tolerância ao exercício e retorno a rotina em ~3 meses. <em>Dica:</em> respeitar limites e progredir devagar.</p>
      </article>

      <article class="case">
        <h3>Paciente C — Redução de Pressão Arterial</h3>
        <p><strong>Contexto:</strong> hipertensão estágio 1 com sobrepeso.</p>
        <p><strong>Intervenção:</strong> dieta com redução de sódio e peso, rotina de 150 minutos/semana de atividade moderada e treino de força.</p>
        <p><strong>Resultado:</strong> queda média da pressão em 8 mmHg e perda de 5 kg em 4 meses.</p>
      </article>

      <section>
        <h3>Quer compartilhar seu caso?</h3>
        <p>Envie seu relato de forma anônima em <a href="/pages/contato.html">Enviar Relato</a>. Ao enviar, você permite que publiquemos um resumo sem dados pessoais.</p>
      </section>
    </section>
  </main>

  <footer class="site-footer">
    <div class="container">
      <p><a href="/">Voltar ao início</a></p>
    </div>
  </footer>
</body>
</html>
HTML

cat > pages/contato.html <<'HTML'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Enviar Relato</title>
  <link rel="stylesheet" href="/css/style.css">
  <meta name="description" content="Envie seu relato de melhora na saúde. Formulário com envio por Formspree (substituir endpoint) e fallback por e‑mail." />
</head>
<body>
  <header class="site-header">
    <div class="container header-inner">
      <h1 class="brand"><a href="/">Saúde & Bem‑Estar</a></h1>
      <nav class="main-nav" aria-label="Navegação">
        <ul>
          <li><a href="/">Início</a></li>
          <li><a href="/pages/atividade.html">Atividade Física</a></li>
          <li><a href="/pages/casos.html">Casos</a></li>
        </ul>
      </nav>
    </div>
  </header>

  <main class="container">
    <section class="card">
      <h2>Enviar Relato (anônimo)</h2>
      <p>Compartilhe sua experiência — os relatos podem ser editados para preservar anonimato. Você pode incluir detalhes sobre diagnóstico, intervenções e resultados.</p>

      <form id="relatoForm" class="form" method="POST" action="https://formspree.io/f/YOUR_FORMSPREE_ID">
        <label for="nome">Nome (opcional)</label>
        <input id="nome" name="nome" type="text" placeholder="Ex.: João (opcional)">

        <label for="email">E‑mail (opcional — para contato)</label>
        <input id="email" name="email" type="email" placeholder="seu@email.com">

        <label for="relato">Relato (conte em detalhes)</label>
        <textarea id="relato" name="relato" rows="8" required placeholder="Descreva a intervenção, tempo, resultados..."></textarea>

        <label for="consent">
          <input id="consent" name="consent" type="checkbox" required>
          Autorizo a publicação de um resumo anônimo do meu relato.
        </label>

        <p class="muted">OBS: Se não configurar um endpoint Formspree, o formulário tentará abrir seu e‑mail (fallback).</p>

        <div class="form-actions">
          <button type="submit" class="btn">Enviar relato</button>
          <button type="button" id="mailtoFallback" class="btn ghost">Enviar por e‑mail</button>
        </div>

        <div id="formStatus" role="status" aria-live="polite" class="sr-only"></div>
      </form>

    </section>
  </main>

  <footer class="site-footer">
    <div class="container">
      <p><a href="/">Voltar ao início</a></p>
    </div>
  </footer>

  <script src="/js/contact.js"></script>
</body>
</html>
HTML

cat > css/style.css <<'CSS'
:root{
  --bg-page: #FFFBEA;
  --card-bg: #ffffff;
  --primary: #37BC9B;
  --accent: #E57373;
  --link: #42A5F5;
  --text: #222;
  --muted: #666;
  --container-max: 1100px;
  --case-bg: #f7fff9;
}

*{box-sizing:border-box}
html,body{height:100%}
body {
  background: var(--bg-page);
  color: var(--text);
  font-family: 'Open Sans', Arial, sans-serif;
  margin: 0;
  -webkit-font-smoothing:antialiased;
  -moz-osx-font-smoothing:grayscale;
}

/* Layout container */
.container {
  max-width: var(--container-max);
  margin: 0 auto;
  padding: 0 16px;
}

/* Header */
.site-header {
  background: linear-gradient(90deg, rgba(55,188,155,0.06), rgba(66,165,245,0.04));
  border-bottom: 1px solid rgba(0,0,0,0.04);
}
.header-inner {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 18px 0;
}
.brand { margin: 0; color: var(--primary); font-size: 1.25rem; }
.brand a { color: inherit; text-decoration: none; }
.main-nav ul { list-style: none; margin: 0; padding: 0; display:flex; gap:12px; }
.main-nav a { color: var(--text); text-decoration: none; font-weight:600; }
.main-nav a:hover { color: var(--primary); }

/* Buttons */
.btn {
  display: inline-block;
  background: var(--primary);
  color: #fff;
  padding: 8px 14px;
  border-radius: 6px;
  text-decoration: none;
  font-weight:600;
}
.btn.ghost, .btn.ghost:link { background: transparent; color: var(--primary); border: 1px solid rgba(55,188,155,0.15); }

/* Card / section styling */
.card {
  background: var(--card-bg);
  margin: 18px auto;
  padding: 18px;
  border-radius:8px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.05);
}

/* Hero */
.hero { padding: 28px 0; }
.hero-inner { display:flex; gap:18px; align-items:center; flex-wrap:wrap; }
.hero-text { flex:1 1 320px; }
.hero h2 { margin: 0 0 8px 0; color: var(--primary); font-size:1.6rem; }
.lead { margin: 0 0 12px 0; color:var(--muted); }

/* Activity grid */
.activity-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; }
.activity-grid article { background: #fff; padding: 12px; border-radius: 8px; box-shadow: 0 1px 6px rgba(0,0,0,0.03); }

/* Cases layout */
.cases { display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; }
.case { background: var(--case-bg); padding: 14px; border-radius: 8px; border: 1px solid rgba(0,0,0,0.04); }

/* Media placeholder */
.media-placeholder { margin-top: 12px; }
.media-placeholder img { width:100%; height:auto; border-radius:8px; display:block; }

/* Form */
.form label { display:block; margin-top:12px; font-weight:600; }
.form input, .form textarea { width:100%; padding:10px; margin-top:6px; border:1px solid #ddd; border-radius:6px; font-size:1rem; }
.form .form-actions { margin-top:12px; display:flex; gap:8px; align-items:center; }
.muted { color: var(--muted); font-size:0.95rem; }

/* Footer */
.site-footer { padding: 18px 0; text-align:center; color:var(--muted); }

/* Accessibility helpers */
.sr-only { position:absolute !important; height:1px; width:1px; overflow:hidden; clip:rect(1px,1px,1px,1px); white-space:nowrap; }

/* Responsive */
@media (max-width:900px) {
  .activity-grid { grid-template-columns: repeat(2, 1fr); }
  .cases { grid-template-columns: repeat(2, 1fr); }
  .hero-inner { flex-direction: column-reverse; }
}
@media (max-width:600px) {
  .main-nav ul { display:none; }
  .activity-grid, .cases { grid-template-columns: 1fr; }
  .hero h2 { font-size:1.25rem; }
}
CSS

cat > js/contact.js <<'JS'
document.addEventListener('DOMContentLoaded', function () {
  const form = document.getElementById('relatoForm');
  const status = document.getElementById('formStatus');
  const mailtoBtn = document.getElementById('mailtoFallback');

  // Form action default is a Formspree endpoint placeholder.
  // Replace 'YOUR_FORMSPREE_ID' in the form action with your Formspree ID.
  const formAction = form.getAttribute('action');

  form.addEventListener('submit', async function (ev) {
    ev.preventDefault();
    status.classList.remove('sr-only');
    status.textContent = 'Enviando...';

    const data = new FormData(form);

    try {
      const resp = await fetch(formAction, {
        method: 'POST',
        body: data,
        headers: { 'Accept': 'application/json' },
      });

      if (resp.ok) {
        status.textContent = 'Obrigado — seu relato foi enviado.';
        form.reset();
      } else {
        // fallback: abrir mailto
        status.textContent = 'Não foi possível enviar automaticamente. Abrindo seu cliente de e‑mail...';
        setTimeout(() => {
          openMailtoFallback();
        }, 800);
      }
    } catch (err) {
      status.textContent = 'Erro ao enviar. Abrindo seu cliente de e‑mail...';
      setTimeout(() => {
        openMailtoFallback();
      }, 800);
    }
  });

  function openMailtoFallback() {
    const nome = encodeURIComponent(document.getElementById('nome').value || 'Anonimo');
    const email = encodeURIComponent(document.getElementById('email').value || '');
    const relato = encodeURIComponent(document.getElementById('relato').value || '');
    const subject = encodeURIComponent('Relato: ' + nome);
    const body = encodeURIComponent(`Nome: ${nome}\nE-mail: ${email}\n\nRelato:\n${relato}`);
    // Substitua o e‑mail abaixo pelo destinatário desejado
    const to = 'igor.m.trabalho@gmail.com';
    window.location.href = `mailto:${to}?subject=${subject}&body=${body}`;
  }

  mailtoBtn.addEventListener('click', openMailtoFallback);
});
JS

echo "Arquivos criados/atualizados localmente."

# Adicionar ao git
git add index.html css/style.css js/contact.js pages/ || true

# Incluir images/ se houver conteúdo
if [ -d images ] && [ "$(ls -A images || true)" != "" ]; then
  git add images || true
fi

# Commit se houver mudanças staged
if git diff --staged --quiet; then
  echo "Nenhuma mudança nova staged para commit."
else
  git commit -m "Add pages: atividade, casos, contato + expanded content and form"
  echo "Commit criado."
fi

# Push para origin/gh-pages (set upstream se necessário)
if git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
  echo "Executando git push origin gh-pages..."
  git push origin gh-pages
else
  echo "Executando git push --set-upstream origin gh-pages..."
  git push -u origin gh-pages
fi

echo "Concluído. Confira: /, /pages/atividade.html, /pages/casos.html, /pages/contato.html"
echo "Lembre-se de substituir 'YOUR_FORMSPREE_ID' no pages/contato.html pelo seu ID do Formspree (se for usar)."
