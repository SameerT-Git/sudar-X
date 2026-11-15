import { Languages } from "lucide-react";

type LanguageToggleProps = {
  className?: string;
};

export default function LanguageToggle({ className = "" }: LanguageToggleProps) {
  return (
    <button
      type="button"
      aria-label="Switch language"
      className={`items-center gap-space-xs font-label-md text-label-md text-on-surface-variant hover:text-on-surface px-space-sm py-space-xs rounded-lg hover:bg-surface-container transition-colors ${className}`}
    >
      <Languages aria-hidden="true" size={18} />
      <span>नेपाली / EN</span>
    </button>
  );
}
