import type { ReactNode } from "react";

import type { Metadata } from "next";

import AuthBackground from "@/components/auth/AuthBackground";
import AuthFooter from "@/components/auth/AuthFooter";
import AuthHeader from "@/components/auth/AuthHeader";

export const metadata: Metadata = {
  title: "Account | SudarX",
  description:
    "Sign in to your SudarX account or create a new one to stream Nepali movies and series.",
};

type AuthLayoutProps = {
  children: ReactNode;
};

export default function AuthLayout({ children }: AuthLayoutProps) {
  return (
    <div className="relative flex min-h-svh flex-col overflow-x-hidden bg-[#050f1a] text-on-surface antialiased">
      <AuthBackground />

      <AuthHeader />

      <div className="relative z-10 flex w-full flex-1 flex-col items-center justify-center px-4 py-8 sm:px-6 sm:py-12">
        {children}
      </div>

      <AuthFooter />
    </div>
  );
}
