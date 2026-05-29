import QRCode from "qrcode";

export async function generateQRCodeDataURL(text: string): Promise<string> {
  return await QRCode.toDataURL(text, {
    errorCorrectionLevel: "H",
    type: "image/png",
    margin: 1,
    color: { dark: "#000000", light: "#FFFFFF" },
    width: 300,
  });
}

export async function generateQRCodeSVG(text: string): Promise<string> {
  return await QRCode.toString(text, {
    type: "svg",
    errorCorrectionLevel: "H",
    margin: 1,
  });
}

export function buildVerifyUrl(token: string): string {
  const base = process.env.NEXT_PUBLIC_APP_URL || "https://nifelux.com";
  return `${base}/verify/${token}`;
}
