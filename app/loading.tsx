import LoadingSpinner from "@/components/common/LoadingSpinner";
export default function Loading() {
  return (
    <div className="min-h-screen bg-brand-dark flex items-center justify-center">
      <div className="flex flex-col items-center gap-4">
        <LoadingSpinner size="lg" />
        <p className="text-text-muted text-sm animate-pulse">Loading...</p>
      </div>
    </div>
  );
}
