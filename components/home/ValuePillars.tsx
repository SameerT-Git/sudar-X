import { Download, Drama, MonitorPlay, MonitorSmartphone, Wallet } from "lucide-react";
import type { LucideIcon } from "lucide-react";

import { VALUE_PILLARS } from "@/data/landing";
import type { PillarIcon } from "@/data/landing";

const PILLAR_ICONS: Record<PillarIcon, LucideIcon> = {
  wallet: Wallet,
  hd: MonitorPlay,
  voices: Drama,
  screens: MonitorSmartphone,
  download: Download,
};

const PILLAR_TONES = {
  primary: "bg-primary-container/20 text-primary",
  secondary: "bg-secondary-container/30 text-secondary",
} as const;

export default function ValuePillars() {
  return (
    <section className="flex flex-col gap-space-lg">
      <div className="text-center max-w-2xl mx-auto flex flex-col gap-space-xs">
        <span className="font-label-badge text-label-badge text-primary uppercase tracking-widest font-bold">
          Built for Cinema Lovers
        </span>
        <h2 className="font-headline-lg-mobile md:text-headline-lg font-headline-lg text-white">
          Why Stream on SudarX?
        </h2>
        <p className="font-body-md text-body-md text-on-surface-variant">
          The definitive streaming technology built specifically for low-latency
          playback across Nepal and the diaspora.
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-5 gap-space-md">
        {VALUE_PILLARS.map((pillar) => {
          const Icon = PILLAR_ICONS[pillar.icon];
          return (
            <div
              key={pillar.id}
              className="flex flex-col gap-space-sm p-space-md rounded-xl bg-surface-container/60 hover:bg-surface-container transition-all"
            >
              <div
                className={`w-12 h-12 rounded-xl flex items-center justify-center ${PILLAR_TONES[pillar.tone]}`}
              >
                <Icon aria-hidden="true" size={26} />
              </div>
              <h3 className="font-headline-sm text-headline-sm text-white font-bold">
                {pillar.title}
              </h3>
              <p className="font-body-sm text-body-sm text-on-surface-variant">
                {pillar.body}
              </p>
            </div>
          );
        })}
      </div>
    </section>
  );
}
