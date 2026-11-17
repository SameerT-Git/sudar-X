import type { ReactNode } from "react";
import type { Metadata } from "next";

import AdminHeader from "@/components/auth/AdminHeader";
import AuthBackground from "@/components/auth/AuthBackground";

export const metadata: Metadata = {
  title: "Admin Sign In | SudarX",
  description: "Sign in to access the SudarX admin management portal.",
};

export default function AdminLoginLayout({ children }: { children: ReactNode }) {
  return (
    <div className="relative flex min-h-svh flex-col overflow-x-hidden bg-[#050f1a] text-on-surface antialiased">
      <AuthBackground />
      <AdminHeader />
      <div className="relative z-10 flex w-full flex-1 flex-col items-center justify-center px-4 pt-24 pb-12 sm:px-6">
        {children}
      </div>
    </div>
  );
}
