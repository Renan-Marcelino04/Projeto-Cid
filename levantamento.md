# Levantamento de Dados — CK Autoshop

**Disciplina:** Modelagem de Banco de Dados — Entrega 2
**Documento de apoio ao [README.md](README.md)**

> Tudo o que está nas seções 4 a 7 é **informação relatada pelo proprietário** na entrevista. O texto não inclui nada além do que foi relatado.

---

## 1. Identificação da organização

| Campo | Informação |
|---|---|
| Organização | CK Autoshop |
| Segmento | Peças e componentes automotivos |
| Modelo de atuação | Predominantemente B2B: locadoras, frotistas, oficinas, seguradoras e outras organizações que administram frotas |
| Endereço | Rua José Pereira Cardoso, 65 — São Miguel Paulista, São Paulo — SP, CEP 08011-310 |
| Telefone institucional | (11) 2033-7364 |
| Site oficial | <https://ckautoshop.com/front-pages/landing-page> |
| Instagram | <https://www.instagram.com/ck.autoshop/> |

**Porte (estimativas):** 11 funcionários; cerca de 90 pedidos por mês; cerca de 100 clientes.

## 2. Objetivo do levantamento

Entender como a CK Autoshop funciona no dia a dia — processos, participantes, informações registradas e dificuldades — para sustentar o levantamento de requisitos e a modelagem do banco de dados.

## 3. Dados da entrevista

| Campo | Informação |
|---|---|
| Entrevistado | Enrique Cintra, proprietário |
| Entrevistador | Leandro Marques Coelho |
| Data e horário | 09/09/2026, às 17h30 |
| Modalidade e local | Presencial, nas dependências da CK Autoshop |

As 23 perguntas e respostas estão na [seção 1.3 do README](README.md#13-perguntas-e-respostas-da-entrevista).

## 4. Processos relatados

### 4.1 Cadastro de peças
Código, descrição, fabricante ou marca, aplicação, fornecedor, custo e valor de venda.

### 4.2 Compras e fornecedores
A compra é feita junto a fornecedores e normalmente atende à necessidade de um pedido. No modelo de dados, os dados de compra e recebimento ficam no item do pedido.

### 4.3 Estoque
As peças são recebidas e conferidas antes da entrada no estoque. O controle por entradas e saídas acompanha quantidades, origem, destino e histórico.

### 4.4 Cotações e vendas
O processo começa com a solicitação do cliente. A equipe pesquisa as peças e elabora a cotação com dados do cliente e do veículo, peças, quantidades, custos, margens, valores de venda e descontos. Status: pendente, enviada, aprovada ou reprovada, e cancelada. A aprovação dá continuidade ao pedido.

### 4.5 Expedição e transporte
Separação, conferência, embalagem, despacho, transporte e entrega. Embalagem com plástico-bolha, fitas, papelão e isopor, conforme a peça.

### 4.6 Financeiro e faturamento
Notas fiscais, valores, descontos, vencimentos, pagamentos e situação financeira.

### 4.7 Devoluções e garantias
Processos específicos para ocorrências, devoluções e garantias, separados das vendas comuns.

### 4.8 Sistemas e controles
Sistema próprio de gestão para cotações, compras, fornecedores, clientes, estoque, pedidos, notas fiscais, financeiro, devoluções e garantias. Também são mencionados planilhas, PDFs e WhatsApp.

## 5. Ciclo operacional

O cliente empresarial solicita peças → a equipe monta a cotação → aprovada, vira pedido → as peças são adquiridas, recebidas e conferidas → entram no estoque → o pedido é separado, embalado e despachado → faturamento por nota fiscal e acompanhamento financeiro → pós-venda (devoluções e garantias).

## 6. Problemas identificados

O principal desafio é a **integração e rastreabilidade das informações** ao longo do ciclo.

| Código | Problema |
|---|---|
| P1 | Dificuldade de acompanhar o status dos pedidos |
| P2 | Atrasos de fornecedores e pedidos aguardando peças |
| P3 | Falta de visibilidade sobre prazos |
| P4 | Controle da margem real das vendas |
| P5 | Rastreio da operação de ponta a ponta |
| P6 | Informações espalhadas entre sistema, planilhas, PDFs e WhatsApp |
| P7 | Controle de devoluções e garantias |
| P8 | Integração e comunicação entre os setores |
| P9 | Rastreabilidade de documentos |
| P10 | Indicadores para acompanhar a operação |
| P11 | Acompanhamento financeiro |

A matriz completa está na seção 3.2 do README.

## 7. Evidências

| Evidência | Descrição |
|---|---|
| Site oficial | <https://ckautoshop.com/front-pages/landing-page> |
| Instagram | <https://www.instagram.com/ck.autoshop/> |
| Logotipo | `logo-ck-autoshop.png` |
