export const paymentService = {
  async initiate(amount: number, email: string, purpose: string, metadata?: Record<string, unknown>) {
    const res = await fetch("/api/payments", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ amount, email, purpose, metadata }) });
    if (!res.ok) throw new Error("Payment initiation failed");
    return res.json();
  },
};
