export default function AuthLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-screen bg-brand-dark flex items-center justify-center relative overflow-hidden">
      <div className="absolute inset-0 bg-hero-gradient" /><div className="absolute inset-0 dot-pattern opacity-30" />
      <div className="absolute top-1/4 left-1/4 w-80 h-80 orb orb-blue opacity-30 animate-float-slow" />
      <div className="absolute bottom-1/4 right-1/4 w-60 h-60 orb orb-purple opacity-20 animate-float" />
      <div className="relative z-10 w-full max-w-md px-4">{children}</div>
    </div>
  );
}
