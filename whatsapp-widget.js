/* ─────────────────────────────────────────────────────────────────
   Fleek Up Home — WhatsApp floating chat button
   Appears after 350 px of scroll, fades in smoothly, pulses once.
   ───────────────────────────────────────────────────────────────── */
(function () {
  const WA_NUMBER  = '27732964275';
  const WA_MESSAGE = 'Hi! I\'d love to know more about your handcrafted products.';
  const SCROLL_THRESHOLD = 350; // px before button appears

  /* ── Inject CSS ─────────────────────────────────────────────── */
  const style = document.createElement('style');
  style.textContent = `
    #wa-btn {
      position: fixed;
      bottom: 32px;
      right: 28px;
      z-index: 9999;
      display: flex;
      align-items: center;
      gap: 10px;
      background: #25D366;
      color: #fff;
      border: none;
      border-radius: 50px;
      padding: 14px 20px 14px 16px;
      font-family: 'Inter', sans-serif;
      font-size: 13px;
      font-weight: 600;
      letter-spacing: .03em;
      cursor: pointer;
      box-shadow: 0 6px 24px rgba(37,211,102,.40);
      text-decoration: none;
      opacity: 0;
      transform: translateY(20px) scale(.92);
      transition: opacity .35s ease, transform .35s ease, box-shadow .2s, background .2s;
      pointer-events: none;
      white-space: nowrap;
      overflow: hidden;
      max-width: 52px; /* collapsed: icon only */
    }
    #wa-btn.wa-visible {
      opacity: 1;
      transform: translateY(0) scale(1);
      pointer-events: auto;
    }
    #wa-btn:hover {
      background: #1ebe5d;
      box-shadow: 0 8px 32px rgba(37,211,102,.55);
      max-width: 260px; /* expand to show label */
    }
    #wa-btn svg {
      flex-shrink: 0;
      width: 24px;
      height: 24px;
    }
    #wa-btn-label {
      overflow: hidden;
      max-width: 0;
      opacity: 0;
      transition: max-width .3s ease, opacity .3s ease;
      white-space: nowrap;
    }
    #wa-btn:hover #wa-btn-label {
      max-width: 180px;
      opacity: 1;
    }

    /* Pulse ring — fires once when button first appears */
    @keyframes wa-pulse {
      0%   { box-shadow: 0 0 0 0 rgba(37,211,102,.55); }
      70%  { box-shadow: 0 0 0 18px rgba(37,211,102,0); }
      100% { box-shadow: 0 0 0 0 rgba(37,211,102,0); }
    }
    #wa-btn.wa-pulse {
      animation: wa-pulse 1s ease-out 2;
    }

    @media (max-width: 600px) {
      #wa-btn { bottom: 22px; right: 18px; padding: 13px 15px; }
    }
  `;
  document.head.appendChild(style);

  /* ── Inject HTML ────────────────────────────────────────────── */
  const encodedMsg = encodeURIComponent(WA_MESSAGE);
  const link = document.createElement('a');
  link.id     = 'wa-btn';
  link.href   = `https://wa.me/${WA_NUMBER}?text=${encodedMsg}`;
  link.target = '_blank';
  link.rel    = 'noopener noreferrer';
  link.setAttribute('aria-label', 'Chat with us on WhatsApp');
  link.innerHTML = `
    <!-- WhatsApp logo SVG -->
    <svg viewBox="0 0 24 24" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
      <path d="M20.52 3.48A11.93 11.93 0 0 0 12 0C5.37 0 0 5.37 0 12c0 2.11.55 4.17 1.6 5.98L0 24l6.19-1.62A11.94 11.94 0 0 0 12 24c6.63 0 12-5.37 12-12 0-3.2-1.25-6.21-3.48-8.52zM12 21.94a9.9 9.9 0 0 1-5.05-1.38l-.36-.21-3.73.98.99-3.63-.24-.38A9.93 9.93 0 0 1 2.06 12C2.06 6.51 6.51 2.06 12 2.06S21.94 6.51 21.94 12 17.49 21.94 12 21.94zm5.44-7.44c-.3-.15-1.76-.87-2.03-.97-.27-.1-.47-.15-.67.15-.2.3-.77.97-.94 1.17-.17.2-.35.22-.65.07-.3-.15-1.26-.46-2.4-1.47-.89-.79-1.49-1.76-1.66-2.06-.17-.3-.02-.46.13-.61.13-.13.3-.35.45-.52.15-.17.2-.3.3-.5.1-.2.05-.37-.02-.52-.07-.15-.67-1.61-.92-2.2-.24-.58-.49-.5-.67-.51h-.57c-.2 0-.52.07-.79.37-.27.3-1.04 1.02-1.04 2.48s1.07 2.88 1.22 3.08c.15.2 2.1 3.2 5.08 4.49.71.31 1.26.49 1.69.62.71.23 1.36.2 1.87.12.57-.09 1.76-.72 2.01-1.41.25-.69.25-1.28.17-1.41-.07-.12-.27-.2-.57-.35z"/>
    </svg>
    <span id="wa-btn-label">Chat with us</span>
  `;
  document.body.appendChild(link);

  /* ── Scroll listener ────────────────────────────────────────── */
  let shown = false;
  let pulsed = false;

  function onScroll() {
    const scrolled = window.scrollY || document.documentElement.scrollTop;
    if (!shown && scrolled >= SCROLL_THRESHOLD) {
      shown = true;
      link.classList.add('wa-visible');
      // Pulse once 400 ms after it appears
      if (!pulsed) {
        pulsed = true;
        setTimeout(() => link.classList.add('wa-pulse'), 400);
        setTimeout(() => link.classList.remove('wa-pulse'), 2800);
      }
    } else if (shown && scrolled < SCROLL_THRESHOLD) {
      shown = false;
      link.classList.remove('wa-visible');
    }
  }

  window.addEventListener('scroll', onScroll, { passive: true });
})();
