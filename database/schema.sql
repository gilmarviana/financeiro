-- Extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tabela de categorias
CREATE TABLE categories (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  color VARCHAR(7) DEFAULT '#667eea',
  icon VARCHAR(50) DEFAULT 'tag',
  type VARCHAR(20) CHECK (type IN ('income', 'expense', 'both')) DEFAULT 'both',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de transações
CREATE TABLE transactions (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  description VARCHAR(255) NOT NULL,
  amount DECIMAL(15, 2) NOT NULL,
  type VARCHAR(10) CHECK (type IN ('income', 'expense')) NOT NULL,
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para melhor performance
CREATE INDEX idx_transactions_date ON transactions(date);
CREATE INDEX idx_transactions_type ON transactions(type);
CREATE INDEX idx_transactions_category ON transactions(category_id);
CREATE INDEX idx_categories_type ON categories(type);

-- Trigger para atualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_categories_updated_at
  BEFORE UPDATE ON categories
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_transactions_updated_at
  BEFORE UPDATE ON transactions
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Função para obter resumo financeiro
CREATE OR REPLACE FUNCTION get_financial_summary()
RETURNS TABLE (
  total_income DECIMAL(15, 2),
  total_expenses DECIMAL(15, 2),
  balance DECIMAL(15, 2),
  transaction_count BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COALESCE(SUM(CASE WHEN t.type = 'income' THEN t.amount ELSE 0 END), 0) as total_income,
    COALESCE(SUM(CASE WHEN t.type = 'expense' THEN t.amount ELSE 0 END), 0) as total_expenses,
    COALESCE(SUM(CASE WHEN t.type = 'income' THEN t.amount ELSE -t.amount END), 0) as balance,
    COUNT(*) as transaction_count
  FROM transactions t;
END;
$$ LANGUAGE plpgsql;

-- Função para obter resumo por categoria
CREATE OR REPLACE FUNCTION get_category_summary(period_start DATE DEFAULT NULL, period_end DATE DEFAULT NULL)
RETURNS TABLE (
  category_id UUID,
  category_name VARCHAR(100),
  category_color VARCHAR(7),
  total_amount DECIMAL(15, 2),
  transaction_count BIGINT,
  transaction_type VARCHAR(10)
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    c.id as category_id,
    c.name as category_name,
    c.color as category_color,
    COALESCE(SUM(t.amount), 0) as total_amount,
    COUNT(t.id) as transaction_count,
    t.type as transaction_type
  FROM categories c
  LEFT JOIN transactions t ON c.id = t.category_id
  WHERE (period_start IS NULL OR t.date >= period_start)
    AND (period_end IS NULL OR t.date <= period_end)
  GROUP BY c.id, c.name, c.color, t.type
  ORDER BY total_amount DESC;
END;
$$ LANGUAGE plpgsql;

-- Inserir categorias padrão
INSERT INTO categories (name, description, color, icon, type) VALUES
  ('Salário', 'Salário mensal', '#48bb78', 'dollar-sign', 'income'),
  ('Freelance', 'Trabalhos freelance', '#38a169', 'briefcase', 'income'),
  ('Investimentos', 'Rendimentos de investimentos', '#68d391', 'trending-up', 'income'),
  ('Outros', 'Outras receitas', '#9ae6b4', 'plus-circle', 'income'),
  
  ('Alimentação', 'Gastos com comida', '#f56565', 'utensils', 'expense'),
  ('Transporte', 'Gastos com transporte', '#e53e3e', 'car', 'expense'),
  ('Moradia', 'Aluguel, condomínio, etc.', '#fc8181', 'home', 'expense'),
  ('Saúde', 'Gastos com saúde', '#feb2b2', 'heart', 'expense'),
  ('Educação', 'Cursos, livros, etc.', '#fbb6ce', 'book', 'expense'),
  ('Lazer', 'Entretenimento e diversão', '#f687b3', 'smile', 'expense'),
  ('Compras', 'Roupas, eletrônicos, etc.', '#ed64a6', 'shopping-bag', 'expense'),
  ('Contas', 'Luz, água, internet, etc.', '#d53f8c', 'file-text', 'expense'),
  ('Outros', 'Outras despesas', '#b83280', 'minus-circle', 'expense');

-- RLS (Row Level Security) - Opcional se você quiser implementar autenticação
-- ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

-- Políticas de RLS (descomente se implementar autenticação)
-- CREATE POLICY "Users can view their own categories" ON categories FOR SELECT USING (auth.uid() = user_id);
-- CREATE POLICY "Users can insert their own categories" ON categories FOR INSERT WITH CHECK (auth.uid() = user_id);
-- CREATE POLICY "Users can update their own categories" ON categories FOR UPDATE USING (auth.uid() = user_id);
-- CREATE POLICY "Users can delete their own categories" ON categories FOR DELETE USING (auth.uid() = user_id);

-- CREATE POLICY "Users can view their own transactions" ON transactions FOR SELECT USING (auth.uid() = user_id);
-- CREATE POLICY "Users can insert their own transactions" ON transactions FOR INSERT WITH CHECK (auth.uid() = user_id);
-- CREATE POLICY "Users can update their own transactions" ON transactions FOR UPDATE USING (auth.uid() = user_id);
-- CREATE POLICY "Users can delete their own transactions" ON transactions FOR DELETE USING (auth.uid() = user_id);