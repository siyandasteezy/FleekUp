// ─────────────────────────────────────────────────────────────────────────────
// Fleek Up Home — PayFast Configuration
//
// SANDBOX (testing)  →  credentials below are the official PayFast test account.
//                        Set PAYFAST_SANDBOX = true.
//
// PRODUCTION         →  1. Log in to payfast.co.za → Settings → Integration
//                        2. Copy your Merchant ID and Merchant Key
//                        3. Set a Passphrase in the PayFast dashboard (recommended)
//                        4. Replace the values below and set PAYFAST_SANDBOX = false
// ─────────────────────────────────────────────────────────────────────────────

const PAYFAST_SANDBOX       = true;                  // ← set false for production

const PAYFAST_MERCHANT_ID   = '10000100';            // sandbox test ID
const PAYFAST_MERCHANT_KEY  = '46f0cd694581a';       // sandbox test key
const PAYFAST_PASSPHRASE    = '';                    // set in PayFast dashboard

// Notify URL — receives Instant Transaction Notifications (ITN) from PayFast.
// Must be a publicly reachable HTTPS endpoint that returns HTTP 200.
// Leave blank for sandbox demos; required for production.
// Example (Supabase Edge Function): 'https://xxxx.supabase.co/functions/v1/payfast-itn'
const PAYFAST_NOTIFY_URL    = '';

// Derived — do not change
const PAYFAST_PROCESS_URL   = PAYFAST_SANDBOX
  ? 'https://sandbox.payfast.co.za/eng/process'
  : 'https://www.payfast.co.za/eng/process';
