-- =====================================================
-- QUERIES DE EXEMPLO E FUNÇÕES ADICIONAIS
-- Sistema Financeiro - Supabase
-- =====================================================

-- =====================================================
-- QUERIES PARA DASHBOARD
-- =====================================================

-- 1. Resumo financeiro geral do usuário
SELECT 
    (SELECT SUM(current_balance) FROM accounts WHERE user_id = auth.uid() AND is_active = true) as saldo_total,
    (SELECT COUNT(*) FROM payments WHERE user_id = auth.uid() AND payment_date IS NULL AND due_date >= CURRENT_DATE) as contas_pendentes,
    (SELECT COUNT(*) FROM payments WHERE user_id = auth.uid() AND payment_date IS NULL AND due_date < CURRENT_DATE) as contas_atrasadas,
    (SELECT SUM(amount) FROM payments WHERE user_id = auth.uid() AND type = 'expense' AND EXTRACT(MONTH FROM payment_date) = EXTRACT(MONTH FROM CURRENT_DATE)) as gastos_mes_atual,
    (SELECT SUM(amount) FROM payments WHERE user_id = auth.uid() AND type = 'income' AND EXTRACT(MONTH FROM payment_date) = EXTRACT(MONTH FROM CURRENT_DATE)) as receitas_mes_atual;

-- 2. Próximos pagamentos (próximos 7 dias)
SELECT 
    p.description,
    p.amount,
    p.due_date,
    c.name as categoria,
    c.color as cor_categoria,
    a.name as conta,
    s.name as status,
    (p.due_date - CURRENT_DATE) as dias_restantes
FROM payments p
JOIN categories c ON p.category_id = c.id
JOIN accounts a ON p.account_id = a.id
JOIN payment_status s ON p.status_id = s.id
WHERE p.user_id = auth.uid()
    AND p.payment_date IS NULL
    AND p.due_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '7 days'
ORDER BY p.due_date ASC;

-- 3. Gastos por categoria (mês atual) com percentual
WITH gastos_categoria AS (
    SELECT 
        c.name as categoria,
        c.color as cor,
        COALESCE(SUM(p.amount), 0) as total_gasto,
        COUNT(p.id) as num_transacoes
    FROM categories c
    LEFT JOIN payments p ON c.id = p.category_id 
        AND p.user_id = auth.uid()
        AND p.type = 'expense'
        AND EXTRACT(MONTH FROM p.payment_date) = EXTRACT(MONTH FROM CURRENT_DATE)
        AND EXTRACT(YEAR FROM p.payment_date) = EXTRACT(YEAR FROM CURRENT_DATE)
    WHERE c.type = 'expense' 
        AND (c.user_id = auth.uid() OR c.is_system = true)
    GROUP BY c.id, c.name, c.color
),
total_gastos AS (
    SELECT SUM(total_gasto) as total
    FROM gastos_categoria
)
SELECT 
    gc.*,
    ROUND((gc.total_gasto / tg.total * 100), 2) as percentual
FROM gastos_categoria gc, total_gastos tg
WHERE gc.total_gasto > 0
ORDER BY gc.total_gasto DESC;

-- =====================================================
-- QUERIES PARA RELATÓRIOS
-- =====================================================

-- 4. Evolução mensal de gastos (últimos 12 meses)
SELECT 
    TO_CHAR(DATE_TRUNC('month', p.payment_date), 'YYYY-MM') as mes,
    TO_CHAR(DATE_TRUNC('month', p.payment_date), 'Mon/YY') as mes_formatado,
    SUM(CASE WHEN p.type = 'expense' THEN p.amount ELSE 0 END) as total_gastos,
    SUM(CASE WHEN p.type = 'income' THEN p.amount ELSE 0 END) as total_receitas,
    (SUM(CASE WHEN p.type = 'income' THEN p.amount ELSE 0 END) - SUM(CASE WHEN p.type = 'expense' THEN p.amount ELSE 0 END)) as saldo_mes
FROM payments p
WHERE p.user_id = auth.uid()
    AND p.payment_date >= CURRENT_DATE - INTERVAL '12 months'
    AND p.payment_date IS NOT NULL
GROUP BY DATE_TRUNC('month', p.payment_date)
ORDER BY DATE_TRUNC('month', p.payment_date) DESC;

-- 5. Top 10 maiores gastos do mês
SELECT 
    p.description,
    p.amount,
    p.payment_date,
    c.name as categoria,
    a.name as conta
FROM payments p
JOIN categories c ON p.category_id = c.id
JOIN accounts a ON p.account_id = a.id
WHERE p.user_id = auth.uid()
    AND p.type = 'expense'
    AND EXTRACT(MONTH FROM p.payment_date) = EXTRACT(MONTH FROM CURRENT_DATE)
    AND EXTRACT(YEAR FROM p.payment_date) = EXTRACT(YEAR FROM CURRENT_DATE)
ORDER BY p.amount DESC
LIMIT 10;

-- 6. Análise de orçamento (atual vs planejado)
SELECT 
    b.name as orcamento,
    c.name as categoria,
    b.amount as valor_orcado,
    COALESCE(SUM(p.amount), 0) as valor_gasto,
    (b.amount - COALESCE(SUM(p.amount), 0)) as valor_restante,
    ROUND((COALESCE(SUM(p.amount), 0) / b.amount * 100), 2) as percentual_usado,
    CASE 
        WHEN COALESCE(SUM(p.amount), 0) > b.amount THEN 'Estourado'
        WHEN COALESCE(SUM(p.amount), 0) / b.amount >= 0.8 THEN 'Atenção'
        ELSE 'Normal'
    END as status_orcamento
FROM budgets b
JOIN categories c ON b.category_id = c.id
LEFT JOIN payments p ON c.id = p.category_id 
    AND p.user_id = b.user_id
    AND p.type = 'expense'
    AND p.payment_date BETWEEN b.start_date AND b.end_date
WHERE b.user_id = auth.uid()
    AND b.is_active = true
    AND CURRENT_DATE BETWEEN b.start_date AND b.end_date
GROUP BY b.id, b.name, c.name, b.amount
ORDER BY percentual_usado DESC;

-- =====================================================
-- QUERIES PARA ANÁLISES AVANÇADAS
-- =====================================================

-- 7. Média de gastos por dia da semana
SELECT 
    TO_CHAR(p.payment_date, 'Day') as dia_semana,
    EXTRACT(DOW FROM p.payment_date) as dia_numero,
    ROUND(AVG(p.amount), 2) as media_gasto,
    COUNT(*) as num_transacoes
FROM payments p
WHERE p.user_id = auth.uid()
    AND p.type = 'expense'
    AND p.payment_date >= CURRENT_DATE - INTERVAL '3 months'
GROUP BY EXTRACT(DOW FROM p.payment_date), TO_CHAR(p.payment_date, 'Day')
ORDER BY dia_numero;

-- 8. Contas que mais impactam o orçamento
WITH impacto_contas AS (
    SELECT 
        a.name as conta,
        at.name as tipo_conta,
        SUM(CASE WHEN p.type = 'expense' THEN p.amount ELSE 0 END) as total_gastos,
        SUM(CASE WHEN p.type = 'income' THEN p.amount ELSE 0 END) as total_receitas,
        COUNT(CASE WHEN p.type = 'expense' THEN 1 END) as num_gastos,
        COUNT(CASE WHEN p.type = 'income' THEN 1 END) as num_receitas
    FROM accounts a
    JOIN account_types at ON a.account_type_id = at.id
    LEFT JOIN payments p ON a.id = p.account_id 
        AND EXTRACT(MONTH FROM p.payment_date) = EXTRACT(MONTH FROM CURRENT_DATE)
    WHERE a.user_id = auth.uid()
        AND a.is_active = true
    GROUP BY a.id, a.name, at.name
)
SELECT 
    *,
    (total_receitas - total_gastos) as saldo_movimento
FROM impacto_contas
ORDER BY total_gastos DESC;

-- =====================================================
-- FUNÇÕES ADICIONAIS ÚTEIS
-- =====================================================

-- 9. Função para obter projeção de gastos
CREATE OR REPLACE FUNCTION get_spending_projection(
    p_user_id UUID,
    p_months_ahead INTEGER DEFAULT 3
)
RETURNS TABLE (
    projected_month DATE,
    projected_amount DECIMAL,
    based_on_period VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    WITH monthly_average AS (
        SELECT AVG(monthly_total) as avg_amount
        FROM (
            SELECT 
                DATE_TRUNC('month', payment_date) as month,
                SUM(amount) as monthly_total
            FROM payments 
            WHERE user_id = p_user_id 
                AND type = 'expense'
                AND payment_date >= CURRENT_DATE - INTERVAL '6 months'
                AND payment_date < DATE_TRUNC('month', CURRENT_DATE)
            GROUP BY DATE_TRUNC('month', payment_date)
        ) monthly_totals
    ),
    recurring_payments_total AS (
        SELECT COALESCE(SUM(amount), 0) as recurring_amount
        FROM recurring_payments 
        WHERE user_id = p_user_id 
            AND type = 'expense'
            AND is_active = true
            AND frequency_type = 'monthly'
    )
    SELECT 
        (DATE_TRUNC('month', CURRENT_DATE) + (gs.month_offset || ' months')::INTERVAL)::DATE,
        COALESCE(ma.avg_amount, 0) + COALESCE(rpt.recurring_amount, 0),
        'Média últimos 6 meses + recorrentes'
    FROM generate_series(1, p_months_ahead) gs(month_offset),
         monthly_average ma,
         recurring_payments_total rpt;
END;
$$ LANGUAGE plpgsql;

-- 10. Função para calcular score financeiro
CREATE OR REPLACE FUNCTION calculate_financial_score(p_user_id UUID)
RETURNS TABLE (
    score INTEGER,
    score_description VARCHAR,
    factors JSONB
) AS $$
DECLARE
    v_score INTEGER := 0;
    v_factors JSONB := '{}';
    v_current_balance DECIMAL;
    v_monthly_income DECIMAL;
    v_monthly_expenses DECIMAL;
    v_budget_adherence DECIMAL;
    v_savings_rate DECIMAL;
BEGIN
    -- Calcular saldo atual
    SELECT COALESCE(SUM(current_balance), 0) INTO v_current_balance
    FROM accounts WHERE user_id = p_user_id AND is_active = true;
    
    -- Calcular receita mensal média
    SELECT COALESCE(AVG(monthly_total), 0) INTO v_monthly_income
    FROM (
        SELECT SUM(amount) as monthly_total
        FROM payments 
        WHERE user_id = p_user_id 
            AND type = 'income'
            AND payment_date >= CURRENT_DATE - INTERVAL '3 months'
        GROUP BY DATE_TRUNC('month', payment_date)
    ) monthly_income;
    
    -- Calcular gastos mensais médios
    SELECT COALESCE(AVG(monthly_total), 0) INTO v_monthly_expenses
    FROM (
        SELECT SUM(amount) as monthly_total
        FROM payments 
        WHERE user_id = p_user_id 
            AND type = 'expense'
            AND payment_date >= CURRENT_DATE - INTERVAL '3 months'
        GROUP BY DATE_TRUNC('month', payment_date)
    ) monthly_expenses;
    
    -- Calcular taxa de poupança
    IF v_monthly_income > 0 THEN
        v_savings_rate := (v_monthly_income - v_monthly_expenses) / v_monthly_income * 100;
    ELSE
        v_savings_rate := 0;
    END IF;
    
    -- Pontuação baseada no saldo (0-25 pontos)
    IF v_current_balance >= v_monthly_expenses * 6 THEN
        v_score := v_score + 25; -- 6 meses de reserva
    ELSIF v_current_balance >= v_monthly_expenses * 3 THEN
        v_score := v_score + 20; -- 3 meses de reserva
    ELSIF v_current_balance >= v_monthly_expenses THEN
        v_score := v_score + 15; -- 1 mês de reserva
    ELSIF v_current_balance > 0 THEN
        v_score := v_score + 10;
    END IF;
    
    -- Pontuação baseada na taxa de poupança (0-25 pontos)
    IF v_savings_rate >= 20 THEN
        v_score := v_score + 25;
    ELSIF v_savings_rate >= 10 THEN
        v_score := v_score + 20;
    ELSIF v_savings_rate >= 5 THEN
        v_score := v_score + 15;
    ELSIF v_savings_rate > 0 THEN
        v_score := v_score + 10;
    END IF;
    
    -- Adicionar outros fatores ao JSON
    v_factors := jsonb_build_object(
        'current_balance', v_current_balance,
        'monthly_income', v_monthly_income,
        'monthly_expenses', v_monthly_expenses,
        'savings_rate', ROUND(v_savings_rate, 2),
        'emergency_fund_months', CASE WHEN v_monthly_expenses > 0 THEN ROUND(v_current_balance / v_monthly_expenses, 1) ELSE 0 END
    );
    
    RETURN QUERY SELECT 
        v_score,
        CASE 
            WHEN v_score >= 80 THEN 'Excelente'
            WHEN v_score >= 60 THEN 'Bom'
            WHEN v_score >= 40 THEN 'Regular'
            WHEN v_score >= 20 THEN 'Ruim'
            ELSE 'Crítico'
        END,
        v_factors;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- QUERIES PARA CONTROLE DE METAS
-- =====================================================

-- 11. Progresso das metas financeiras
SELECT 
    fg.name as meta,
    fg.description,
    fg.target_amount as valor_meta,
    fg.current_amount as valor_atual,
    ROUND((fg.current_amount / fg.target_amount * 100), 2) as percentual_atingido,
    (fg.target_amount - fg.current_amount) as valor_faltante,
    fg.target_date as data_meta,
    (fg.target_date - CURRENT_DATE) as dias_restantes,
    CASE 
        WHEN fg.current_amount >= fg.target_amount THEN 'Atingida'
        WHEN fg.target_date < CURRENT_DATE THEN 'Vencida'
        ELSE 'Em andamento'
    END as status_meta
FROM financial_goals fg
WHERE fg.user_id = auth.uid()
    AND fg.is_active = true
ORDER BY percentual_atingido DESC;

-- =====================================================
-- QUERIES PARA EXPORTAÇÃO DE DADOS
-- =====================================================

-- 12. Exportar histórico completo (formato para Excel/CSV)
SELECT 
    p.payment_date as "Data Pagamento",
    p.due_date as "Data Vencimento",
    p.description as "Descrição",
    p.amount as "Valor",
    CASE WHEN p.type = 'income' THEN 'Receita' ELSE 'Despesa' END as "Tipo",
    c.name as "Categoria",
    a.name as "Conta",
    s.name as "Status",
    pt.name as "Tipo Pagamento",
    p.notes as "Observações"
FROM payments p
JOIN categories c ON p.category_id = c.id
JOIN accounts a ON p.account_id = a.id
JOIN payment_status s ON p.status_id = s.id
JOIN payment_types pt ON p.payment_type_id = pt.id
WHERE p.user_id = auth.uid()
    AND p.payment_date >= '2024-01-01' -- Ajustar período conforme necessário
ORDER BY p.payment_date DESC;

-- =====================================================
-- QUERIES PARA NOTIFICAÇÕES AUTOMÁTICAS
-- =====================================================

-- 13. Identificar pagamentos que precisam de notificação
SELECT 
    p.id,
    p.user_id,
    p.description,
    p.amount,
    p.due_date,
    (p.due_date - CURRENT_DATE) as dias_ate_vencimento
FROM payments p
JOIN notification_settings ns ON p.user_id = ns.user_id
WHERE p.payment_date IS NULL  -- Ainda não foi pago
    AND ns.payment_due_enabled = true
    AND (p.due_date - CURRENT_DATE) <= ns.payment_due_days_before
    AND (p.due_date - CURRENT_DATE) >= 0
    AND NOT EXISTS (
        SELECT 1 FROM notifications n 
        WHERE n.related_payment_id = p.id 
            AND n.type = 'payment_due'
            AND n.created_at >= CURRENT_DATE
    );

-- 14. Identificar orçamentos estourados
SELECT 
    b.id,
    b.user_id,
    b.name,
    b.amount as orcamento,
    SUM(p.amount) as gasto_atual,
    (SUM(p.amount) - b.amount) as valor_excedente
FROM budgets b
JOIN notification_settings ns ON b.user_id = ns.user_id
LEFT JOIN payments p ON b.category_id = p.category_id 
    AND p.user_id = b.user_id
    AND p.type = 'expense'
    AND p.payment_date BETWEEN b.start_date AND b.end_date
WHERE b.is_active = true
    AND ns.budget_alert_enabled = true
    AND CURRENT_DATE BETWEEN b.start_date AND b.end_date
GROUP BY b.id, b.user_id, b.name, b.amount
HAVING SUM(p.amount) > b.amount;

-- =====================================================
-- EXEMPLO DE USO DAS FUNÇÕES CRIADAS
-- =====================================================

-- Usar a função de projeção de gastos
SELECT * FROM get_spending_projection(auth.uid(), 6);

-- Calcular score financeiro do usuário
SELECT * FROM calculate_financial_score(auth.uid());

-- Gerar pagamentos recorrentes (executar diariamente)
SELECT generate_recurring_payments();