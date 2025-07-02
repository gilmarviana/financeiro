-- =====================================================
-- DADOS DE EXEMPLO PARA TESTE DO SISTEMA FINANCEIRO
-- Sistema Financeiro - Supabase
-- =====================================================

-- IMPORTANTE: Execute este arquivo SOMENTE após:
-- 1. Ter criado um usuário no Supabase Auth
-- 2. Ter executado o arquivo supabase_financial_system.sql
-- 3. Substituir 'USER_ID_AQUI' pelo ID real do usuário

-- =====================================================
-- VARIÁVEIS DE CONFIGURAÇÃO
-- =====================================================
-- Substitua este UUID pelo ID real do seu usuário
-- Você pode obter através de: SELECT auth.uid(); (quando logado)
-- EXEMPLO: '12345678-1234-1234-1234-123456789012'

-- =====================================================
-- 1. INSERIR PERFIL DO USUÁRIO
-- =====================================================
INSERT INTO users (id, email, full_name, phone) VALUES 
('USER_ID_AQUI', 'usuario@email.com', 'João Silva', '(11) 99999-9999')
ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    full_name = EXCLUDED.full_name,
    phone = EXCLUDED.phone;

-- =====================================================
-- 2. CRIAR CONTAS DO USUÁRIO
-- =====================================================
INSERT INTO accounts (user_id, account_type_id, name, bank_name, initial_balance, current_balance, color) VALUES 
-- Conta Corrente
('USER_ID_AQUI', (SELECT id FROM account_types WHERE name = 'Conta Corrente'), 'Itaú Conta Corrente', 'Banco Itaú', 5000.00, 5000.00, '#FF6B00'),

-- Conta Poupança
('USER_ID_AQUI', (SELECT id FROM account_types WHERE name = 'Conta Poupança'), 'Itaú Poupança', 'Banco Itaú', 15000.00, 15000.00, '#00AA00'),

-- Cartão de Crédito
('USER_ID_AQUI', (SELECT id FROM account_types WHERE name = 'Cartão de Crédito'), 'Cartão Itaú Mastercard', 'Banco Itaú', 0.00, -1200.00, '#CC0000'),

-- Dinheiro
('USER_ID_AQUI', (SELECT id FROM account_types WHERE name = 'Dinheiro'), 'Carteira', NULL, 300.00, 300.00, '#4CAF50'),

-- Carteira Digital
('USER_ID_AQUI', (SELECT id FROM account_types WHERE name = 'Carteira Digital'), 'PicPay', 'PicPay', 150.00, 150.00, '#00BCD4');

-- =====================================================
-- 3. CRIAR CATEGORIAS PERSONALIZADAS
-- =====================================================
INSERT INTO categories (user_id, name, description, icon, color, type) VALUES 
-- Subcategorias de Alimentação
('USER_ID_AQUI', 'Supermercado', 'Compras de supermercado', 'shopping-cart', '#FF9800', 'expense'),
('USER_ID_AQUI', 'Restaurantes', 'Refeições em restaurantes', 'utensils', '#FF5722', 'expense'),
('USER_ID_AQUI', 'Delivery', 'Pedidos de comida', 'truck', '#E91E63', 'expense'),

-- Subcategorias de Transporte
('USER_ID_AQUI', 'Combustível', 'Gasolina e etanol', 'fuel', '#607D8B', 'expense'),
('USER_ID_AQUI', 'Uber/Taxi', 'Corridas de aplicativo', 'car', '#9C27B0', 'expense'),

-- Receitas adicionais
('USER_ID_AQUI', 'Renda Extra', 'Trabalhos extras', 'dollar-sign', '#4CAF50', 'income');

-- =====================================================
-- 4. CRIAR PAGAMENTOS RECORRENTES
-- =====================================================
INSERT INTO recurring_payments (
    user_id, account_id, category_id, description, amount, type,
    frequency_type, frequency_interval, start_date, next_occurrence, fixed_day
) VALUES 
-- Aluguel
('USER_ID_AQUI', 
 (SELECT id FROM accounts WHERE user_id = 'USER_ID_AQUI' AND name = 'Itaú Conta Corrente'), 
 (SELECT id FROM categories WHERE name = 'Moradia' AND is_system = true), 
 'Aluguel Apartamento', 1800.00, 'expense', 'monthly', 1, '2024-01-05', '2025-01-05', 5),

-- Salário
('USER_ID_AQUI', 
 (SELECT id FROM accounts WHERE user_id = 'USER_ID_AQUI' AND name = 'Itaú Conta Corrente'), 
 (SELECT id FROM categories WHERE name = 'Salário' AND is_system = true), 
 'Salário Empresa XYZ', 6500.00, 'income', 'monthly', 1, '2024-01-05', '2025-01-05', 5),

-- Netflix
('USER_ID_AQUI', 
 (SELECT id FROM accounts WHERE user_id = 'USER_ID_AQUI' AND name = 'Cartão Itaú Mastercard'), 
 (SELECT id FROM categories WHERE name = 'Serviços' AND is_system = true), 
 'Netflix Premium', 45.90, 'expense', 'monthly', 1, '2024-01-15', '2025-01-15', 15),

-- Academia
('USER_ID_AQUI', 
 (SELECT id FROM accounts WHERE user_id = 'USER_ID_AQUI' AND name = 'Itaú Conta Corrente'), 
 (SELECT id FROM categories WHERE name = 'Saúde' AND is_system = true), 
 'Academia Smart Fit', 89.90, 'expense', 'monthly', 1, '2024-01-10', '2025-01-10', 10);

-- =====================================================
-- 5. CRIAR PAGAMENTOS HISTÓRICOS (ÚLTIMOS 3 MESES)
-- =====================================================

-- Dezembro 2024
INSERT INTO payments (
    user_id, account_id, category_id, payment_type_id, status_id,
    description, amount, type, due_date, payment_date
) VALUES 
-- Receitas
('USER_ID_AQUI', 
 (SELECT id FROM accounts WHERE user_id = 'USER_ID_AQUI' AND name = 'Itaú Conta Corrente'),
 (SELECT id FROM categories WHERE name = 'Salário' AND is_system = true),
 (SELECT id FROM payment_types WHERE name = 'Recorrente'),
 (SELECT id FROM payment_status WHERE name = 'Pago'),
 'Salário Dezembro', 6500.00, 'income', '2024-12-05', '2024-12-05'),

-- Despesas Dezembro
('USER_ID_AQUI', 
 (SELECT id FROM accounts WHERE user_id = 'USER_ID_AQUI' AND name = 'Itaú Conta Corrente'),
 (SELECT id FROM categories WHERE name = 'Moradia' AND is_system = true),
 (SELECT id FROM payment_types WHERE name = 'Recorrente'),
 (SELECT id FROM payment_status WHERE name = 'Pago'),
 'Aluguel Dezembro', 1800.00, 'expense', '2024-12-05', '2024-12-05'),

('USER_ID_AQUI', 
 (SELECT id FROM accounts WHERE user_id = 'USER_ID_AQUI' AND name = 'Cartão Itaú Mastercard'),
 (SELECT id FROM categories WHERE user_id = 'USER_ID_AQUI' AND name = 'Supermercado'),
 (SELECT id FROM payment_types WHERE name = 'Normal'),
 (SELECT id FROM payment_status WHERE name = 'Pago'),
 'Compras Extra', 450.80, 'expense', '2024-12-10', '2024-12-10'),

('USER_ID_AQUI', 
 (SELECT id FROM accounts WHERE user_id = 'USER_ID_AQUI' AND name = 'Cartão Itaú Mastercard'),
 (SELECT id FROM categories WHERE user_id = 'USER_ID_AQUI' AND name = 'Combustível'),
 (SELECT id FROM payment_types WHERE name = 'Normal'),
 (SELECT id FROM payment_status WHERE name = 'Pago'),
 'Posto Shell', 120.00, 'expense', '2024-12-12', '2024-12-12'),

('USER_ID_AQUI', 
 (SELECT id FROM accounts WHERE user_id = 'USER_ID_AQUI' AND name = 'Cartão Itaú Mastercard'),
 (SELECT id FROM categories WHERE name = 'Serviços' AND is_system = true),
 (SELECT id FROM payment_types WHERE name = 'Recorrente'),
 (SELECT id FROM payment_status WHERE name = 'Pago'),
 'Netflix', 45.90, 'expense', '2024-12-15', '2024-12-15'),

-- Novembro 2024
('USER_ID_AQUI', 
 (SELECT id FROM accounts WHERE user_id = 'USER_ID_AQUI' AND name = 'Itaú Conta Corrente'),
 (SELECT id FROM categories WHERE name = 'Salário' AND is_system = true),
 (SELECT id FROM payment_types WHERE name = 'Recorrente'),
 (SELECT id FROM payment_status WHERE name = 'Pago'),
 'Salário Novembro', 6500.00, 'income', '2024-11-05', '2024-11-05'),

('USER_ID_AQUI', 
 (SELECT id FROM accounts WHERE user_id = 'USER_ID_AQUI' AND name = 'Itaú Conta Corrente'),
 (SELECT id FROM categories WHERE name = 'Moradia' AND is_system = true),
 (SELECT id FROM payment_types WHERE name = 'Recorrente'),
 (SELECT id FROM payment_status WHERE name = 'Pago'),
 'Aluguel Novembro', 1800.00, 'expense', '2024-11-05', '2024-11-05'),

-- Outubro 2024
('USER_ID_AQUI', 
 (SELECT id FROM accounts WHERE user_id = 'USER_ID_AQUI' AND name = 'Itaú Conta Corrente'),
 (SELECT id FROM categories WHERE name = 'Salário' AND is_system = true),
 (SELECT id FROM payment_types WHERE name = 'Recorrente'),
 (SELECT id FROM payment_status WHERE name = 'Pago'),
 'Salário Outubro', 6500.00, 'income', '2024-10-05', '2024-10-05');

-- =====================================================
-- 6. CRIAR PAGAMENTOS FUTUROS/PENDENTES
-- =====================================================
INSERT INTO payments (
    user_id, account_id, category_id, payment_type_id, status_id,
    description, amount, type, due_date
) VALUES 
-- Janeiro 2025
('USER_ID_AQUI', 
 (SELECT id FROM accounts WHERE user_id = 'USER_ID_AQUI' AND name = 'Itaú Conta Corrente'),
 (SELECT id FROM categories WHERE name = 'Moradia' AND is_system = true),
 (SELECT id FROM payment_types WHERE name = 'Recorrente'),
 (SELECT id FROM payment_status WHERE name = 'Pendente'),
 'Aluguel Janeiro', 1800.00, 'expense', CURRENT_DATE + INTERVAL '5 days'),

('USER_ID_AQUI', 
 (SELECT id FROM accounts WHERE user_id = 'USER_ID_AQUI' AND name = 'Cartão Itaú Mastercard'),
 (SELECT id FROM categories WHERE name = 'Serviços' AND is_system = true),
 (SELECT id FROM payment_types WHERE name = 'Recorrente'),
 (SELECT id FROM payment_status WHERE name = 'Pendente'),
 'Netflix Janeiro', 45.90, 'expense', CURRENT_DATE + INTERVAL '10 days'),

('USER_ID_AQUI', 
 (SELECT id FROM accounts WHERE user_id = 'USER_ID_AQUI' AND name = 'Itaú Conta Corrente'),
 (SELECT id FROM categories WHERE name = 'Impostos' AND is_system = true),
 (SELECT id FROM payment_types WHERE name = 'Fixo'),
 (SELECT id FROM payment_status WHERE name = 'Pendente'),
 'IPTU 2025', 1200.00, 'expense', CURRENT_DATE + INTERVAL '15 days'),

('USER_ID_AQUI', 
 (SELECT id FROM accounts WHERE user_id = 'USER_ID_AQUI' AND name = 'Itaú Conta Corrente'),
 (SELECT id FROM categories WHERE name = 'Saúde' AND is_system = true),
 (SELECT id FROM payment_types WHERE name = 'Normal'),
 (SELECT id FROM payment_status WHERE name = 'Pendente'),
 'Consulta Médica', 250.00, 'expense', CURRENT_DATE + INTERVAL '7 days');

-- =====================================================
-- 7. CRIAR ORÇAMENTOS
-- =====================================================
INSERT INTO budgets (
    user_id, category_id, name, amount, start_date, end_date, alert_percentage
) VALUES 
-- Orçamento Alimentação
('USER_ID_AQUI', 
 (SELECT id FROM categories WHERE name = 'Alimentação' AND is_system = true),
 'Orçamento Alimentação Janeiro 2025', 800.00, 
 DATE_TRUNC('month', CURRENT_DATE)::DATE, 
 (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month - 1 day')::DATE, 
 80.00),

-- Orçamento Transporte
('USER_ID_AQUI', 
 (SELECT id FROM categories WHERE name = 'Transporte' AND is_system = true),
 'Orçamento Transporte Janeiro 2025', 500.00, 
 DATE_TRUNC('month', CURRENT_DATE)::DATE, 
 (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month - 1 day')::DATE, 
 75.00),

-- Orçamento Lazer
('USER_ID_AQUI', 
 (SELECT id FROM categories WHERE name = 'Lazer' AND is_system = true),
 'Orçamento Lazer Janeiro 2025', 400.00, 
 DATE_TRUNC('month', CURRENT_DATE)::DATE, 
 (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month - 1 day')::DATE, 
 85.00);

-- =====================================================
-- 8. CRIAR METAS FINANCEIRAS
-- =====================================================
INSERT INTO financial_goals (
    user_id, account_id, name, description, target_amount, current_amount, target_date
) VALUES 
-- Meta Reserva de Emergência
('USER_ID_AQUI', 
 (SELECT id FROM accounts WHERE user_id = 'USER_ID_AQUI' AND name = 'Itaú Poupança'),
 'Reserva de Emergência', 'Meta de 6 meses de gastos para emergências', 30000.00, 15000.00, 
 CURRENT_DATE + INTERVAL '12 months'),

-- Meta Viagem
('USER_ID_AQUI', 
 (SELECT id FROM accounts WHERE user_id = 'USER_ID_AQUI' AND name = 'Itaú Poupança'),
 'Viagem Europa', 'Economizar para viagem de férias', 15000.00, 3000.00, 
 CURRENT_DATE + INTERVAL '8 months'),

-- Meta Carro
('USER_ID_AQUI', 
 (SELECT id FROM accounts WHERE user_id = 'USER_ID_AQUI' AND name = 'Itaú Poupança'),
 'Entrada Carro Novo', 'Juntar entrada para trocar de carro', 25000.00, 8000.00, 
 CURRENT_DATE + INTERVAL '18 months');

-- =====================================================
-- 9. CONFIGURAR NOTIFICAÇÕES
-- =====================================================
INSERT INTO notification_settings (
    user_id, payment_due_days_before, budget_alert_percentage, low_balance_threshold
) VALUES 
('USER_ID_AQUI', 3, 80.00, 500.00)
ON CONFLICT (user_id) DO UPDATE SET
    payment_due_days_before = EXCLUDED.payment_due_days_before,
    budget_alert_percentage = EXCLUDED.budget_alert_percentage,
    low_balance_threshold = EXCLUDED.low_balance_threshold;

-- =====================================================
-- 10. CRIAR ALGUMAS NOTIFICAÇÕES DE EXEMPLO
-- =====================================================
INSERT INTO notifications (
    user_id, type, title, message, related_payment_id, scheduled_for
) VALUES 
('USER_ID_AQUI', 'payment_due', 'Pagamento Próximo do Vencimento', 
 'O aluguel vence em 3 dias. Não esqueça de fazer o pagamento!',
 (SELECT id FROM payments WHERE user_id = 'USER_ID_AQUI' AND description = 'Aluguel Janeiro' LIMIT 1),
 CURRENT_DATE + INTERVAL '2 days'),

('USER_ID_AQUI', 'low_balance', 'Saldo Baixo', 
 'Sua conta corrente está com saldo baixo. Considere fazer uma transferência.',
 NULL, CURRENT_TIMESTAMP);

-- =====================================================
-- QUERIES PARA VERIFICAR OS DADOS INSERIDOS
-- =====================================================

-- Verificar contas criadas
SELECT 
    a.name as conta,
    at.name as tipo,
    a.current_balance as saldo,
    a.color
FROM accounts a
JOIN account_types at ON a.account_type_id = at.id
WHERE a.user_id = 'USER_ID_AQUI';

-- Verificar pagamentos recorrentes
SELECT 
    rp.description,
    rp.amount,
    rp.frequency_type,
    rp.next_occurrence
FROM recurring_payments rp
WHERE rp.user_id = 'USER_ID_AQUI';

-- Verificar próximos pagamentos
SELECT 
    p.description,
    p.amount,
    p.due_date,
    (p.due_date - CURRENT_DATE) as dias_restantes
FROM payments p
WHERE p.user_id = 'USER_ID_AQUI'
    AND p.payment_date IS NULL
ORDER BY p.due_date;

-- Verificar orçamentos
SELECT 
    b.name,
    b.amount as orcado,
    c.name as categoria
FROM budgets b
JOIN categories c ON b.category_id = c.id
WHERE b.user_id = 'USER_ID_AQUI'
    AND b.is_active = true;

-- Verificar metas
SELECT 
    fg.name,
    fg.target_amount as meta,
    fg.current_amount as atual,
    ROUND((fg.current_amount / fg.target_amount * 100), 2) as percentual
FROM financial_goals fg
WHERE fg.user_id = 'USER_ID_AQUI'
    AND fg.is_active = true;

-- =====================================================
-- IMPORTANTE: LEMBRAR DE ATUALIZAR O USER_ID
-- =====================================================

/*
ANTES DE EXECUTAR ESTE ARQUIVO:

1. Faça login no Supabase Dashboard
2. Execute: SELECT auth.uid(); para obter seu User ID
3. Substitua todas as ocorrências de 'USER_ID_AQUI' pelo seu ID real
4. Execute o arquivo completo

EXEMPLO DE COMO OBTER O USER ID:
- Crie uma conta via Supabase Auth
- No SQL Editor, execute: SELECT auth.uid();
- Copie o UUID retornado
- Use Find & Replace para substituir 'USER_ID_AQUI'

APÓS EXECUTAR:
- Verifique se todos os dados foram inseridos corretamente
- Teste as queries de exemplo do arquivo queries_exemplos.sql
- Explore o dashboard usando as views criadas
*/