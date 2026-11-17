import Link from "next/link";
import { ArrowLeft, HelpCircle } from "lucide-react";

export default function AdminHeader() {
  return (
    <header className="fixed top-0 w-full z-50 bg-surface-container-lowest/80 backdrop-blur-xl shadow-[0_1px_8px_rgba(0,0,0,0.4)]">
      <div className="w-full max-w-7xl mx-auto px-6 h-16 flex items-center justify-between">
        <Link href="/" className="flex items-center gap-3 select-none">
          <span className="text-2xl font-black tracking-tight text-white">
            Sudar<span className="text-[#dc143c]">X</span>
          </span>
          <span className="text-[10px] font-bold tracking-widest px-2 py-0.5 rounded uppercase bg-[#16202c] text-slate-300 border border-[#2a384b]">
            ADMIN PORTAL
          </span>
        </Link>

        <div className="flex items-center gap-6">
          <Link
            href="#"
            className="flex items-center gap-1.5 text-slate-400 hover:text-white transition-colors text-sm font-medium whitespace-nowrap"
          >
            <HelpCircle size={18} aria-hidden="true" />
            <span>Support</span>
          </Link>
          <Link
            href="/"
            className="flex items-center gap-1.5 text-slate-400 hover:text-white transition-colors text-sm font-medium whitespace-nowrap"
          >
            <ArrowLeft size={18} aria-hidden="true" />
            <span>Back to SudarX</span>
          </Link>
        </div>
      </div>
    </header>
  );
}
