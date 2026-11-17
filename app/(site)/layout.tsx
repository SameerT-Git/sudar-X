import type { ReactNode } from "react";
import { Suspense } from "react";

import Footer from "@/components/layout/Footer";
import Navbar from "@/components/layout/Navbar";

type SiteLayoutProps = {
  children: ReactNode;
};

export default function SiteLayout({ children }: SiteLayoutProps) {
  return (
    <>
      <Suspense
        fallback={
          <div className="fixed top-0 left-0 right-0 z-50 h-20 bg-surface/90 backdrop-blur-md" />
        }
      >
        <Navbar />
      </Suspense>

      <main className="w-full flex-1 bg-background pt-20">{children}</main>

      <Footer />
    </>
  );
}
