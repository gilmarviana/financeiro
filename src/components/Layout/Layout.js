import React from 'react'
import { Link, useLocation } from 'react-router-dom'
import { 
  LayoutDashboard, 
  CreditCard, 
  PlusCircle, 
  BarChart3, 
  Settings,
  TrendingUp,
  TrendingDown,
  Wallet
} from 'lucide-react'
import './Layout.css'

function Layout({ children }) {
  const location = useLocation()

  const navigation = [
    { name: 'Dashboard', href: '/', icon: LayoutDashboard },
    { name: 'Transações', href: '/transactions', icon: CreditCard },
    { name: 'Receitas', href: '/income', icon: TrendingUp },
    { name: 'Despesas', href: '/expenses', icon: TrendingDown },
    { name: 'Relatórios', href: '/reports', icon: BarChart3 },
    { name: 'Categorias', href: '/categories', icon: Settings },
  ]

  return (
    <div className="layout">
      <nav className="sidebar">
        <div className="sidebar-header">
          <div className="logo">
            <Wallet size={32} />
            <h2>FinanceApp</h2>
          </div>
        </div>
        
        <div className="sidebar-nav">
          {navigation.map((item) => {
            const Icon = item.icon
            const isActive = location.pathname === item.href
            
            return (
              <Link
                key={item.name}
                to={item.href}
                className={`nav-item ${isActive ? 'active' : ''}`}
              >
                <Icon size={20} />
                <span>{item.name}</span>
              </Link>
            )
          })}
        </div>
      </nav>
      
      <main className="main-content">
        <div className="content-wrapper">
          {children}
        </div>
      </main>
    </div>
  )
}

export default Layout