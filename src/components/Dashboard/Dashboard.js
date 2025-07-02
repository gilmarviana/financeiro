import React, { useMemo } from 'react'
import { useFinance } from '../../context/FinanceContext'
import { TrendingUp, TrendingDown, DollarSign, CreditCard } from 'lucide-react'
import { format } from 'date-fns'
import { ptBR } from 'date-fns/locale'
import RecentTransactions from './RecentTransactions'
import FinancialChart from './FinancialChart'
import './Dashboard.css'

function Dashboard() {
  const { summary, transactions, loading } = useFinance()

  const formatCurrency = (value) => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(value)
  }

  const recentTransactions = useMemo(() => {
    return transactions.slice(0, 5)
  }, [transactions])

  const cards = [
    {
      title: 'Saldo Total',
      value: summary.balance,
      icon: DollarSign,
      color: summary.balance >= 0 ? 'success' : 'danger',
      trend: summary.balance >= 0 ? 'up' : 'down'
    },
    {
      title: 'Receitas',
      value: summary.totalIncome,
      icon: TrendingUp,
      color: 'success',
      trend: 'up'
    },
    {
      title: 'Despesas',
      value: summary.totalExpenses,
      icon: TrendingDown,
      color: 'danger',
      trend: 'down'
    },
    {
      title: 'Transações',
      value: transactions.length,
      icon: CreditCard,
      color: 'info',
      isCount: true
    }
  ]

  if (loading) {
    return (
      <div className="dashboard">
        <div className="loading">
          <div className="spinner"></div>
          <p>Carregando dados...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="dashboard">
      <div className="dashboard-header">
        <h1>Dashboard Financeiro</h1>
        <p>Bem-vindo ao seu controle financeiro pessoal</p>
      </div>

      <div className="dashboard-cards">
        {cards.map((card, index) => {
          const Icon = card.icon
          return (
            <div key={index} className={`dashboard-card ${card.color}`}>
              <div className="card-header">
                <div className="card-icon">
                  <Icon size={24} />
                </div>
                <div className="card-trend">
                  {card.trend === 'up' && <TrendingUp size={16} />}
                  {card.trend === 'down' && <TrendingDown size={16} />}
                </div>
              </div>
              <div className="card-content">
                <h3>{card.title}</h3>
                <p className="card-value">
                  {card.isCount ? card.value : formatCurrency(card.value)}
                </p>
              </div>
            </div>
          )
        })}
      </div>

      <div className="dashboard-content">
        <div className="chart-section">
          <div className="section-header">
            <h2>Visão Geral Financeira</h2>
          </div>
          <FinancialChart />
        </div>

        <div className="transactions-section">
          <div className="section-header">
            <h2>Transações Recentes</h2>
          </div>
          <RecentTransactions transactions={recentTransactions} />
        </div>
      </div>
    </div>
  )
}

export default Dashboard