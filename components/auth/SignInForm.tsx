"use client";

import { useState } from "react";
import Link from "next/link";
import { Eye, EyeOff } from "lucide-react";

export default function SignInForm() {
  const [showPassword, setShowPassword] = useState(false);
  const [facebookLogoError, setFacebookLogoError] = useState(false);

  function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    // TODO: connect auth
  }

  return (
    <div className="w-full max-w-md rounded-2xl border border-[#223042] bg-[#0e1724]/90 p-6 shadow-2xl backdrop-blur-2xl sm:p-9">
      <div className="mb-6 text-center">
        <h1 className="text-2xl font-extrabold text-white sm:text-3xl">Sign In</h1>
        <p className="mt-2 text-sm text-slate-400">
          Enter your credentials to access your account
        </p>
      </div>

      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label htmlFor="identifier" className="mb-1 block text-sm font-semibold text-slate-200">
            Email or Mobile Number
          </label>
          <input
            id="identifier"
            name="identifier"
            type="text"
            placeholder="name@example.com or 98XXXXXXXX"
            required
            className="w-full rounded-xl border border-[#223042] bg-[#06101c]/90 px-4 py-3 text-white placeholder:text-slate-500 focus:border-[#dc143c] focus:outline-none focus:ring-2 focus:ring-[#dc143c]/30"
          />
        </div>

        <div>
          <div className="mb-1 flex items-center justify-between">
            <label htmlFor="password" className="text-sm font-semibold text-slate-200">
              Password
            </label>
            <Link href="/forgot-password" className="text-sm text-slate-300 hover:text-white">
              Forgot Password?
            </Link>
          </div>
          <div className="relative">
            <input
              id="password"
              name="password"
              type={showPassword ? "text" : "password"}
              placeholder="••••••••"
              required
              className="w-full rounded-xl border border-[#223042] bg-[#06101c]/90 px-4 py-3 pr-11 text-white placeholder:text-slate-500 focus:border-[#dc143c] focus:outline-none focus:ring-2 focus:ring-[#dc143c]/30"
            />
            <button
              type="button"
              onClick={() => setShowPassword((v) => !v)}
              aria-label={showPassword ? "Hide password" : "Show password"}
              className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-white"
            >
              {showPassword ? <EyeOff size={20} /> : <Eye size={20} />}
            </button>
          </div>
        </div>

        <label htmlFor="remember" className="flex items-center gap-2 text-sm text-slate-400">
          <input id="remember" name="remember" type="checkbox" className="h-4 w-4 accent-[#dc143c]" />
          Remember me
        </label>

        <button
          type="submit"
          className="w-full cursor-pointer rounded-xl bg-gradient-to-r from-[#dc143c] to-[#b30f30] py-3 font-semibold text-white hover:brightness-110"
        >
          Sign In
        </button>
      </form>

      <div className="my-6 border-t border-[#223042]" />

      <div className="grid grid-cols-2 gap-3">
        <button
          type="button"
          aria-label="Sign in with Google"
          className="flex cursor-pointer items-center justify-center gap-2 rounded-xl border border-[#223042] bg-[#06101c]/80 py-2.5 text-sm text-slate-200 hover:bg-[#192535]"
        >
          <img
            src="https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg"
            alt=""
            aria-hidden="true"
            className="h-5 w-5"
          />
          <span>Google</span>
        </button>

        <button
          type="button"
          aria-label="Sign in with Facebook"
          className="flex cursor-pointer items-center justify-center gap-2 rounded-xl border border-[#223042] bg-[#06101c]/80 py-2.5 text-sm text-slate-200 hover:bg-[#192535]"
        >
          {facebookLogoError ? (
            <svg aria-hidden="true" className="h-5 w-5" viewBox="0 0 24 24" fill="#1877F2">
              <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z" />
            </svg>
          ) : (
            <img
              src="https://upload.wikimedia.org/wikipedia/commons/thumb/b/b9/2023_Facebook_icon.svg/96px-2023_Facebook_icon.svg.png"
              alt=""
              aria-hidden="true"
              className="h-5 w-5"
              onError={() => setFacebookLogoError(true)}
            />
          )}
          <span>Facebook</span>
        </button>
      </div>

      <p className="mt-6 text-center text-sm text-slate-400">
        New to SudarX?{" "}
        <Link href="/Sign-Up" className="font-semibold text-white hover:underline">
          Sign up now
        </Link>
      </p>
    </div>
  );
}