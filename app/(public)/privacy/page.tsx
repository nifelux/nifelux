import { Metadata } from "next";
export const metadata: Metadata = { title: "Privacy Policy" };

export default function PrivacyPage() {
  return (
    <div className="min-h-screen bg-brand-dark py-24">
      <div className="container-custom max-w-3xl">
        <div className="mb-12">
          <span className="badge-brand inline-flex mb-4">Legal</span>
          <h1 className="font-display text-4xl md:text-5xl font-bold text-white mb-4">Privacy Policy</h1>
          <p className="text-text-muted text-sm">Last updated: {new Date().toLocaleDateString("en-NG", { year: "numeric", month: "long", day: "numeric" })}</p>
        </div>

        <div className="glass-card p-8 md:p-12 space-y-8 text-text-secondary leading-relaxed">
          {[
            { title: "1. Information We Collect", content: "We collect information you provide directly to us, such as when you create an account, submit a contact form, or make a payment. This includes your name, email address, phone number, and payment information. We also collect information automatically when you use our platform, including log data and usage information." },
            { title: "2. How We Use Your Information", content: "We use the information we collect to provide, maintain, and improve our services, process transactions, send transactional and promotional communications, and comply with legal obligations. We do not sell your personal information to third parties." },
            { title: "3. Information Sharing", content: "We may share your information with service providers who assist us in operating our platform (including Supabase for database services, iPayNG for payment processing, and Resend for email delivery). These providers are bound by confidentiality agreements." },
            { title: "4. Data Security", content: "We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. All data is encrypted in transit and at rest." },
            { title: "5. Your Rights", content: "You have the right to access, correct, or delete your personal information. You may also object to or restrict certain processing of your data. To exercise these rights, contact us at hello@nifelux.com." },
            { title: "6. Cookies", content: "We use cookies and similar tracking technologies to provide and improve our services. You can control cookies through your browser settings, though disabling cookies may affect platform functionality." },
            { title: "7. Changes to This Policy", content: "We may update this privacy policy from time to time. We will notify you of any significant changes by posting the new policy on this page and updating the effective date." },
            { title: "8. Contact Us", content: "If you have any questions about this privacy policy, please contact us at hello@nifelux.com or write to us at: Nifelux Technologies, Lagos, Nigeria." },
          ].map(({ title, content }) => (
            <div key={title}>
              <h2 className="font-display text-lg font-bold text-white mb-3">{title}</h2>
              <p>{content}</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
