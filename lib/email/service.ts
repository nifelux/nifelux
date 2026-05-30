// ============================================
// NIFELUX — Email Service (Resend)
// SERVER-SIDE ONLY — never import in client
// ============================================

const RESEND_API = "https://api.resend.com/emails";
const FROM = "Nifelux Technologies <noreply@nifelux.com>";

async function sendEmail(payload: {
  to: string;
  subject: string;
  html: string;
}) {
  if (!process.env.RESEND_API_KEY) {
    console.warn("RESEND_API_KEY not set — email skipped");
    return;
  }

  const res = await fetch(RESEND_API, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${process.env.RESEND_API_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ from: FROM, ...payload }),
  });

  if (!res.ok) {
    const err = await res.text();
    console.error("Email send failed:", err);
    throw new Error(`Email failed: ${err}`);
  }

  return res.json();
}

export const emailService = {
  async sendPaymentReceipt({
    to,
    amount,
    reference,
    purpose,
  }: {
    to: string;
    amount: number;
    reference: string;
    purpose: string;
  }) {
    return sendEmail({
      to,
      subject: `Payment Receipt — ₦${amount.toLocaleString()} | Nifelux Technologies`,
      html: `
        <div style="font-family:system-ui,sans-serif;max-width:520px;margin:0 auto;background:#050816;color:#fff;border-radius:16px;overflow:hidden;">
          <div style="background:linear-gradient(135deg,#2563EB,#7C3AED);padding:32px 24px;text-align:center;">
            <h1 style="margin:0;font-size:24px;font-weight:700;">Nifelux Technologies</h1>
            <p style="margin:8px 0 0;opacity:0.8;font-size:14px;">Payment Receipt</p>
          </div>
          <div style="padding:32px 24px;">
            <p style="color:#CBD5E1;font-size:14px;margin:0 0 24px;">Thank you for your payment. Here are your transaction details:</p>
            <div style="background:#111827;border-radius:12px;padding:20px;margin-bottom:24px;">
              <div style="display:flex;justify-content:space-between;margin-bottom:12px;">
                <span style="color:#94A3B8;font-size:13px;">Amount</span>
                <span style="color:#22C55E;font-weight:700;font-size:18px;">₦${amount.toLocaleString()}</span>
              </div>
              <div style="display:flex;justify-content:space-between;margin-bottom:12px;">
                <span style="color:#94A3B8;font-size:13px;">Reference</span>
                <span style="color:#fff;font-size:12px;font-family:monospace;">${reference}</span>
              </div>
              <div style="display:flex;justify-content:space-between;margin-bottom:12px;">
                <span style="color:#94A3B8;font-size:13px;">Purpose</span>
                <span style="color:#fff;font-size:13px;text-transform:capitalize;">${purpose}</span>
              </div>
              <div style="display:flex;justify-content:space-between;">
                <span style="color:#94A3B8;font-size:13px;">Status</span>
                <span style="color:#22C55E;font-size:13px;font-weight:600;">Successful ✓</span>
              </div>
            </div>
            <p style="color:#64748B;font-size:12px;text-align:center;margin:0;">
              Questions? Contact us at <a href="mailto:hello@nifelux.com" style="color:#3B82F6;">hello@nifelux.com</a>
            </p>
          </div>
          <div style="background:#0B1120;padding:16px 24px;text-align:center;">
            <p style="color:#475569;font-size:11px;margin:0;">© ${new Date().getFullYear()} Nifelux Technologies, Lagos Nigeria</p>
          </div>
        </div>
      `,
    });
  },

  async sendWelcomeEmail({ to, name }: { to: string; name: string }) {
    return sendEmail({
      to,
      subject: "Welcome to Nifelux Technologies 🚀",
      html: `
        <div style="font-family:system-ui,sans-serif;max-width:520px;margin:0 auto;background:#050816;color:#fff;border-radius:16px;overflow:hidden;">
          <div style="background:linear-gradient(135deg,#2563EB,#7C3AED);padding:32px 24px;text-align:center;">
            <h1 style="margin:0;font-size:24px;font-weight:700;">Welcome to Nifelux</h1>
          </div>
          <div style="padding:32px 24px;">
            <h2 style="margin:0 0 12px;font-size:20px;">Hi ${name} 👋</h2>
            <p style="color:#CBD5E1;font-size:14px;line-height:1.6;margin:0 0 24px;">
              Your Nifelux Technologies account has been created successfully.
              You now have access to your digital dashboard, certifications, and ID management.
            </p>
            <a href="${process.env.NEXT_PUBLIC_APP_URL}/dashboard" 
               style="display:inline-block;background:linear-gradient(135deg,#2563EB,#7C3AED);color:#fff;padding:12px 24px;border-radius:10px;text-decoration:none;font-weight:600;font-size:14px;">
              Go to Dashboard →
            </a>
          </div>
          <div style="background:#0B1120;padding:16px 24px;text-align:center;">
            <p style="color:#475569;font-size:11px;margin:0;">© ${new Date().getFullYear()} Nifelux Technologies, Lagos Nigeria</p>
          </div>
        </div>
      `,
    });
  },

  async sendCertificateIssued({
    to,
    name,
    title,
    verificationCode,
  }: {
    to: string;
    name: string;
    title: string;
    verificationCode: string;
  }) {
    return sendEmail({
      to,
      subject: `Your Certificate: ${title} | Nifelux Technologies`,
      html: `
        <div style="font-family:system-ui,sans-serif;max-width:520px;margin:0 auto;background:#050816;color:#fff;border-radius:16px;overflow:hidden;">
          <div style="background:linear-gradient(135deg,#22C55E,#2563EB);padding:32px 24px;text-align:center;">
            <h1 style="margin:0;font-size:24px;font-weight:700;">🏆 Certificate Issued</h1>
          </div>
          <div style="padding:32px 24px;">
            <h2 style="margin:0 0 8px;font-size:18px;">Congratulations, ${name}!</h2>
            <p style="color:#CBD5E1;font-size:14px;line-height:1.6;margin:0 0 24px;">
              You have been awarded the following certificate by Nifelux Technologies:
            </p>
            <div style="background:#111827;border-radius:12px;padding:20px;margin-bottom:24px;text-align:center;">
              <p style="color:#22C55E;font-size:11px;font-weight:600;text-transform:uppercase;letter-spacing:0.1em;margin:0 0 8px;">Certificate of Achievement</p>
              <h3 style="color:#fff;font-size:20px;margin:0 0 16px;">${title}</h3>
              <p style="color:#94A3B8;font-size:11px;margin:0 0 4px;">Verification Code</p>
              <p style="color:#fff;font-family:monospace;font-size:14px;background:#1F2937;padding:8px 16px;border-radius:8px;display:inline-block;margin:0;">${verificationCode}</p>
            </div>
            <a href="${process.env.NEXT_PUBLIC_APP_URL}/verify/${verificationCode}"
               style="display:inline-block;background:linear-gradient(135deg,#22C55E,#2563EB);color:#fff;padding:12px 24px;border-radius:10px;text-decoration:none;font-weight:600;font-size:14px;">
              View & Verify Certificate →
            </a>
          </div>
          <div style="background:#0B1120;padding:16px 24px;text-align:center;">
            <p style="color:#475569;font-size:11px;margin:0;">© ${new Date().getFullYear()} Nifelux Technologies, Lagos Nigeria</p>
          </div>
        </div>
      `,
    });
  },

  async sendIdIssued({
    to,
    name,
    idNumber,
  }: {
    to: string;
    name: string;
    idNumber: string;
  }) {
    return sendEmail({
      to,
      subject: "Your Nifelux Digital ID Has Been Issued",
      html: `
        <div style="font-family:system-ui,sans-serif;max-width:520px;margin:0 auto;background:#050816;color:#fff;border-radius:16px;overflow:hidden;">
          <div style="background:linear-gradient(135deg,#2563EB,#7C3AED);padding:32px 24px;text-align:center;">
            <h1 style="margin:0;font-size:24px;font-weight:700;">🪪 Digital ID Issued</h1>
          </div>
          <div style="padding:32px 24px;">
            <h2 style="margin:0 0 12px;font-size:18px;">Hi ${name},</h2>
            <p style="color:#CBD5E1;font-size:14px;line-height:1.6;margin:0 0 24px;">Your Nifelux Digital ID has been issued and is now active.</p>
            <div style="background:#111827;border-radius:12px;padding:20px;margin-bottom:24px;text-align:center;">
              <p style="color:#94A3B8;font-size:11px;margin:0 0 8px;">ID Number</p>
              <p style="color:#fff;font-family:monospace;font-size:20px;font-weight:700;margin:0;">${idNumber}</p>
            </div>
            <a href="${process.env.NEXT_PUBLIC_APP_URL}/id-card"
               style="display:inline-block;background:linear-gradient(135deg,#2563EB,#7C3AED);color:#fff;padding:12px 24px;border-radius:10px;text-decoration:none;font-weight:600;font-size:14px;">
              View My ID Card →
            </a>
          </div>
          <div style="background:#0B1120;padding:16px 24px;text-align:center;">
            <p style="color:#475569;font-size:11px;margin:0;">© ${new Date().getFullYear()} Nifelux Technologies, Lagos Nigeria</p>
          </div>
        </div>
      `,
    });
  },
};
