export default function AuthBackground() {
  return (
    <div className="fixed inset-0 pointer-events-none z-0 overflow-hidden">
      {/* Red glow */}
      <div className="absolute -top-40 left-1/2 -translate-x-1/2 w-[46rem] h-[28rem] bg-[#dc143c]/12 rounded-full blur-[140px]" />

      {/* Blue glow */}
      <div className="absolute top-1/2 -right-40 w-[32rem] h-[30rem] bg-[#16439e]/12 rounded-full blur-[160px]" />

      {/* Dark bottom glow */}
      <div className="absolute -bottom-32 left-1/4 w-[36rem] h-[24rem] bg-[#0a1420]/80 rounded-full blur-[110px]" />

      {/* Dark radial overlay */}
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_center,transparent_35%,#050f1a_100%)] opacity-95" />
    </div>
  );
}