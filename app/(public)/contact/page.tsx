import { Metadata } from "next";
export const metadata: Metadata = { title: "Contact" };
export default function ContactPage() {
  return (
    <div className="min-h-screen bg-brand-dark flex items-center justify-center">
      <div className="text-center px-4">
        <div className="w-16 h-16 rounded-2xl bg-brand-gradient mx-auto flex items-center justify-center mb-6">
          <span className="text-2xl">🚀</span>
        </div>
        <h1 className="font-display text-3xl font-bold text-white mb-3">Contact</h1>
        <p className="text-text-muted text-sm max-w-sm mx-auto">Full page implementation ready. Copy the matching Phase 1 output file into this path.</p>
        <a href="/" className="inline-flex items-center gap-2 mt-6 text-sm text-brand-blue-light hover:text-white transition-colors">← Back to Home</a>
      </div>
    </div>
  );
}
