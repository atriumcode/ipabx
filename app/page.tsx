export default function Page() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900">
      <div className="mx-auto max-w-2xl px-4 text-center">
        <div className="mb-8 inline-flex rounded-full bg-blue-500/10 px-4 py-2">
          <span className="text-sm font-medium text-blue-400">PBX Enterprise System</span>
        </div>

        <h1 className="mb-6 text-5xl font-bold text-white">Sistema PBX Moderno</h1>

        <p className="mb-8 text-xl text-slate-300">
          Plataforma completa de gerenciamento de telefonia empresarial com suporte a múltiplos tenants, integração
          Asterisk PJSIP/SIP e interface moderna
        </p>

        <div className="mb-12 grid gap-4 sm:grid-cols-2">
          <div className="rounded-lg border border-slate-700 bg-slate-800/50 p-6 backdrop-blur">
            <div className="mb-3 text-3xl">📞</div>
            <h3 className="mb-2 font-semibold text-white">Ramais</h3>
            <p className="text-sm text-slate-400">Gerenciamento completo de ramais PJSIP e SIP</p>
          </div>

          <div className="rounded-lg border border-slate-700 bg-slate-800/50 p-6 backdrop-blur">
            <div className="mb-3 text-3xl">🌐</div>
            <h3 className="mb-2 font-semibold text-white">Troncos</h3>
            <p className="text-sm text-slate-400">Configuração de troncos SIP para operadoras</p>
          </div>

          <div className="rounded-lg border border-slate-700 bg-slate-800/50 p-6 backdrop-blur">
            <div className="mb-3 text-3xl">👥</div>
            <h3 className="mb-2 font-semibold text-white">Filas</h3>
            <p className="text-sm text-slate-400">Filas de atendimento com estratégias avançadas</p>
          </div>

          <div className="rounded-lg border border-slate-700 bg-slate-800/50 p-6 backdrop-blur">
            <div className="mb-3 text-3xl">📊</div>
            <h3 className="mb-2 font-semibold text-white">Dashboard</h3>
            <p className="text-sm text-slate-400">Estatísticas e monitoramento em tempo real</p>
          </div>
        </div>

        <div className="flex flex-col items-center gap-4 sm:flex-row sm:justify-center">
          <a
            href="/frontend/index.html"
            className="inline-flex items-center justify-center rounded-lg bg-blue-600 px-8 py-3 font-medium text-white transition-colors hover:bg-blue-700"
          >
            Acessar Sistema
          </a>
          <a
            href="https://github.com"
            className="inline-flex items-center justify-center rounded-lg border border-slate-600 bg-slate-800/50 px-8 py-3 font-medium text-white backdrop-blur transition-colors hover:bg-slate-700"
          >
            Ver Documentação
          </a>
        </div>

        <div className="mt-12 border-t border-slate-700 pt-8">
          <div className="grid gap-6 text-left sm:grid-cols-3">
            <div>
              <h4 className="mb-2 font-semibold text-white">Backend</h4>
              <p className="text-sm text-slate-400">NestJS + TypeORM + PostgreSQL</p>
            </div>
            <div>
              <h4 className="mb-2 font-semibold text-white">Frontend</h4>
              <p className="text-sm text-slate-400">React + TailwindCSS + Zustand</p>
            </div>
            <div>
              <h4 className="mb-2 font-semibold text-white">Telefonia</h4>
              <p className="text-sm text-slate-400">Asterisk 20+ (PJSIP/SIP)</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
