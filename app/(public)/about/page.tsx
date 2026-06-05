import { Metadata } from "next";
import AboutClient from "@/features/about/AboutClient";

export const metadata: Metadata = {
  title: "About",
  description: "Nifelux Technologies is a futuristic Nigerian technology company building intelligent AI systems, robotics, and automation for Africa and the world. Founded by Oluwanifemi Abdullahi Olude.",
  openGraph: {
    title: "About Nifelux Technologies",
    description: "Building Africa's technology future from Lagos, Nigeria.",
    images: [{ url: "/og/og-about.png", width: 1200, height: 630 }],
  },
};

export default function AboutPage() { return <AboutClient />; }
