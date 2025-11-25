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
