
import Link from "next/link";
import Image from "next/image";
import { ArrowLeft } from "lucide-react";

export default function AuthHeader() {
  return (
    <header className="relative z-40 w-full bg-surface-container-lowest/60 backdrop-blur-xl border-b border-[#223042]/40">

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 sm:h-20 flex items-center justify-between">
        <Link
          href="/"
          className="flex items-center gap-2 group transition-opacity hover:opacity-90"
        >
          <Image
            src="/image/logo/screen.png"
            alt="SudarX Logo"
            width={150}
            height={40}
            className="h-7 sm:h-8 md:h-9 w-auto object-contain block"
            priority
          />
          <div className="hidden items-center text-xl sm:text-2xl font-black font-display tracking-tight text-white">
            Sudar<span className="text-[#dc143c]">X</span>
          </div>
        </Link>

        <Link
          href="/"
          className="group inline-flex items-center gap-2 px-3 py-1.5 sm:px-3.5 sm:py-2 text-xs sm:text-sm font-medium text-slate-300 hover:text-white rounded-lg hover:bg-surface-container-high/60 border border-transparent hover:border-[#223042] transition-all duration-200"
        >
          <ArrowLeft className="material-symbols-outlined text-[18px] sm:text-[20px] transition-transform duration-200 group-hover:-translate-x-1"/>
          <span>Back to Browse</span>
        </Link>

      </div>
    </header>
  );
}
