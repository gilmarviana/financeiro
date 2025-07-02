import React from 'react'
import { format } from 'date-fns'
import { ptBR } from 'date-fns/locale'
import { TrendingUp, TrendingDown, ArrowRight } from 'lucide-react'
import { Link } from 'react-router-dom'
import './RecentTransactions.css'

function RecentTransactions({ transactions }) {
  const formatCurrency = (value) => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(value)
  }

  const formatDate = (date) => {
    return format(new Date(date), 'dd/MM', { locale: ptBR })
  }

  if (!transactions || transactions.length === 0) {
    return (
      <div className="recent-transactions">
        <div className="empty-state">
          <p>Nenhuma transação encontrada</p>
          <Link to="/transactions" className="add-transaction-btn">
            Adicionar Transação
          </Link>
        </div>
      </div>
    )
  }

  return (
    <div className="recent-transactions">
      <div className="transactions-list">
        {transactions.map((transaction) => {
          const isIncome = transaction.type === 'income'
          return (
            <div key={transaction.id} className="transaction-item">
              <div className="transaction-icon">
                {isIncome ? (
                  <TrendingUp size={16} className="income-icon" />
                ) : (
                  <TrendingDown size={16} className="expense-icon" />
                )}
              </div>
              
              <div className="transaction-details">
                <div className="transaction-description">
                  {transaction.description}
                </div>
                <div className="transaction-meta">
                  <span className="transaction-date">
                    {formatDate(transaction.date)}
                  </span>
                  {transaction.categories && (
                    <span className="transaction-category">
                      {transaction.categories.name}
                    </span>
                  )}
                </div>
              </div>
              
              <div className={`transaction-amount ${isIncome ? 'income' : 'expense'}`}>
                {isIncome ? '+' : '-'}{formatCurrency(Math.abs(transaction.amount))}
              </div>
            </div>
          )
        })}
      </div>
      
      <div className="view-all">
        <Link to="/transactions" className="view-all-link">
          Ver todas as transações
          <ArrowRight size={16} />
        </Link>
      </div>
    </div>
  )
}

export default RecentTransactions