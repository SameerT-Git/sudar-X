import EditorialBanner from "@/components/home/EditorialBanner";
import FaqSection from "@/components/home/FaqSection";
import FinalCta from "@/components/home/FinalCta";
import HeroSection from "@/components/home/HeroSection";
import NepalSpotlight from "@/components/home/NepalSpotlight";
import OriginalSeries from "@/components/home/OriginalSeries";
import SubscriptionPlans from "@/components/home/SubscriptionPlans";
import TrendingInNepal from "@/components/home/TrendingInNepal";
import ValuePillars from "@/components/home/ValuePillars";
import { VideoPlayerProvider } from "@/components/home/VideoPlayer";

export default function Page() {
  return (
    <VideoPlayerProvider>
      <div className="flex flex-col w-full text-on-surface select-none">
        <HeroSection />

        <div className="w-full flex flex-col gap-space-xl py-space-xl px-margin-mobile lg:px-margin">
          <TrendingInNepal />
          <NepalSpotlight />
          <OriginalSeries />
          <EditorialBanner />
          <ValuePillars />
          <SubscriptionPlans />
          <FaqSection />
          <FinalCta />
        </div>
      </div>
    </VideoPlayerProvider>
  );
}
