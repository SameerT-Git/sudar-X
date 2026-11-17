import Link from "next/link";

export default function AuthFooter() {
  return (
    <footer className="relative z-10 w-full bg-[#050f1a]/95 backdrop-blur-md border-t border-[#223042]/50 py-5 sm:py-6">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex items-center justify-center text-xs sm:text-sm text-slate-400">
        <div className="flex items-center justify-center gap-15 sm:gap-20">
          <Link href="#" className="hover:text-white transition-colors">
            Terms
          </Link>
          <Link href="#" className="hover:text-white transition-colors">
            Privacy
          </Link>
          <Link href="#" className="hover:text-white transition-colors">
            Support
          </Link>
        </div>
      </div>
    </footer>
  );
}
