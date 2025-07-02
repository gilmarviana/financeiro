# Sistema Financeiro com Supabase

Sistema completo de gestão financeira pessoal desenvolvido para Supabase (PostgreSQL) com todas as funcionalidades solicitadas.

## 📋 Funcionalidades Principais

### 🏦 Gestão de Contas
- **Múltiplos tipos de conta**: Corrente, Poupança, Cartão de Crédito, Dinheiro, Investimentos, Carteiras Digitais
- **Controle de saldo automático**: Atualização em tempo real através de triggers
- **Configurações específicas**: Limites de crédito, dias de fechamento/vencimento para cartões

### 💰 Sistema de Pagamentos
- **3 Tipos distintos de pagamento**:
  - **Normal**: Pagamentos únicos e variáveis (compras do dia a dia)
  - **Fixo**: Pagamentos com valor fixo em datas específicas (impostos anuais)
  - **Recorrente**: Pagamentos automáticos que se repetem (aluguel, mensalidades)

### 📊 Categorização Inteligente
- **Categorias pré-definidas**: Moradia, Alimentação, Transporte, Saúde, etc.
- **Subcategorias**: Hierarquia de categorias para melhor organização
- **Categorias personalizadas**: Usuários podem criar suas próprias categorias
- **Cores e ícones**: Identificação visual das categorias

### 📅 Pagamentos Recorrentes Avançados
- **Múltiplas frequências**: Diária, semanal, mensal, anual
- **Configurações flexíveis**: Dia fixo do mês, dia da semana específico
- **Controle de duração**: Data de início/fim, número máximo de ocorrências
- **Geração automática**: Função para criar pagamentos futuros automaticamente

### 🎯 Sistema de Orçamentos
- **Orçamentos por categoria**: Controle de gastos por área
- **Períodos flexíveis**: Mensal, semanal, anual
- **Alertas automáticos**: Notificação quando atingir % do orçamento
- **Acompanhamento visual**: Comparação realizado vs planejado

### 🔔 Notificações e Alertas
- **Lembretes de vencimento**: X dias antes do vencimento
- **Alertas de atraso**: Pagamentos não realizados na data
- **Alertas de orçamento**: Quando ultrapassar limite definido
- **Saldo baixo**: Quando conta atingir valor mínimo
- **Configurações personalizáveis**: Ativar/desativar por tipo

### 📈 Relatórios e Análises
- **Dashboard completo**: Visão geral das finanças
- **Gastos por categoria**: Análise detalhada de onde vai o dinheiro
- **Comparativos temporais**: Mês atual vs anterior, ano vs ano
- **Projeções futuras**: Baseado em pagamentos recorrentes
- **Fluxo de caixa**: Previsão de entradas e saídas

### 🎯 Metas Financeiras
- **Objetivos de economia**: Definir metas de valor e prazo
- **Acompanhamento de progresso**: Quanto já foi economizado
- **Vinculação com contas**: Onde o dinheiro será guardado

### 📎 Anexos e Comprovantes
- **Upload de arquivos**: Comprovantes de pagamento
- **Integração com Storage**: Usando Supabase Storage
- **Metadados**: Descrição, tipo, tamanho do arquivo

## 🗃️ Estrutura das Tabelas

### Tabelas Principais
1. **`users`** - Perfis dos usuários (conecta com Supabase Auth)
2. **`accounts`** - Contas bancárias e carteiras do usuário
3. **`categories`** - Categorias de receitas e despesas
4. **`payments`** - Transações/pagamentos principais
5. **`recurring_payments`** - Configurações de pagamentos recorrentes
6. **`budgets`** - Orçamentos por categoria
7. **`notifications`** - Sistema de notificações
8. **`financial_goals`** - Metas financeiras

### Tabelas de Apoio
- **`account_types`** - Tipos de conta disponíveis
- **`payment_types`** - Tipos de pagamento (Normal, Fixo, Recorrente)
- **`payment_status`** - Status dos pagamentos (Pendente, Pago, Atrasado, etc.)
- **`notification_settings`** - Configurações de notificação por usuário
- **`payment_attachments`** - Anexos dos pagamentos

## 🔒 Segurança

### Row Level Security (RLS)
- **Isolamento por usuário**: Cada usuário só acessa seus próprios dados
- **Políticas granulares**: Controle de SELECT, INSERT, UPDATE, DELETE
- **Integração com Supabase Auth**: Usando `auth.uid()` para identificação

### Triggers Automáticos
- **Atualização de saldos**: Quando pagamentos são inseridos/editados
- **Updated_at automático**: Timestamp de última modificação
- **Validações**: Controles de integridade dos dados

## 📊 Views e Funções Úteis

### Views Pré-criadas
- **`v_upcoming_payments`** - Próximos pagamentos (para dashboard)
- **`v_user_total_balance`** - Saldo total por usuário
- **`v_monthly_expenses`** - Gastos mensais por categoria

### Funções Especiais
- **`generate_recurring_payments()`** - Gera pagamentos recorrentes automaticamente
- **`get_expenses_by_category()`** - Relatório de gastos por categoria
- **`update_account_balance()`** - Atualiza saldos automaticamente

## 🚀 Como Usar

### 1. Configuração Inicial no Supabase

```sql
-- Execute o arquivo supabase_financial_system.sql
-- no SQL Editor do seu projeto Supabase
```

### 2. Configurar Storage (para anexos)

```sql
-- No Supabase Storage, crie um bucket chamado 'payment-attachments'
-- Configure as políticas de acesso conforme necessário
```

### 3. Configurar Cron Job (Edge Functions)

```javascript
// Para executar generate_recurring_payments() automaticamente
// Configure uma Edge Function que rode diariamente
```

## 📱 Exemplos de Queries Úteis

### Dashboard - Resumo Financeiro
```sql
-- Saldo total do usuário
SELECT * FROM v_user_total_balance WHERE user_id = auth.uid();

-- Próximos 5 pagamentos
SELECT * FROM v_upcoming_payments 
WHERE user_id = auth.uid() 
LIMIT 5;

-- Gastos do mês atual
SELECT 
    SUM(amount) as total_expenses,
    COUNT(*) as total_transactions
FROM payments 
WHERE user_id = auth.uid() 
    AND type = 'expense'
    AND EXTRACT(MONTH FROM payment_date) = EXTRACT(MONTH FROM CURRENT_DATE)
    AND EXTRACT(YEAR FROM payment_date) = EXTRACT(YEAR FROM CURRENT_DATE);
```

### Relatórios de Gastos
```sql
-- Gastos por categoria no mês atual
SELECT * FROM get_expenses_by_category(
    auth.uid(),
    DATE_TRUNC('month', CURRENT_DATE)::DATE,
    (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month - 1 day')::DATE
);

-- Comparação mensal (este mês vs mês anterior)
WITH current_month AS (
    SELECT SUM(amount) as current_total
    FROM payments 
    WHERE user_id = auth.uid() 
        AND type = 'expense'
        AND payment_date >= DATE_TRUNC('month', CURRENT_DATE)
),
previous_month AS (
    SELECT SUM(amount) as previous_total
    FROM payments 
    WHERE user_id = auth.uid() 
        AND type = 'expense'
        AND payment_date >= DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '1 month'
        AND payment_date < DATE_TRUNC('month', CURRENT_DATE)
)
SELECT 
    c.current_total,
    p.previous_total,
    ((c.current_total - p.previous_total) / p.previous_total * 100) as percentage_change
FROM current_month c, previous_month p;
```

### Controle de Orçamento
```sql
-- Status do orçamento por categoria
SELECT 
    b.name as budget_name,
    c.name as category_name,
    b.amount as budget_amount,
    COALESCE(SUM(p.amount), 0) as spent_amount,
    (COALESCE(SUM(p.amount), 0) / b.amount * 100) as percentage_used,
    (b.amount - COALESCE(SUM(p.amount), 0)) as remaining_amount
FROM budgets b
JOIN categories c ON b.category_id = c.id
LEFT JOIN payments p ON c.id = p.category_id 
    AND p.user_id = b.user_id
    AND p.type = 'expense'
    AND p.payment_date BETWEEN b.start_date AND b.end_date
WHERE b.user_id = auth.uid()
    AND b.is_active = true
    AND CURRENT_DATE BETWEEN b.start_date AND b.end_date
GROUP BY b.id, b.name, c.name, b.amount;
```

## 🔧 Manutenção e Otimização

### Índices Criados
- Índices em todas as chaves estrangeiras
- Índices em campos de data para queries rápidas
- Índices compostos para consultas complexas

### Limpeza de Dados
```sql
-- Limpar notificações antigas (mais de 6 meses)
DELETE FROM notifications 
WHERE created_at < CURRENT_DATE - INTERVAL '6 months'
    AND is_read = true;

-- Arquivar pagamentos muito antigos (opcional)
-- Criar tabela payments_archive e mover dados antigos
```

### Backup e Restore
```sql
-- Use as ferramentas nativas do Supabase/PostgreSQL
-- Configure backups automáticos no painel do Supabase
```

## 🔮 Próximos Passos Recomendados

1. **Frontend Development**
   - Interface React/Next.js com componentes para cada funcionalidade
   - Gráficos interativos (Chart.js, Recharts)
   - Dashboard responsivo

2. **Integrações Externas**
   - Open Banking para importação automática
   - APIs de bancos brasileiros
   - Sincronização com cartões de crédito

3. **Funcionalidades Avançadas**
   - Machine Learning para categorização automática
   - Previsões baseadas em histórico
   - Sugestões de economia

4. **Mobile App**
   - React Native ou Flutter
   - Notificações push nativas
   - Scanner de QR codes para pagamentos

5. **Relatórios Avançados**
   - PDF export
   - Planilhas Excel personalizadas
   - Gráficos de tendências

## 📞 Suporte

Para dúvidas ou problemas:
- Verifique a documentação do Supabase
- Teste as queries no SQL Editor
- Monitore os logs de erro
- Use as ferramentas de debug do PostgreSQL

---

**Sistema desenvolvido para Supabase com PostgreSQL 15+**
**Compatível com Row Level Security (RLS) e Supabase Auth**