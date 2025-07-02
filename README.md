# Sistema Financeiro Pessoal

Um sistema completo de controle financeiro pessoal desenvolvido em React com Supabase como banco de dados.

## 🚀 Funcionalidades

- **Dashboard Interativo**: Visão geral das finanças com gráficos e resumos
- **Controle de Transações**: Adicionar, editar e remover receitas e despesas
- **Categorização**: Organizar transações por categorias personalizáveis
- **Relatórios Visuais**: Gráficos de evolução mensal e distribuição de gastos
- **Interface Responsiva**: Funciona perfeitamente em desktop e mobile
- **Design Moderno**: Interface limpa e intuitiva

## 🛠️ Tecnologias Utilizadas

- **Frontend**: React, React Router DOM
- **Backend**: Supabase (PostgreSQL)
- **Gráficos**: Recharts
- **Ícones**: Lucide React
- **Notificações**: React Hot Toast
- **Formatação de Datas**: date-fns

## 📋 Pré-requisitos

- Node.js (versão 14 ou superior)
- NPM ou Yarn
- Conta no Supabase

## ⚙️ Configuração

### 1. Clone o repositório
```bash
git clone <url-do-repositório>
cd financeiro
```

### 2. Instale as dependências
```bash
npm install
```

### 3. Configure o Supabase

#### 3.1. Crie um projeto no Supabase
1. Acesse [supabase.com](https://supabase.com)
2. Crie uma nova conta ou faça login
3. Crie um novo projeto
4. Anote a URL do projeto e a chave anônima

#### 3.2. Configure o banco de dados
1. No painel do Supabase, vá para "SQL Editor"
2. Execute o script SQL que está em `database/schema.sql`
3. Isso criará todas as tabelas necessárias e dados iniciais

### 4. Configure as variáveis de ambiente
```bash
cp .env.example .env
```

Edite o arquivo `.env` e adicione suas credenciais do Supabase:
```env
REACT_APP_SUPABASE_URL=https://seu-projeto.supabase.co
REACT_APP_SUPABASE_ANON_KEY=sua-chave-anonima-aqui
```

### 5. Execute o projeto
```bash
npm start
```

O aplicativo estará disponível em `http://localhost:3000`

## 🗄️ Estrutura do Banco de Dados

### Tabelas Principais

#### `categories`
- Categorias para organizar transações
- Campos: id, name, description, color, icon, type

#### `transactions`
- Registro de todas as transações financeiras
- Campos: id, description, amount, type, date, category_id, notes

### Funções Disponíveis

- `get_financial_summary()`: Retorna resumo geral das finanças
- `get_category_summary()`: Retorna resumo por categoria

## 🎨 Estrutura do Projeto

```
src/
├── components/
│   ├── Dashboard/
│   │   ├── Dashboard.js          # Página principal do dashboard
│   │   ├── Dashboard.css         # Estilos do dashboard
│   │   ├── RecentTransactions.js # Lista de transações recentes
│   │   ├── RecentTransactions.css
│   │   ├── FinancialChart.js     # Gráficos financeiros
│   │   └── FinancialChart.css
│   └── Layout/
│       ├── Layout.js             # Layout principal da aplicação
│       └── Layout.css
├── context/
│   └── FinanceContext.js         # Contexto global do estado financeiro
├── services/
│   ├── transactionService.js     # Serviços para transações
│   └── categoryService.js        # Serviços para categorias
├── lib/
│   └── supabase.js              # Configuração do cliente Supabase
├── App.js                       # Componente principal
├── App.css                      # Estilos globais
└── index.js                     # Ponto de entrada
```

## 📱 Páginas e Funcionalidades

### Dashboard
- Resumo financeiro com cards informativos
- Gráfico de evolução mensal (últimos 6 meses)
- Gráfico de distribuição entre receitas e despesas
- Lista das 5 transações mais recentes

### Transações (Em desenvolvimento)
- Lista completa de transações
- Filtros por período e categoria
- Formulário para adicionar/editar transações

### Categorias (Em desenvolvimento)
- Gerenciamento de categorias
- Personalização de cores e ícones

### Relatórios (Em desenvolvimento)
- Relatórios detalhados por período
- Exportação de dados
- Análise de tendências

## 🔧 Scripts Disponíveis

```bash
# Executar em modo de desenvolvimento
npm start

# Executar testes
npm test

# Criar build de produção
npm run build

# Ejetar configurações do Create React App
npm run eject
```

## 🎯 Próximos Passos

- [ ] Implementar autenticação de usuários
- [ ] Adicionar página completa de transações
- [ ] Criar formulários para adicionar/editar transações
- [ ] Implementar página de categorias
- [ ] Adicionar relatórios avançados
- [ ] Implementar filtros e pesquisa
- [ ] Adicionar exportação de dados
- [ ] Implementar backup automático
- [ ] Adicionar notificações e lembretes
- [ ] Criar versão mobile (PWA)

## 🤝 Como Contribuir

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

## 📞 Suporte

Se você encontrar algum problema ou tiver dúvidas:

1. Verifique se seguiu todos os passos de configuração
2. Confirme se o Supabase está configurado corretamente
3. Verifique se todas as dependências foram instaladas
4. Abra uma issue no repositório

## 🙏 Agradecimentos

- [Supabase](https://supabase.com) - Backend as a Service
- [Lucide](https://lucide.dev) - Ícones
- [Recharts](https://recharts.org) - Biblioteca de gráficos
- [React](https://reactjs.org) - Framework frontend
