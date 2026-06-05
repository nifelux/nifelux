import { Metadata } from "next";
export const metadata: Metadata = {
  title: "Contact",
  description: "Contact Nifelux Technologies for partnerships, project inquiries, or investment discussions. Based in Lagos, Nigeria.",
  openGraph: { title: "Contact — Nifelux Technologies", description: "Contact Nifelux Technologies for partnerships, project inquiries, or investment discussions. Based in Lagos, Nigeria." },
};
// Full implementation: paste the matching *Client component or Phase 1 page content here
export default function ContactPage() {
  return (
    <div className="min-h-screen bg-brand-dark flex items-center justify-center">
      <div className="text-center px-4">
        <div className="w-16 h-16 rounded-2xl bg-brand-gradient mx-auto flex items-center justify-center mb-6 shadow-glow"><span className="text-2xl">⚙️</span></div>
        <h1 className="font-display text-3xl font-bold text-white mb-3">Contact</h1>
        <p className="text-text-muted text-sm max-w-sm mx-auto mb-6">Paste the full page implementation here from the Phase 1 output files.</p>
        <a href="/" className="text-sm text-brand-blue-light hover:text-white transition-colors">← Back to Home</a>
      </div>
    </div>
  );
}
