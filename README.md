# Batalhas de Rima

Plataforma editorial e arquivo vivo da cultura freestyle brasileira.

## Stack
- Astro + TypeScript
- Cloudflare Workers (Astro Cloudflare adapter)
- Supabase (PostgreSQL, Auth e Storage)
- React islands para interações pontuais
- Tailwind CSS 4

## Requisitos
Node.js 22+, npm e contas Cloudflare/Supabase.

## Instalação
```bash
npm install
cp .env.example .env
npm run dev
```

## Supabase
Crie um projeto em https://database.new, configure as variáveis do ambiente e aplique as migrations:

```bash
npx supabase login
npx supabase link --project-ref SEU_PROJECT_REF
npx supabase db push
```

## Comandos
```bash
npm run dev
npm run check
npm run build
npm run preview
npm run deploy
```

## Ambiente
- `PUBLIC_SUPABASE_URL`
- `PUBLIC_SUPABASE_PUBLISHABLE_KEY`
- `SUPABASE_SECRET_KEY` (somente servidor; nunca expor no browser)

## Renderização
Astro usa `output: "server"` com Cloudflare adapter. Páginas editoriais que possam ser geradas no build podem optar por `export const prerender = true`. Páginas dependentes de hostname ou dados dinâmicos permanecem SSR.

## Segurança
RLS deve permanecer habilitada em todas as tabelas expostas. Acesso público somente de leitura para registros publicados. Não criar políticas públicas de escrita nem expor chaves secretas.

## Cloudflare
Configure o deploy com o adapter oficial: https://docs.astro.build/en/guides/integrations-guide/cloudflare/
