import React, { useMemo } from 'react'
import { useFinance } from '../../context/FinanceContext'
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Cell } from 'recharts'
import { format, startOfMonth, endOfMonth, eachMonthOfInterval, subMonths } from 'date-fns'
import { ptBR } from 'date-fns/locale'

function FinancialChart() {
  const { transactions, summary } = useFinance()

  const monthlyData = useMemo(() => {
    if (!transactions.length) return []

    const last6Months = eachMonthOfInterval({
      start: subMonths(new Date(), 5),
      end: new Date()
    })

    return last6Months.map(month => {
      const monthStart = startOfMonth(month)
      const monthEnd = endOfMonth(month)
      
      const monthTransactions = transactions.filter(transaction => {
        const transactionDate = new Date(transaction.date)
        return transactionDate >= monthStart && transactionDate <= monthEnd
      })

      const income = monthTransactions
        .filter(t => t.type === 'income')
        .reduce((sum, t) => sum + parseFloat(t.amount), 0)
      
      const expenses = monthTransactions
        .filter(t => t.type === 'expense')
        .reduce((sum, t) => sum + parseFloat(t.amount), 0)

      return {
        month: format(month, 'MMM', { locale: ptBR }),
        receitas: income,
        despesas: expenses,
        saldo: income - expenses
      }
    })
  }, [transactions])

  const pieData = useMemo(() => {
    if (summary.totalIncome === 0 && summary.totalExpenses === 0) return []
    
    return [
      {
        name: 'Receitas',
        value: summary.totalIncome,
        color: '#48bb78'
      },
      {
        name: 'Despesas',
        value: summary.totalExpenses,
        color: '#f56565'
      }
    ]
  }, [summary])

  const formatCurrency = (value) => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL',
      minimumFractionDigits: 0,
      maximumFractionDigits: 0
    }).format(value)
  }

  const CustomTooltip = ({ active, payload, label }) => {
    if (active && payload && payload.length) {
      return (
        <div className="chart-tooltip">
          <p className="tooltip-label">{`${label}`}</p>
          {payload.map((entry, index) => (
            <p 
              key={index} 
              className="tooltip-value"
              style={{ color: entry.color }}
            >
              {`${entry.name}: ${formatCurrency(entry.value)}`}
            </p>
          ))}
        </div>
      )
    }
    return null
  }

  if (!transactions.length) {
    return (
      <div className="chart-container">
        <div className="chart-empty">
          <p>Adicione algumas transações para ver os gráficos</p>
        </div>
      </div>
    )
  }

  return (
    <div className="chart-container">
      {monthlyData.length > 0 && (
        <div className="chart-section">
          <h3>Evolução Mensal</h3>
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={monthlyData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
              <XAxis 
                dataKey="month" 
                tick={{ fontSize: 12 }}
                stroke="#718096"
              />
              <YAxis 
                tick={{ fontSize: 12 }}
                stroke="#718096"
                tickFormatter={formatCurrency}
              />
              <Tooltip content={<CustomTooltip />} />
              <Bar dataKey="receitas" fill="#48bb78" radius={[4, 4, 0, 0]} />
              <Bar dataKey="despesas" fill="#f56565" radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>
      )}

      {pieData.length > 0 && (
        <div className="chart-section">
          <h3>Distribuição</h3>
          <ResponsiveContainer width="100%" height={250}>
            <PieChart>
              <Pie
                data={pieData}
                cx="50%"
                cy="50%"
                innerRadius={60}
                outerRadius={100}
                dataKey="value"
                label={({ name, percent }) => `${name}: ${(percent * 100).toFixed(0)}%`}
                labelLine={false}
              >
                {pieData.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={entry.color} />
                ))}
              </Pie>
              <Tooltip formatter={(value) => formatCurrency(value)} />
            </PieChart>
          </ResponsiveContainer>
        </div>
      )}
      
      <style jsx>{`
        .chart-container {
          display: flex;
          flex-direction: column;
          gap: 2rem;
        }
        
        .chart-section h3 {
          margin: 0 0 1rem 0;
          font-size: 1rem;
          font-weight: 600;
          color: #1a202c;
        }
        
        .chart-empty {
          text-align: center;
          padding: 4rem 2rem;
          color: #718096;
        }
        
        .chart-tooltip {
          background: white;
          border: 1px solid #e2e8f0;
          border-radius: 8px;
          padding: 0.75rem;
          box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        
        .tooltip-label {
          margin: 0 0 0.5rem 0;
          font-weight: 600;
          color: #1a202c;
        }
        
        .tooltip-value {
          margin: 0.25rem 0;
          font-size: 0.875rem;
        }
        
        @media (max-width: 768px) {
          .chart-container {
            gap: 1.5rem;
          }
        }
      `}</style>
    </div>
  )
}

export default FinancialChart