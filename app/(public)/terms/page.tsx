import { Metadata } from "next";
export const metadata: Metadata = { title: "Terms of Service" };

export default function TermsPage() {
  return (
    <div className="min-h-screen bg-brand-dark py-24">
      <div className="container-custom max-w-3xl">
        <div className="mb-12">
          <span className="badge-brand inline-flex mb-4">Legal</span>
          <h1 className="font-display text-4xl md:text-5xl font-bold text-white mb-4">Terms of Service</h1>
          <p className="text-text-muted text-sm">Last updated: {new Date().toLocaleDateString("en-NG", { year: "numeric", month: "long", day: "numeric" })}</p>
        </div>

        <div className="glass-card p-8 md:p-12 space-y-8 text-text-secondary leading-relaxed">
          {[
            { title: "1. Acceptance of Terms", content: "By accessing or using the Nifelux Technologies platform, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our services." },
            { title: "2. Use of Services", content: "You may use our services only for lawful purposes and in accordance with these terms. You agree not to use our services in any way that violates applicable laws, infringes on intellectual property rights, or transmits harmful content." },
            { title: "3. Account Registration", content: "To access certain features, you must register for an account. You are responsible for maintaining the confidentiality of your credentials and for all activities that occur under your account." },
            { title: "4. Digital IDs and Certifications", content: "Digital IDs and certifications issued by Nifelux Technologies are the intellectual property of Nifelux Technologies. They may not be forged, altered, or misrepresented. Fraudulent use will result in immediate revocation and may result in legal action." },
            { title: "5. Payments", content: "All payments are processed securely through iPayNG. By making a payment, you agree to iPayNG's terms of service. All contributions to Nifelux Technologies are non-refundable unless otherwise stated." },
            { title: "6. Intellectual Property", content: "All content on this platform, including text, graphics, logos, and software, is the property of Nifelux Technologies and is protected by Nigerian and international copyright laws." },
            { title: "7. Disclaimer of Warranties", content: "Our services are provided on an 'as is' basis without warranties of any kind. Nifelux Technologies does not warrant that the platform will be uninterrupted, error-free, or free of harmful components." },
            { title: "8. Limitation of Liability", content: "To the fullest extent permitted by law, Nifelux Technologies shall not be liable for any indirect, incidental, special, or consequential damages arising from your use of our services." },
            { title: "9. Governing Law", content: "These terms shall be governed by and construed in accordance with the laws of the Federal Republic of Nigeria. Any disputes shall be resolved in the courts of Lagos State, Nigeria." },
            { title: "10. Contact", content: "For questions about these terms, contact us at hello@nifelux.com or: Nifelux Technologies, Lagos, Nigeria." },
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
