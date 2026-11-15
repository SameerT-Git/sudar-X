import type { ReactNode } from "react";
import { Suspense } from "react";

import type { Metadata } from "next";
import { Inter, Plus_Jakarta_Sans } from "next/font/google";

import Footer from "@/components/layout/Footer";
import Navbar from "@/components/layout/Navbar";

import "./globals.css";

const inter = Inter({
  variable: "--font-inter",
  subsets: ["latin"],
  display: "swap",
});

const plusJakartaSans = Plus_Jakarta_Sans({
  variable: "--font-plus-jakarta-sans",
  subsets: ["latin"],
  display: "swap",
});

export const metadata: Metadata = {
  title: "SudarX | Nepali Movies & Series",
  description: "Discover and stream Nepali movies and series on SudarX.",
};

type RootLayoutProps = {
  children: ReactNode;
};

export default function RootLayout({ children }: RootLayoutProps) {
  return (
    <html lang="en" className="dark">
      <body
        className={`${inter.variable} ${plusJakartaSans.variable} bg-background font-body-md text-on-surface antialiased min-h-screen flex flex-col`}
      >
        <Suspense
          fallback={
            <div className="fixed top-0 left-0 right-0 z-50 h-20 bg-surface/90 backdrop-blur-md" />
          }
        >
          <Navbar />
        </Suspense>

        <main className="w-full flex-1 bg-background pt-20">{children}</main>

        <Footer />
      </body>
    </html>
  );
}
