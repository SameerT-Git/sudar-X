import { CircleCheck, XCircle } from "lucide-react";

import { PAYMENT_METHODS, PLANS } from "@/data/landing";

export default function SubscriptionPlans() {
  return (
    <section className="flex flex-col gap-space-lg pt-space-lg">
      <div className="text-center max-w-2xl mx-auto flex flex-col gap-space-xs">
        <span className="font-label-badge text-label-badge text-primary uppercase tracking-widest font-bold">
          Fair &amp; Transparent
        </span>
        <h2 className="font-headline-lg-mobile md:text-headline-lg font-headline-lg text-white">
          Choose Your Streaming Plan
        </h2>
        <p className="font-body-md text-body-md text-on-surface-variant">
          Cancel anytime. Change plans whenever you want. No hidden fees.
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-space-lg max-w-5xl mx-auto w-full">
        {PLANS.map((plan) => (
          <div
            key={plan.id}
            className={`flex flex-col rounded-2xl p-space-lg relative ${
              plan.popular
                ? "bg-surface-container-high shadow-[0_0_32px_rgba(220,20,60,0.25)] transform md:-translate-y-3"
                : "bg-surface-container shadow-xl hover:bg-surface-container-high transition-colors"
            }`}
          >
            {plan.popular ? (
              <div className="absolute -top-3.5 left-1/2 -translate-x-1/2 px-3 py-1 rounded-full bg-primary-container text-white font-label-badge text-label-badge font-bold uppercase tracking-wider shadow-md">
                Most Popular
              </div>
            ) : null}

            <h3 className="font-headline-md text-headline-md text-white font-bold">
              {plan.name}
            </h3>
            <p className="font-body-sm text-body-sm text-on-surface-variant mb-space-md">
              {plan.tagline}
            </p>

            <div className="flex items-baseline gap-1 mb-space-lg">
              <span className="font-label-lg text-label-lg text-on-surface-variant">
                NPR
              </span>
              <span className="font-display-hero text-headline-lg text-white font-extrabold">
                {plan.price}
              </span>
              <span className="font-body-sm text-body-sm text-on-surface-variant">
                / month
              </span>
            </div>

            <ul className="flex flex-col gap-space-sm font-body-sm text-body-sm text-on-surface mb-space-xl flex-1">
              {plan.features.map((feature) => (
                <li
                  key={feature.label}
                  className={`flex items-center gap-2 ${
                    feature.included ? "" : "text-on-surface-variant/60"
                  }`}
                >
                  {feature.included ? (
                    <CircleCheck
                      aria-hidden="true"
                      size={18}
                      className="flex-none text-primary"
                    />
                  ) : (
                    <XCircle
                      aria-hidden="true"
                      size={18}
                      className="flex-none"
                    />
                  )}
                  <span className={feature.highlight ? "text-primary font-bold" : undefined}>
                    {feature.label}
                  </span>
                </li>
              ))}
            </ul>

            <button
              type="button"
              className={`w-full py-space-sm px-space-md rounded-full font-label-lg text-label-lg transition-all ${
                plan.popular
                  ? "bg-primary-container text-on-primary-container hover:brightness-110 font-bold shadow-[0_0_20px_rgba(220,20,60,0.5)]"
                  : "bg-surface-container-highest hover:bg-surface-variant text-white font-semibold"
              }`}
            >
              {plan.cta}
            </button>
          </div>
        ))}
      </div>

      <div className="flex flex-col items-center gap-space-xs mt-space-md">
        <span className="font-label-md text-label-md text-on-surface-variant">
          Supported Local &amp; International Payment Gateways
        </span>
        <div className="flex flex-wrap items-center justify-center gap-space-sm">
          {PAYMENT_METHODS.map((method) => (
            <span
              key={method}
              className="px-3 py-1.5 rounded-lg bg-surface-container text-white font-label-md text-label-md font-semibold"
            >
              {method}
            </span>
          ))}
        </div>
      </div>
    </section>
  );
}
