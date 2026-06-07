# Apresentação — NutriGym

Os slides estão em [`NutriGym-apresentacao.md`](NutriGym-apresentacao.md), no formato **Marp**
(Markdown → slides). As telas estão representadas por *mockups* fiéis (header verde,
cards verdes, etc.); você pode trocá-los por prints reais quando o app rodar.

## Como visualizar / exportar (VSCode — recomendado)

1. Instale a extensão **"Marp for VS Code"** (Marketplace).
2. Abra `NutriGym-apresentacao.md`.
3. Clique no ícone de **preview** (canto superior direito) para ver os slides.
4. Para exportar: paleta de comandos (**Ctrl+Shift+P**) →
   **"Marp: Export Slide Deck..."** → escolha **PDF**, **PPTX** ou **HTML**.

## Alternativa (linha de comando, se tiver Node)

```bash
npx @marp-team/marp-cli@latest NutriGym-apresentacao.md --pdf
npx @marp-team/marp-cli@latest NutriGym-apresentacao.md --pptx
```

## Trocar mockups por prints reais

Quando o app estiver rodando, tire os prints das telas, salve-os nesta pasta
(ex.: `prints/login.png`) e substitua os blocos `<div class="phone">...</div>`
por `![w:290](prints/login.png)` no markdown.
