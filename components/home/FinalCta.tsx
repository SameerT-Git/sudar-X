export default function FinalCta() {
  return (
    <section className="my-space-lg relative rounded-2xl overflow-hidden bg-primary-container text-on-primary-container p-space-xl flex flex-col md:flex-row items-center justify-between gap-space-lg shadow-[0_8px_32px_rgba(220,20,60,0.4)]">
      <div className="flex flex-col gap-space-xs max-w-xl">
        <h2 className="font-headline-lg-mobile md:text-headline-lg font-headline-lg font-extrabold text-white">
          Ready to experience the best Nepali stories?
        </h2>
        <p className="font-body-lg text-body-lg text-white/90">
          Join thousands of cinema lovers today. Start your 7-day free trial on
          SudarX.
        </p>
      </div>
      <div className="flex items-center gap-space-md flex-none">
        <button
          type="button"
          className="px-space-xl py-space-sm bg-white text-on-primary font-label-lg text-label-lg font-bold rounded-full hover:bg-primary-fixed shadow-lg hover:shadow-xl transition-all transform active:scale-95"
        >
          Get Started Now
        </button>
      </div>
    </section>
  );
}
