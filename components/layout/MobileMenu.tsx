import Link from "next/link";

import LanguageToggle from "./LanguageToggle";
import NavLinks from "./NavLinks";
import SearchField from "./SearchField";

type MobileMenuProps = {
  id?: string;
  onClose: () => void;
};

export default function MobileMenu({ id, onClose }: MobileMenuProps) {
  return (
    <div
      id={id}
      className="lg:hidden bg-surface/95 backdrop-blur-md border-t border-surface-container-high/60 shadow-lg"
    >
      <div className="px-margin-mobile py-space-md flex flex-col gap-space-md">
        {/* The header search pill is hidden below sm, so repeat it here. */}
        <SearchField className="flex w-full sm:hidden" />

        <NavLinks variant="mobile" onNavigate={onClose} />

        <div className="flex flex-col gap-space-sm border-t border-surface-container-high/60 pt-space-md">
          <LanguageToggle className="flex w-full justify-center md:hidden" />

          <div className="flex items-center gap-space-sm">
            <Link
              href="/Sign-In"
              onClick={onClose}
              className="flex-1 text-center font-label-lg text-label-lg text-on-surface hover:text-primary px-space-sm py-space-sm rounded-full transition-colors"
            >
              Login
            </Link>
            <Link
              href="/Sign-Up"
              onClick={onClose}
              className="flex-1 text-center font-label-lg text-label-lg font-semibold bg-primary-container text-on-primary-container px-space-lg py-space-sm rounded-full shadow-[0_4px_16px_rgba(220,20,60,0.35)] hover:shadow-[0_6px_24px_rgba(220,20,60,0.6)] hover:brightness-110 transition-all"
            >
              Sign Up
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}
