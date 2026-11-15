import { FEATURED_SWITCHER } from "@/data/landing";

export default function FeaturedSwitcher() {
  return (
    <div className="w-full bg-surface-container-low px-margin-mobile lg:px-margin py-space-md shadow-2xl">
      <div className="grid grid-cols-2 md:grid-cols-4 gap-space-md">
        {FEATURED_SWITCHER.map((item) => (
          <div
            key={item.id}
            className={`cursor-pointer group flex flex-col gap-1.5 p-space-xs rounded-lg transition-colors ${
              item.playing
                ? "bg-surface-container/40"
                : "hover:bg-surface-container/30"
            }`}
          >
            <div className="h-1 w-full bg-surface-container-highest rounded-full overflow-hidden">
              <div
                className={`h-full rounded-full ${
                  item.playing
                    ? "bg-primary-container w-3/4"
                    : "bg-transparent w-0"
                }`}
              />
            </div>
            <div className="flex items-center justify-between gap-2">
              <span
                className={`font-label-md text-label-md truncate transition-colors ${
                  item.playing
                    ? "text-white font-semibold group-hover:text-primary"
                    : "text-on-surface-variant group-hover:text-white"
                }`}
              >
                {item.title}
              </span>
              <span
                className={`flex-none font-label-badge text-label-badge ${
                  item.playing
                    ? "text-primary px-1.5 rounded bg-primary-container/20"
                    : item.note === "ORIGINAL"
                      ? "text-secondary"
                      : "text-on-surface-variant"
                }`}
              >
                {item.note}
              </span>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
