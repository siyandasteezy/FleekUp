// ─────────────────────────────────────────────────────────────────────────────
// Fleek Up Home — Cart Module
// Included on every page. Exposes window.Cart for all cart operations.
// Data is persisted in localStorage under 'fleekup_cart'.
// ─────────────────────────────────────────────────────────────────────────────

(function () {
  const KEY = 'fleekup_cart';

  // ── Internal helpers ────────────────────────────────────────────────────────

  function _get() {
    try { return JSON.parse(localStorage.getItem(KEY) || '[]'); }
    catch { return []; }
  }

  function _save(cart) {
    localStorage.setItem(KEY, JSON.stringify(cart));
    _badge();
  }

  function _badge() {
    const count = _get().reduce((s, i) => s + i.quantity, 0);
    document.querySelectorAll('.cart-count').forEach(el => {
      el.textContent = count;
      el.style.display = count > 0 ? 'flex' : 'none';
    });
  }

  // ── Public API ───────────────────────────────────────────────────────────────

  /**
   * Add an item to the cart. If the product already exists, its quantity
   * is incremented. Caps at 10 per product.
   * @param {{ id, name, price, image, quantity? }} item
   * @returns {number} new total item count
   */
  function add(item) {
    const cart = _get();
    const existing = cart.find(i => i.id === item.id);
    if (existing) {
      existing.quantity = Math.min(10, existing.quantity + (item.quantity || 1));
    } else {
      cart.push({
        id:       item.id,
        name:     item.name,
        price:    item.price,
        image:    item.image || '',
        quantity: item.quantity || 1,
      });
    }
    _save(cart);
    return count();
  }

  /** Remove an item entirely from the cart by product id. */
  function remove(id) {
    _save(_get().filter(i => i.id !== id));
  }

  /**
   * Set quantity of a specific item. If qty ≤ 0 the item is removed.
   */
  function setQty(id, qty) {
    if (qty <= 0) { remove(id); return; }
    const cart = _get();
    const item = cart.find(i => i.id === id);
    if (item) { item.quantity = Math.min(10, qty); _save(cart); }
  }

  /** Empty the entire cart. */
  function clear() {
    localStorage.removeItem(KEY);
    _badge();
  }

  /** Returns the raw cart array. */
  function get() { return _get(); }

  /** Total number of individual units in the cart. */
  function count() { return _get().reduce((s, i) => s + i.quantity, 0); }

  /** Cart subtotal in ZAR (sum of price × quantity). */
  function total() { return _get().reduce((s, i) => s + (i.price || 0) * i.quantity, 0); }

  /** Force-refresh all badge elements (call after DOM is ready). */
  function refreshBadge() { _badge(); }

  // Expose
  window.Cart = { add, remove, setQty, clear, get, count, total, refreshBadge };

  // Update badge as soon as the DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', _badge);
  } else {
    _badge();
  }
})();
