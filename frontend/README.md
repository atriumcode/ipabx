# PBX Moderno Enterprise - Frontend

Interface moderna em React para gerenciamento do sistema PBX.

## Tecnologias

- React 18
- TypeScript
- Vite
- TailwindCSS
- React Router
- Zustand (Estado global)
- Axios (HTTP Client)
- Lucide React (Ícones)

## Instalação

\`\`\`bash
# Instalar dependências
npm install

# Iniciar servidor de desenvolvimento
npm run dev

# Build para produção
npm run build

# Visualizar build de produção
npm run preview
\`\`\`

## Estrutura

\`\`\`
src/
├── components/      # Componentes reutilizáveis
│   └── ui/         # Componentes de interface
├── layouts/        # Layouts da aplicação
├── pages/          # Páginas da aplicação
├── stores/         # Estado global (Zustand)
├── lib/            # Utilitários e API
├── App.tsx         # Componente principal
└── main.tsx        # Entry point
\`\`\`

## Funcionalidades

- Dashboard com estatísticas em tempo real
- Gerenciamento de Ramais (PJSIP/SIP)
- Gerenciamento de Troncos
- Filas de Atendimento
- Grupos de Chamada
- URA (IVR)
- Rotas de Entrada/Saída
- CDR (Registros de Chamadas)
- Gravações
- Gerenciamento de Usuários
- Configurações do Sistema

## Temas

O sistema suporta tema claro e escuro através de classes CSS personalizadas.

## API

O frontend se comunica com o backend através da API REST em `/api`.
A autenticação é feita via JWT tokens armazenados no localStorage.
