import Image from "next/image";
import { Globe } from "lucide-react";

import { EDITORIAL } from "@/data/landing";

export default function EditorialBanner() {
  return (
    <section className="relative w-full rounded-2xl overflow-hidden bg-gradient-to-r from-surface-container-low via-surface-container to-surface-container-low p-space-lg lg:p-space-xl shadow-2xl">
      <div className="relative z-10 grid grid-cols-1 lg:grid-cols-12 gap-space-lg items-center">
        <div className="lg:col-span-7 flex flex-col gap-space-sm">
          <div className="flex items-center gap-space-xs text-primary font-label-badge text-label-badge tracking-widest uppercase">
            <Globe aria-hidden="true" size={18} />
            <span>{EDITORIAL.eyebrow}</span>
          </div>

          <h2 className="font-display-hero text-headline-lg-mobile md:text-headline-lg font-headline-lg text-white font-bold leading-tight">
            {EDITORIAL.heading}
          </h2>

          <p className="font-body-lg text-body-md md:text-body-lg text-on-surface-variant max-w-xl">
            {EDITORIAL.body}
          </p>

          <div className="grid grid-cols-2 sm:grid-cols-4 gap-space-sm mt-space-md">
            {EDITORIAL.stats.map((stat) => (
              <div
                key={stat.label}
                className="flex flex-col bg-surface/60 backdrop-blur-sm p-space-sm rounded-xl"
              >
                <span
                  className={`font-headline-md text-headline-md font-bold ${stat.tone}`}
                >
                  {stat.value}
                </span>
                <span className="font-body-sm text-body-sm text-tertiary">
                  {stat.label}
                </span>
              </div>
            ))}
          </div>
        </div>

        <div className="lg:col-span-5 flex justify-center">
          <div className="relative w-full max-w-md aspect-[4/3] rounded-2xl overflow-hidden shadow-[0_16px_40px_rgba(0,0,0,0.7)] group">
            <Image
              src={EDITORIAL.image}
              alt="Montage of Nepali cinema history"
              fill
              sizes="(min-width: 1024px) 40vw, 100vw"
              className="object-cover transition-transform duration-700 group-hover:scale-105"
            />
            <div className="absolute inset-0 bg-gradient-to-t from-surface via-transparent to-transparent" />
            <div className="absolute bottom-3 left-4 right-4 flex items-center justify-between gap-2">
              <div className="flex items-center gap-2">
                <span className="w-3 h-3 rounded-full bg-primary-container animate-pulse" />
                <span className="font-label-badge text-label-badge text-white uppercase tracking-wider font-bold">
                  Diaspora Hub Active
                </span>
              </div>
              <span className="hidden sm:block font-label-md text-label-md text-primary">
                {EDITORIAL.hubs}
              </span>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
