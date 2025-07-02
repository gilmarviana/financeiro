-- ============================================
-- SISTEMA FINANCEIRO - SUPABASE
-- Estrutura completa das tabelas
-- ============================================

-- Extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================
-- 1. TABELA DE USUÁRIOS
-- ============================================
-- Usuários do sistema (conecta com Supabase Auth)
CREATE TABLE users (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(255),
    avatar_url TEXT,
    phone VARCHAR(20),
    timezone VARCHAR(50) DEFAULT 'America/Sao_Paulo',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 2. TABELA DE TIPOS DE CONTAS
-- ============================================
CREATE TABLE account_types (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Inserir tipos de contas padrão
INSERT INTO account_types (name, description, icon) VALUES 
('Conta Corrente', 'Conta bancária para movimentação diária', 'bank'),
('Conta Poupança', 'Conta de poupança para reservas', 'piggy-bank'),
('Cartão de Crédito', 'Cartão de crédito', 'credit-card'),
('Cartão de Débito', 'Cartão de débito', 'debit-card'),
('Dinheiro', 'Dinheiro em espécie', 'cash'),
('Investimentos', 'Contas de investimento', 'trending-up'),
('Carteira Digital', 'Pix, PayPal, PicPay, etc.', 'smartphone');

-- ============================================
-- 3. TABELA DE CONTAS/CARTEIRAS
-- ============================================
CREATE TABLE accounts (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    account_type_id UUID REFERENCES account_types(id) NOT NULL,
    name VARCHAR(255) NOT NULL,
    bank_name VARCHAR(255),
    account_number VARCHAR(50),
    agency VARCHAR(20),
    initial_balance DECIMAL(15,2) DEFAULT 0,
    current_balance DECIMAL(15,2) DEFAULT 0,
    credit_limit DECIMAL(15,2) DEFAULT 0, -- Para cartões de crédito
    closing_day INTEGER, -- Dia de fechamento do cartão (1-31)
    due_day INTEGER, -- Dia de vencimento do cartão (1-31)
    is_active BOOLEAN DEFAULT TRUE,
    color VARCHAR(7) DEFAULT '#3B82F6', -- Cor em hex para identificação
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 4. TABELA DE CATEGORIAS
-- ============================================
CREATE TABLE categories (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    parent_id UUID REFERENCES categories(id) ON DELETE CASCADE, -- Para subcategorias
    name VARCHAR(255) NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    color VARCHAR(7) DEFAULT '#6B7280',
    type VARCHAR(20) CHECK (type IN ('income', 'expense')) NOT NULL,
    is_system BOOLEAN DEFAULT FALSE, -- Categorias padrão do sistema
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Inserir categorias padrão de despesas
INSERT INTO categories (name, description, icon, color, type, is_system) VALUES 
('Moradia', 'Aluguel, financiamento, condomínio', 'home', '#EF4444', 'expense', TRUE),
('Alimentação', 'Supermercado, restaurantes, delivery', 'utensils', '#F97316', 'expense', TRUE),
('Transporte', 'Combustível, transporte público, manutenção', 'car', '#8B5CF6', 'expense', TRUE),
('Saúde', 'Plano de saúde, consultas, medicamentos', 'heart', '#EC4899', 'expense', TRUE),
('Educação', 'Cursos, livros, mensalidades', 'book-open', '#3B82F6', 'expense', TRUE),
('Lazer', 'Cinema, viagens, hobbies', 'gamepad-2', '#10B981', 'expense', TRUE),
('Vestuário', 'Roupas, calçados, acessórios', 'shirt', '#F59E0B', 'expense', TRUE),
('Serviços', 'Internet, telefone, streaming', 'wifi', '#6366F1', 'expense', TRUE),
('Impostos', 'IPTU, IPVA, IR', 'file-text', '#DC2626', 'expense', TRUE),
('Outros', 'Despesas diversas', 'more-horizontal', '#6B7280', 'expense', TRUE);

-- Inserir categorias padrão de receitas
INSERT INTO categories (name, description, icon, color, type, is_system) VALUES 
('Salário', 'Salário principal', 'briefcase', '#10B981', 'income', TRUE),
('Freelance', 'Trabalhos extras', 'user', '#3B82F6', 'income', TRUE),
('Investimentos', 'Dividendos, juros, rendimentos', 'trending-up', '#8B5CF6', 'income', TRUE),
('Vendas', 'Vendas de produtos/serviços', 'shopping-bag', '#F97316', 'income', TRUE),
('Outros', 'Receitas diversas', 'plus-circle', '#6B7280', 'income', TRUE);

-- ============================================
-- 5. TABELA DE STATUS DE PAGAMENTOS
-- ============================================
CREATE TABLE payment_status (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    color VARCHAR(7),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

INSERT INTO payment_status (name, description, color) VALUES 
('Pendente', 'Pagamento agendado, aguardando processamento', '#F59E0B'),
('Pago', 'Pagamento realizado com sucesso', '#10B981'),
('Atrasado', 'Pagamento em atraso', '#EF4444'),
('Cancelado', 'Pagamento cancelado', '#6B7280'),
('Agendado', 'Pagamento agendado para o futuro', '#3B82F6');

-- ============================================
-- 6. TABELA DE TIPOS DE PAGAMENTO
-- ============================================
CREATE TABLE payment_types (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

INSERT INTO payment_types (name, description) VALUES 
('Normal', 'Pagamento único, variável'),
('Fixo', 'Pagamento em data específica, valor fixo'),
('Recorrente', 'Pagamento que se repete automaticamente');

-- ============================================
-- 7. TABELA PRINCIPAL DE PAGAMENTOS/TRANSAÇÕES
-- ============================================
CREATE TABLE payments (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    account_id UUID REFERENCES accounts(id) NOT NULL,
    category_id UUID REFERENCES categories(id) NOT NULL,
    payment_type_id UUID REFERENCES payment_types(id) NOT NULL,
    status_id UUID REFERENCES payment_status(id) NOT NULL,
    
    -- Informações básicas
    description VARCHAR(500) NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    type VARCHAR(20) CHECK (type IN ('income', 'expense')) NOT NULL,
    
    -- Datas
    due_date DATE NOT NULL,
    payment_date DATE,
    
    -- Informações adicionais
    notes TEXT,
    reference_number VARCHAR(100), -- Número de referência/documento
    tags VARCHAR(500), -- Tags separadas por vírgula
    
    -- Relacionamento com recorrência
    recurring_payment_id UUID, -- Referência para configuração de recorrência
    installment_number INTEGER DEFAULT 1, -- Número da parcela
    total_installments INTEGER DEFAULT 1, -- Total de parcelas
    
    -- Campos de controle
    is_transfer BOOLEAN DEFAULT FALSE, -- Se é uma transferência entre contas
    transfer_to_account_id UUID REFERENCES accounts(id), -- Conta destino da transferência
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 8. TABELA DE PAGAMENTOS RECORRENTES
-- ============================================
CREATE TABLE recurring_payments (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    account_id UUID REFERENCES accounts(id) NOT NULL,
    category_id UUID REFERENCES categories(id) NOT NULL,
    
    -- Configurações da recorrência
    description VARCHAR(500) NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    type VARCHAR(20) CHECK (type IN ('income', 'expense')) NOT NULL,
    
    -- Configurações de frequência
    frequency_type VARCHAR(20) CHECK (frequency_type IN ('daily', 'weekly', 'monthly', 'yearly')) NOT NULL,
    frequency_interval INTEGER DEFAULT 1, -- A cada X períodos
    
    -- Datas
    start_date DATE NOT NULL,
    end_date DATE, -- Data final (NULL = sem fim)
    next_occurrence DATE NOT NULL,
    last_generated DATE,
    
    -- Configurações avançadas
    fixed_day INTEGER, -- Dia fixo do mês (1-31)
    weekday INTEGER, -- Dia da semana (0=domingo, 6=sábado)
    max_occurrences INTEGER, -- Máximo de ocorrências (NULL = ilimitado)
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 9. TABELA DE ORÇAMENTOS
-- ============================================
CREATE TABLE budgets (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    category_id UUID REFERENCES categories(id) NOT NULL,
    
    -- Configurações do orçamento
    name VARCHAR(255) NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    period_type VARCHAR(20) CHECK (period_type IN ('monthly', 'yearly', 'weekly')) DEFAULT 'monthly',
    
    -- Período específico
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    
    -- Status e alertas
    alert_percentage DECIMAL(5,2) DEFAULT 80.00, -- Alerta quando atingir X% do orçamento
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Garantir que não há orçamentos duplicados para mesma categoria no mesmo período
    UNIQUE(user_id, category_id, start_date, end_date)
);

-- ============================================
-- 10. TABELA DE NOTIFICAÇÕES
-- ============================================
CREATE TABLE notifications (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    
    -- Configurações da notificação
    type VARCHAR(50) NOT NULL, -- 'payment_due', 'payment_overdue', 'budget_alert', 'low_balance'
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    
    -- Dados relacionados
    related_payment_id UUID REFERENCES payments(id) ON DELETE SET NULL,
    related_budget_id UUID REFERENCES budgets(id) ON DELETE SET NULL,
    related_account_id UUID REFERENCES accounts(id) ON DELETE SET NULL,
    
    -- Status
    is_read BOOLEAN DEFAULT FALSE,
    is_sent BOOLEAN DEFAULT FALSE,
    sent_at TIMESTAMP WITH TIME ZONE,
    
    -- Agendamento
    scheduled_for TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 11. TABELA DE CONFIGURAÇÕES DE NOTIFICAÇÃO
-- ============================================
CREATE TABLE notification_settings (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    
    -- Configurações por tipo de notificação
    payment_due_enabled BOOLEAN DEFAULT TRUE,
    payment_due_days_before INTEGER DEFAULT 3,
    
    payment_overdue_enabled BOOLEAN DEFAULT TRUE,
    
    budget_alert_enabled BOOLEAN DEFAULT TRUE,
    budget_alert_percentage DECIMAL(5,2) DEFAULT 80.00,
    
    low_balance_enabled BOOLEAN DEFAULT TRUE,
    low_balance_threshold DECIMAL(15,2) DEFAULT 100.00,
    
    -- Meios de notificação
    email_enabled BOOLEAN DEFAULT TRUE,
    push_enabled BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(user_id)
);

-- ============================================
-- 12. TABELA DE METAS FINANCEIRAS
-- ============================================
CREATE TABLE financial_goals (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    account_id UUID REFERENCES accounts(id), -- Conta onde o dinheiro será guardado
    
    -- Informações da meta
    name VARCHAR(255) NOT NULL,
    description TEXT,
    target_amount DECIMAL(15,2) NOT NULL,
    current_amount DECIMAL(15,2) DEFAULT 0,
    
    -- Datas
    target_date DATE,
    achieved_date DATE,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    is_achieved BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 13. TABELA DE ANEXOS/COMPROVANTES
-- ============================================
CREATE TABLE payment_attachments (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    payment_id UUID REFERENCES payments(id) ON DELETE CASCADE NOT NULL,
    
    -- Informações do arquivo
    file_name VARCHAR(255) NOT NULL,
    file_type VARCHAR(100) NOT NULL,
    file_size INTEGER NOT NULL,
    file_url TEXT NOT NULL, -- URL do arquivo no Supabase Storage
    
    -- Metadados
    description TEXT,
    uploaded_by UUID REFERENCES users(id) NOT NULL,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- ÍNDICES PARA PERFORMANCE
-- ============================================

-- Índices para payments (tabela principal)
CREATE INDEX idx_payments_user_id ON payments(user_id);
CREATE INDEX idx_payments_account_id ON payments(account_id);
CREATE INDEX idx_payments_category_id ON payments(category_id);
CREATE INDEX idx_payments_due_date ON payments(due_date);
CREATE INDEX idx_payments_payment_date ON payments(payment_date);
CREATE INDEX idx_payments_type ON payments(type);
CREATE INDEX idx_payments_status_id ON payments(status_id);
CREATE INDEX idx_payments_recurring_id ON payments(recurring_payment_id);

-- Índices para contas
CREATE INDEX idx_accounts_user_id ON accounts(user_id);
CREATE INDEX idx_accounts_type_id ON accounts(account_type_id);

-- Índices para categorias
CREATE INDEX idx_categories_user_id ON categories(user_id);
CREATE INDEX idx_categories_parent_id ON categories(parent_id);
CREATE INDEX idx_categories_type ON categories(type);

-- Índices para recorrências
CREATE INDEX idx_recurring_payments_user_id ON recurring_payments(user_id);
CREATE INDEX idx_recurring_payments_next_occurrence ON recurring_payments(next_occurrence);
CREATE INDEX idx_recurring_payments_is_active ON recurring_payments(is_active);

-- Índices para orçamentos
CREATE INDEX idx_budgets_user_id ON budgets(user_id);
CREATE INDEX idx_budgets_category_id ON budgets(category_id);
CREATE INDEX idx_budgets_period ON budgets(start_date, end_date);

-- Índices para notificações
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_scheduled_for ON notifications(scheduled_for);

-- ============================================
-- TRIGGERS PARA ATUALIZAÇÃO AUTOMÁTICA
-- ============================================

-- Trigger para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Aplicar trigger em todas as tabelas relevantes
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_accounts_updated_at BEFORE UPDATE ON accounts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON categories
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON payments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_recurring_payments_updated_at BEFORE UPDATE ON recurring_payments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_budgets_updated_at BEFORE UPDATE ON budgets
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notifications_updated_at BEFORE UPDATE ON notifications
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_financial_goals_updated_at BEFORE UPDATE ON financial_goals
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- FUNÇÃO PARA ATUALIZAR SALDO DAS CONTAS
-- ============================================
CREATE OR REPLACE FUNCTION update_account_balance()
RETURNS TRIGGER AS $$
BEGIN
    -- Se é uma inserção de pagamento do tipo despesa
    IF TG_OP = 'INSERT' AND NEW.type = 'expense' AND NEW.payment_date IS NOT NULL THEN
        UPDATE accounts 
        SET current_balance = current_balance - NEW.amount 
        WHERE id = NEW.account_id;
    END IF;
    
    -- Se é uma inserção de pagamento do tipo receita
    IF TG_OP = 'INSERT' AND NEW.type = 'income' AND NEW.payment_date IS NOT NULL THEN
        UPDATE accounts 
        SET current_balance = current_balance + NEW.amount 
        WHERE id = NEW.account_id;
    END IF;
    
    -- Se é uma atualização e mudou a data de pagamento
    IF TG_OP = 'UPDATE' THEN
        -- Reverter o pagamento anterior se existia
        IF OLD.payment_date IS NOT NULL THEN
            IF OLD.type = 'expense' THEN
                UPDATE accounts 
                SET current_balance = current_balance + OLD.amount 
                WHERE id = OLD.account_id;
            ELSE
                UPDATE accounts 
                SET current_balance = current_balance - OLD.amount 
                WHERE id = OLD.account_id;
            END IF;
        END IF;
        
        -- Aplicar o novo pagamento se existe
        IF NEW.payment_date IS NOT NULL THEN
            IF NEW.type = 'expense' THEN
                UPDATE accounts 
                SET current_balance = current_balance - NEW.amount 
                WHERE id = NEW.account_id;
            ELSE
                UPDATE accounts 
                SET current_balance = current_balance + NEW.amount 
                WHERE id = NEW.account_id;
            END IF;
        END IF;
    END IF;
    
    -- Se é uma exclusão
    IF TG_OP = 'DELETE' AND OLD.payment_date IS NOT NULL THEN
        IF OLD.type = 'expense' THEN
            UPDATE accounts 
            SET current_balance = current_balance + OLD.amount 
            WHERE id = OLD.account_id;
        ELSE
            UPDATE accounts 
            SET current_balance = current_balance - OLD.amount 
            WHERE id = OLD.account_id;
        END IF;
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ language 'plpgsql';

-- Aplicar trigger de saldo
CREATE TRIGGER payments_update_balance 
    AFTER INSERT OR UPDATE OR DELETE ON payments
    FOR EACH ROW EXECUTE FUNCTION update_account_balance();

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

-- Habilitar RLS em todas as tabelas principais
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE recurring_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE budgets ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE notification_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE financial_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_attachments ENABLE ROW LEVEL SECURITY;

-- Políticas RLS - Usuários só podem ver seus próprios dados

-- Users
CREATE POLICY "Users can view own profile" ON users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON users FOR UPDATE USING (auth.uid() = id);

-- Accounts
CREATE POLICY "Users can view own accounts" ON accounts FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create own accounts" ON accounts FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own accounts" ON accounts FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own accounts" ON accounts FOR DELETE USING (auth.uid() = user_id);

-- Categories (usuários podem ver categorias do sistema e suas próprias)
CREATE POLICY "Users can view categories" ON categories FOR SELECT USING (
    is_system = true OR auth.uid() = user_id
);
CREATE POLICY "Users can create own categories" ON categories FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own categories" ON categories FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own categories" ON categories FOR DELETE USING (auth.uid() = user_id);

-- Payments
CREATE POLICY "Users can view own payments" ON payments FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create own payments" ON payments FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own payments" ON payments FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own payments" ON payments FOR DELETE USING (auth.uid() = user_id);

-- Recurring Payments
CREATE POLICY "Users can view own recurring payments" ON recurring_payments FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create own recurring payments" ON recurring_payments FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own recurring payments" ON recurring_payments FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own recurring payments" ON recurring_payments FOR DELETE USING (auth.uid() = user_id);

-- Budgets
CREATE POLICY "Users can view own budgets" ON budgets FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create own budgets" ON budgets FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own budgets" ON budgets FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own budgets" ON budgets FOR DELETE USING (auth.uid() = user_id);

-- Notifications
CREATE POLICY "Users can view own notifications" ON notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create own notifications" ON notifications FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own notifications" ON notifications FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own notifications" ON notifications FOR DELETE USING (auth.uid() = user_id);

-- Notification Settings
CREATE POLICY "Users can view own notification settings" ON notification_settings FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create own notification settings" ON notification_settings FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own notification settings" ON notification_settings FOR UPDATE USING (auth.uid() = user_id);

-- Financial Goals
CREATE POLICY "Users can view own financial goals" ON financial_goals FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create own financial goals" ON financial_goals FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own financial goals" ON financial_goals FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own financial goals" ON financial_goals FOR DELETE USING (auth.uid() = user_id);

-- Payment Attachments (baseado no payment relacionado)
CREATE POLICY "Users can view own payment attachments" ON payment_attachments FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM payments p 
        WHERE p.id = payment_attachments.payment_id 
        AND p.user_id = auth.uid()
    )
);
CREATE POLICY "Users can create payment attachments" ON payment_attachments FOR INSERT WITH CHECK (
    EXISTS (
        SELECT 1 FROM payments p 
        WHERE p.id = payment_attachments.payment_id 
        AND p.user_id = auth.uid()
    )
);

-- Tabelas de referência (sem RLS pois são compartilhadas)
-- account_types, payment_status, payment_types não precisam de RLS

-- ============================================
-- FUNÇÕES ÚTEIS PARA O SISTEMA
-- ============================================

-- Função para gerar próximos pagamentos recorrentes
CREATE OR REPLACE FUNCTION generate_recurring_payments()
RETURNS INTEGER AS $$
DECLARE
    rec RECORD;
    next_date DATE;
    payments_created INTEGER := 0;
BEGIN
    -- Loop através de todos os pagamentos recorrentes ativos que precisam gerar novos pagamentos
    FOR rec IN 
        SELECT * FROM recurring_payments 
        WHERE is_active = true 
        AND next_occurrence <= CURRENT_DATE + INTERVAL '7 days' -- Gerar com até 7 dias de antecedência
        AND (end_date IS NULL OR next_occurrence <= end_date)
    LOOP
        -- Inserir o novo pagamento
        INSERT INTO payments (
            user_id, account_id, category_id, payment_type_id, status_id,
            description, amount, type, due_date, recurring_payment_id
        ) VALUES (
            rec.user_id, rec.account_id, rec.category_id, 
            (SELECT id FROM payment_types WHERE name = 'Recorrente'),
            (SELECT id FROM payment_status WHERE name = 'Pendente'),
            rec.description, rec.amount, rec.type, rec.next_occurrence, rec.id
        );
        
        -- Calcular próxima ocorrência
        CASE rec.frequency_type
            WHEN 'daily' THEN
                next_date := rec.next_occurrence + (rec.frequency_interval || ' days')::INTERVAL;
            WHEN 'weekly' THEN
                next_date := rec.next_occurrence + (rec.frequency_interval || ' weeks')::INTERVAL;
            WHEN 'monthly' THEN
                next_date := rec.next_occurrence + (rec.frequency_interval || ' months')::INTERVAL;
            WHEN 'yearly' THEN
                next_date := rec.next_occurrence + (rec.frequency_interval || ' years')::INTERVAL;
        END CASE;
        
        -- Atualizar a configuração de recorrência
        UPDATE recurring_payments 
        SET next_occurrence = next_date,
            last_generated = CURRENT_DATE
        WHERE id = rec.id;
        
        payments_created := payments_created + 1;
    END LOOP;
    
    RETURN payments_created;
END;
$$ LANGUAGE plpgsql;

-- Função para calcular gastos por categoria em um período
CREATE OR REPLACE FUNCTION get_expenses_by_category(
    p_user_id UUID,
    p_start_date DATE,
    p_end_date DATE
)
RETURNS TABLE (
    category_id UUID,
    category_name VARCHAR,
    total_amount DECIMAL,
    transaction_count INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id as category_id,
        c.name as category_name,
        COALESCE(SUM(p.amount), 0) as total_amount,
        COUNT(p.id)::INTEGER as transaction_count
    FROM categories c
    LEFT JOIN payments p ON c.id = p.category_id 
        AND p.user_id = p_user_id
        AND p.type = 'expense'
        AND p.payment_date BETWEEN p_start_date AND p_end_date
    WHERE c.type = 'expense' 
        AND (c.user_id = p_user_id OR c.is_system = true)
    GROUP BY c.id, c.name
    ORDER BY total_amount DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- VIEWS ÚTEIS PARA RELATÓRIOS
-- ============================================

-- View para dashboard - próximos pagamentos
CREATE VIEW v_upcoming_payments AS
SELECT 
    p.id,
    p.user_id,
    p.description,
    p.amount,
    p.due_date,
    p.type,
    c.name as category_name,
    c.color as category_color,
    a.name as account_name,
    s.name as status_name,
    s.color as status_color,
    (p.due_date - CURRENT_DATE) as days_until_due
FROM payments p
JOIN categories c ON p.category_id = c.id
JOIN accounts a ON p.account_id = a.id
JOIN payment_status s ON p.status_id = s.id
WHERE p.payment_date IS NULL 
    AND p.due_date >= CURRENT_DATE
ORDER BY p.due_date ASC;

-- View para saldo total por usuário
CREATE VIEW v_user_total_balance AS
SELECT 
    user_id,
    SUM(current_balance) as total_balance,
    SUM(CASE WHEN current_balance > 0 THEN current_balance ELSE 0 END) as positive_balance,
    SUM(CASE WHEN current_balance < 0 THEN current_balance ELSE 0 END) as negative_balance,
    COUNT(*) as total_accounts
FROM accounts 
WHERE is_active = true
GROUP BY user_id;

-- View para gastos mensais por categoria
CREATE VIEW v_monthly_expenses AS
SELECT 
    p.user_id,
    EXTRACT(YEAR FROM p.payment_date) as year,
    EXTRACT(MONTH FROM p.payment_date) as month,
    c.id as category_id,
    c.name as category_name,
    SUM(p.amount) as total_amount,
    COUNT(*) as transaction_count
FROM payments p
JOIN categories c ON p.category_id = c.id
WHERE p.type = 'expense' 
    AND p.payment_date IS NOT NULL
GROUP BY p.user_id, EXTRACT(YEAR FROM p.payment_date), EXTRACT(MONTH FROM p.payment_date), c.id, c.name;

-- ============================================
-- COMENTÁRIOS FINAIS
-- ============================================

/*
ESTRUTURA COMPLETA DO SISTEMA FINANCEIRO:

1. Gestão de Usuários e Contas
2. Categorização flexível de receitas/despesas
3. Três tipos de pagamentos (Normal, Fixo, Recorrente)
4. Sistema de orçamentos por categoria
5. Notificações e alertas automáticos
6. Metas financeiras
7. Anexos/comprovantes
8. Segurança com RLS
9. Triggers automáticos para saldos
10. Funções úteis para relatórios
11. Views para dashboards

PRÓXIMOS PASSOS RECOMENDADOS:
- Configurar Supabase Storage para anexos
- Implementar job/cron para gerar pagamentos recorrentes
- Criar API endpoints para todas as operações
- Desenvolver interface frontend
- Configurar notificações por email/push
- Implementar exportação de dados
*/