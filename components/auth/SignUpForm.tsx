"use client";

import { useState } from "react";
import Link from "next/link";
import { Eye, EyeOff } from "lucide-react";

function getPasswordStrength(password: string) {
  if (!password) {
    return { score: 0, label: "Password strength", labelClass: "text-on-surface-variant/70" };
  }

  let score = 0;
  if (password.length >= 8) score++;
  if (/[A-Z]/.test(password) && /[a-z]/.test(password)) score++;
  if (/[0-9]/.test(password)) score++;
  if (/[^A-Za-z0-9]/.test(password)) score++;

  if (score <= 1) return { score: 1, label: "Weak", labelClass: "text-red-400 font-medium" };
  if (score === 2) return { score: 2, label: "Fair", labelClass: "text-amber-300 font-medium" };
  if (score === 3) return { score: 3, label: "Good", labelClass: "text-blue-300 font-medium" };
  return { score: 4, label: "Strong & Secure", labelClass: "text-[#ffb3b3] font-medium" };
}

export default function SignUpForm() {
  const [showPassword, setShowPassword] = useState(false);
  const [password, setPassword] = useState("");
  const [facebookLogoError, setFacebookLogoError] = useState(false);

  const strength = getPasswordStrength(password);

  function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    // TODO: connect sign-up
  }

  const barActiveClass = (index: number) => {
    if (strength.score <= 0) return "bg-surface-container-high";
    if (strength.score === 1) return index === 0 ? "bg-red-400" : "bg-surface-container-high";
    if (strength.score === 2) return index < 2 ? "bg-amber-300" : "bg-surface-container-high";
    if (strength.score === 3) return index < 3 ? "bg-blue-300" : "bg-surface-container-high";
    return "bg-primary-container";
  };

  return (
    <div className="w-full max-w-lg mx-auto relative z-10 my-2 sm:my-4">
      <div className="w-full bg-surface-container/75 backdrop-blur-2xl rounded-2xl p-6 sm:p-8 md:p-9 shadow-2xl shadow-surface-container-lowest/80 border border-surface-container-highest/60 relative overflow-hidden">
        <div className="absolute top-0 left-0 right-0 h-[2px] bg-gradient-to-r from-transparent via-primary-container to-transparent" />

        <div className="mb-6 text-center">
          <h1 className="text-2xl sm:text-3xl font-extrabold text-on-surface tracking-tight font-headline-lg">
            Create Your SudarX Account
          </h1>
          <p className="mt-2 text-xs sm:text-sm text-on-surface-variant/80 font-body-md">
            Join SudarX and enjoy Nepali entertainment in one place
          </p>
        </div>

        <form className="space-y-4" onSubmit={handleSubmit}>
          <div className="flex flex-col gap-1.5 text-left">
            <label className="font-label-md text-label-md text-on-surface font-medium" htmlFor="name">
              Full Name
            </label>
            <input
              className="w-full h-11 px-3.5 rounded-lg bg-surface-container-lowest/80 text-on-surface placeholder:text-on-surface-variant/40 font-body-md text-body-md border border-surface-container-highest/60 transition-all duration-200 focus:outline-none focus:border-primary-container focus:ring-1 focus:ring-primary-container"
              id="name"
              name="name"
              placeholder="e.g. Aayush Shrestha"
              required
              type="text"
              autoComplete="name"
            />
          </div>

          <div className="flex flex-col gap-1.5 text-left">
            <label className="font-label-md text-label-md text-on-surface font-medium" htmlFor="email">
              Email Address
            </label>
            <input
              className="w-full h-11 px-3.5 rounded-lg bg-surface-container-lowest/80 text-on-surface placeholder:text-on-surface-variant/40 font-body-md text-body-md border border-surface-container-highest/60 transition-all duration-200 focus:outline-none focus:border-primary-container focus:ring-1 focus:ring-primary-container"
              id="email"
              name="email"
              placeholder="you@domain.com"
              required
              type="email"
              autoComplete="email"
            />
          </div>

          <div className="flex flex-col gap-1.5 text-left">
            <label className="font-label-md text-label-md text-on-surface font-medium" htmlFor="phone">
              Mobile Number
            </label>
            <div className="flex items-center gap-2.5 w-full">
              <div className="h-11 px-3 flex-shrink-0 flex items-center gap-1.5 rounded-lg bg-surface-container-high/80 border border-surface-container-highest/60 text-secondary font-label-md text-xs sm:text-sm select-none">
                <span>🇳🇵</span>
                <span className="font-semibold text-on-surface">+977</span>
              </div>
              <input
                className="w-full h-11 px-3.5 rounded-lg bg-surface-container-lowest/80 text-on-surface placeholder:text-on-surface-variant/40 font-body-md text-body-md border border-surface-container-highest/60 transition-all duration-200 focus:outline-none focus:border-primary-container focus:ring-1 focus:ring-primary-container"
                id="phone"
                name="phone"
                pattern="[0-9]{10}"
                placeholder="98XXXXXXXX"
                type="tel"
                autoComplete="tel-national"
              />
            </div>
          </div>

          <div className="flex flex-col gap-1.5 text-left">
            <label className="font-label-md text-label-md text-on-surface font-medium" htmlFor="password">
              Create Password
            </label>
            <div className="relative flex items-center">
              <input
                className="w-full h-11 pl-3.5 pr-11 rounded-lg bg-surface-container-lowest/80 text-on-surface placeholder:text-on-surface-variant/40 font-body-md text-body-md border border-surface-container-highest/60 transition-all duration-200 focus:outline-none focus:border-primary-container focus:ring-1 focus:ring-primary-container"
                id="password"
                name="password"
                placeholder="••••••••••••"
                required
                type={showPassword ? "text" : "password"}
                autoComplete="new-password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
              />
              <button
                aria-label={showPassword ? "Hide password" : "Show password"}
                className="absolute right-2 h-8 w-8 flex items-center justify-center text-on-surface-variant hover:text-on-surface transition-colors cursor-pointer"
                type="button"
                onClick={() => setShowPassword((v) => !v)}
              >
                {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
              </button>
            </div>

            <div className="mt-1 flex flex-col gap-1.5">
              <div className="grid grid-cols-4 gap-1.5 h-1 w-full">
                {[0, 1, 2, 3].map((i) => (
                  <div key={i} className={`h-full rounded-full transition-colors ${barActiveClass(i)}`} />
                ))}
              </div>
              <div className="flex items-center justify-between text-[11px] font-body-sm">
                <span className={strength.labelClass}>{strength.label}</span>
                <span className="text-on-surface-variant/70">Min. 8 characters</span>
              </div>
            </div>
          </div>

          <div className="pt-1 pb-1 flex items-start gap-2.5 text-left select-none">
            <input
              className="mt-0.5 w-4 h-4 rounded bg-surface-container-lowest border-surface-container-highest text-primary-container focus:ring-primary-container cursor-pointer"
              id="terms-agree"
              name="terms"
              required
              type="checkbox"
            />
            <label
              className="font-body-sm text-body-sm text-on-surface-variant/90 leading-snug cursor-pointer"
              htmlFor="terms-agree"
            >
              I agree to SudarX{" "}
              <Link className="text-secondary hover:text-primary transition-colors underline underline-offset-2" href="#">
                Terms of Use
              </Link>{" "}
              and{" "}
              <Link className="text-secondary hover:text-primary transition-colors underline underline-offset-2" href="#">
                Privacy Policy
              </Link>
              .
            </label>
          </div>

          <button
            className="relative w-full h-12 flex cursor-pointer items-center justify-center gap-2 rounded-lg bg-gradient-to-r from-primary-container via-[#e61943] to-primary-container text-white font-label-lg text-label-lg font-bold shadow-lg shadow-primary-container/35 hover:shadow-primary-container/50 hover:brightness-110 active:scale-[0.99] transition-all duration-200 mt-2"
            type="submit"
          >
            <span>Create Account &amp; Start Watching</span>
          </button>
        </form>

        <div className="my-5">
          <div className="relative flex items-center justify-center">
            <div className="absolute inset-0 flex items-center">
              <div className="w-full h-[1px] bg-surface-container-highest/70" />
            </div>
            <div className="relative px-3 bg-surface-container text-on-surface-variant/70 font-label-md text-xs uppercase tracking-wider select-none">
              or sign up with
            </div>
          </div>
          <div className="mt-4 grid grid-cols-2 gap-3">
            <button
              className="group relative w-full h-11 py-2.5 px-3 flex cursor-pointer items-center justify-center gap-2 rounded-lg bg-surface-container-lowest/80 hover:bg-surface-container-high/80 text-on-surface text-xs sm:text-sm font-medium transition-all duration-200 border border-surface-container-highest/60 hover:border-outline-variant/60 active:scale-[0.99] shadow-sm"
              type="button"
              aria-label="Sign up with Google"
            >
              <img
                src="https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg"
                alt=""
                aria-hidden="true"
                className="w-4 h-4 flex-shrink-0"
              />
              <span className="group-hover:text-primary transition-colors font-medium">Google</span>
            </button>
            <button
              className="group relative w-full h-11 py-2.5 px-3 flex cursor-pointer items-center justify-center gap-2 rounded-lg bg-surface-container-lowest/80 hover:bg-surface-container-high/80 text-on-surface text-xs sm:text-sm font-medium transition-all duration-200 border border-surface-container-highest/60 hover:border-outline-variant/60 active:scale-[0.99] shadow-sm"
              type="button"
              aria-label="Sign up with Facebook"
            >
              {facebookLogoError ? (
                <svg aria-hidden="true" className="w-4 h-4 flex-shrink-0" viewBox="0 0 24 24" fill="#1877F2">
                  <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z" />
                </svg>
              ) : (
                <img
                  src="https://upload.wikimedia.org/wikipedia/commons/thumb/b/b9/2023_Facebook_icon.svg/96px-2023_Facebook_icon.svg.png"
                  alt=""
                  aria-hidden="true"
                  className="w-4 h-4 flex-shrink-0"
                  onError={() => setFacebookLogoError(true)}
                />
              )}
              <span className="group-hover:text-primary transition-colors font-medium">Facebook</span>
            </button>
          </div>
        </div>

        <div className="pt-2 text-center border-t border-surface-container-highest/50">
          <p className="font-body-md text-sm text-on-surface-variant/80">
            Already have an account?{" "}
            <Link className="text-secondary font-semibold hover:text-primary hover:underline transition-colors ml-1" href="/Sign-In">
              Sign in
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}
